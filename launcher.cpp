#include <gtk/gtk.h>
#include <gio/gdesktopappinfo.h>

#include <algorithm>
#include <memory>
#include <string>
#include <unordered_set>
#include <vector>

namespace {

struct AppEntry {
    GDesktopAppInfo* app = nullptr;
    std::string name;
    std::string search_name;
    ~AppEntry() { if (app) g_object_unref(app); }
};

GtkWidget* app_grid = nullptr;
std::vector<std::shared_ptr<AppEntry>> applications;

std::string lower(std::string value) {
    std::transform(value.begin(), value.end(), value.begin(),
                   [](unsigned char ch) { return static_cast<char>(g_ascii_tolower(ch)); });
    return value;
}

void launch_app(GtkButton*, gpointer data) {
    auto* entry = static_cast<AppEntry*>(data);
    GError* error = nullptr;
    if (!g_app_info_launch(G_APP_INFO(entry->app), nullptr, nullptr, &error)) {
        g_warning("Could not launch %s: %s", entry->name.c_str(), error ? error->message : "unknown error");
        if (error) g_error_free(error);
        return;
    }
    gtk_main_quit();
}

GtkWidget* make_app_button(const std::shared_ptr<AppEntry>& entry) {
    GtkWidget* button = gtk_button_new();
    gtk_widget_set_name(button, "app-button");
    gtk_widget_set_size_request(button, 82, 86);
    gtk_button_set_relief(GTK_BUTTON(button), GTK_RELIEF_NONE);
    GtkWidget* content = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    GIcon* icon = g_app_info_get_icon(G_APP_INFO(entry->app));
    GtkWidget* image = icon
        ? gtk_image_new_from_gicon(icon, GTK_ICON_SIZE_DIALOG)
        : gtk_image_new_from_icon_name("application-x-executable", GTK_ICON_SIZE_DIALOG);
    gtk_widget_set_size_request(image, 40, 40);
    GtkWidget* label = gtk_label_new(entry->name.c_str());
    gtk_label_set_ellipsize(GTK_LABEL(label), PANGO_ELLIPSIZE_END);
    gtk_label_set_max_width_chars(GTK_LABEL(label), 11);
    gtk_label_set_lines(GTK_LABEL(label), 2);
    gtk_widget_set_tooltip_text(button, entry->name.c_str());
    gtk_box_pack_start(GTK_BOX(content), image, TRUE, TRUE, 0);
    gtk_box_pack_start(GTK_BOX(content), label, FALSE, FALSE, 0);
    gtk_container_add(GTK_CONTAINER(button), content);
    g_signal_connect(button, "clicked", G_CALLBACK(launch_app), entry.get());
    return button;
}

void show_matching_apps(const char* query) {
    GList* old_children = gtk_container_get_children(GTK_CONTAINER(app_grid));
    for (GList* item = old_children; item; item = item->next)
        gtk_widget_destroy(GTK_WIDGET(item->data));
    g_list_free(old_children);

    const std::string needle = lower(query ? query : "");
    for (const auto& app : applications) {
        if (!needle.empty() && app->search_name.find(needle) == std::string::npos) continue;
        gtk_flow_box_insert(GTK_FLOW_BOX(app_grid), make_app_button(app), -1);
    }
    gtk_widget_show_all(app_grid);
}

void add_apps_from_directory(const std::string& path, std::unordered_set<std::string>& seen) {
    GError* error = nullptr;
    GDir* dir = g_dir_open(path.c_str(), 0, &error);
    if (!dir) {
        if (error) g_error_free(error);
        return;
    }
    const gchar* name = nullptr;
    while ((name = g_dir_read_name(dir))) {
        const std::string filename(name);
        if (filename.size() < 9 || filename.substr(filename.size() - 8) != ".desktop") continue;
        if (!seen.insert(filename).second) continue;
        const std::string full_path = path + "/" + filename;
        GDesktopAppInfo* app = g_desktop_app_info_new_from_filename(full_path.c_str());
        if (!app) continue;
        if (g_desktop_app_info_get_is_hidden(app) || !g_app_info_should_show(G_APP_INFO(app))) {
            g_object_unref(app);
            continue;
        }
        const char* app_name = g_app_info_get_display_name(G_APP_INFO(app));
        if (!app_name || !*app_name) app_name = g_app_info_get_name(G_APP_INFO(app));
        if (!app_name || !*app_name) {
            g_object_unref(app);
            continue;
        }
        auto entry = std::make_shared<AppEntry>();
        entry->app = app;
        entry->name = app_name;
        entry->search_name = lower(entry->name + " " + filename);
        applications.push_back(std::move(entry));
    }
    g_dir_close(dir);
}

void load_applications() {
    std::unordered_set<std::string> seen;
    const char* home = g_get_home_dir();
    std::vector<std::string> dirs = {
        "/usr/share/applications",
        "/usr/local/share/applications",
        std::string(home) + "/.local/share/applications",
        std::string(home) + "/.local/share/flatpak/exports/share/applications",
        "/var/lib/flatpak/exports/share/applications"
    };
    const char* xdg_dirs = g_getenv("XDG_DATA_DIRS");
    if (xdg_dirs) {
        gchar** values = g_strsplit(xdg_dirs, ":", -1);
        for (gchar** value = values; value && *value; ++value)
            if (**value) dirs.emplace_back(std::string(*value) + "/applications");
        g_strfreev(values);
    }
    for (const auto& dir : dirs) add_apps_from_directory(dir, seen);
    std::sort(applications.begin(), applications.end(), [](const auto& a, const auto& b) {
        return g_utf8_collate(a->name.c_str(), b->name.c_str()) < 0;
    });
}

gboolean on_key_press(GtkWidget*, GdkEventKey* event, gpointer) {
    if (event->keyval == GDK_KEY_Escape) {
        gtk_main_quit();
        return TRUE;
    }
    return FALSE;
}

void apply_style() {
    static const char css[] =
        "window { background: rgba(24, 19, 30, 0.08); }"
        "#launcher-panel { background-color: rgba(255, 255, 255, 0.88);"
        " border: 1px solid rgba(253, 132, 203, 0.75); border-radius: 24px; padding: 22px; }"
        "#launcher-title { color: #37283a; font-size: 22px; font-weight: 700; }"
        "#launcher-search { background: rgba(255,255,255,0.86); border: 1px solid #d4aec7;"
        " border-radius: 18px; padding: 10px 14px; color: #302531; }"
        "#app-button { background: transparent; color: #332a35; border: 0; border-radius: 15px; padding: 6px; }"
        "#app-button:hover { background: rgba(253,132,203,0.75); color: #fff; }";
    GtkCssProvider* provider = gtk_css_provider_new();
    gtk_css_provider_load_from_data(provider, css, -1, nullptr);
    gtk_style_context_add_provider_for_screen(gdk_screen_get_default(),
        GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref(provider);
}

GtkWidget* make_character_image() {
    const std::string base = std::string(g_get_home_dir()) + "/.config/Light/assets/launcher/";
    const char* candidates[] = {"elflight.png", "hocelf.png", "memrene.png"};
    for (const char* filename : candidates) {
        const std::string path = base + filename;
        if (!g_file_test(path.c_str(), G_FILE_TEST_IS_REGULAR)) continue;
        GError* error = nullptr;
        GdkPixbuf* pixbuf = gdk_pixbuf_new_from_file_at_scale(path.c_str(), 500, 570, TRUE, &error);
        if (pixbuf) {
            GtkWidget* image = gtk_image_new_from_pixbuf(pixbuf);
            g_object_unref(pixbuf);
            gtk_widget_set_halign(image, GTK_ALIGN_END);
            gtk_widget_set_valign(image, GTK_ALIGN_CENTER);
            gtk_widget_set_margin_end(image, 28);
            gtk_widget_set_sensitive(image, FALSE);
            return image;
        }
        if (error) g_error_free(error);
    }
    return nullptr;
}

} // namespace

int main(int argc, char** argv) {
    gtk_init(&argc, &argv);
    load_applications();
    apply_style();

    GtkWidget* window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "LightOS Launcher");
    gtk_window_set_default_size(GTK_WINDOW(window), 1000, 640);
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
    gtk_window_set_decorated(GTK_WINDOW(window), FALSE);
    g_signal_connect(window, "key-press-event", G_CALLBACK(on_key_press), nullptr);
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), nullptr);

    GtkWidget* overlay = gtk_overlay_new();
    gtk_container_add(GTK_CONTAINER(window), overlay);
    GtkWidget* body = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_size_request(body, 1000, 640);
    gtk_container_add(GTK_CONTAINER(overlay), body);

    GtkWidget* panel = gtk_box_new(GTK_ORIENTATION_VERTICAL, 14);
    gtk_widget_set_name(panel, "launcher-panel");
    gtk_widget_set_size_request(panel, 500, 0);
    gtk_widget_set_margin_start(panel, 24);
    gtk_widget_set_margin_top(panel, 24);
    gtk_widget_set_margin_bottom(panel, 24);
    gtk_box_pack_start(GTK_BOX(body), panel, FALSE, TRUE, 0);

    GtkWidget* title = gtk_label_new("LightOS");
    gtk_widget_set_name(title, "launcher-title");
    gtk_widget_set_halign(title, GTK_ALIGN_START);
    gtk_box_pack_start(GTK_BOX(panel), title, FALSE, FALSE, 0);

    GtkWidget* search = gtk_search_entry_new();
    gtk_widget_set_name(search, "launcher-search");
    gtk_entry_set_placeholder_text(GTK_ENTRY(search), "Search applications");
    gtk_box_pack_start(GTK_BOX(panel), search, FALSE, FALSE, 0);
    g_signal_connect(search, "search-changed", G_CALLBACK(+[](GtkSearchEntry* entry, gpointer) {
        show_matching_apps(gtk_entry_get_text(GTK_ENTRY(entry)));
    }), nullptr);

    GtkWidget* scroller = gtk_scrolled_window_new(nullptr, nullptr);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroller), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC);
    gtk_box_pack_start(GTK_BOX(panel), scroller, TRUE, TRUE, 0);
    app_grid = gtk_flow_box_new();
    gtk_flow_box_set_selection_mode(GTK_FLOW_BOX(app_grid), GTK_SELECTION_NONE);
    gtk_flow_box_set_max_children_per_line(GTK_FLOW_BOX(app_grid), 5);
    gtk_flow_box_set_min_children_per_line(GTK_FLOW_BOX(app_grid), 4);
    gtk_flow_box_set_row_spacing(GTK_FLOW_BOX(app_grid), 5);
    gtk_flow_box_set_column_spacing(GTK_FLOW_BOX(app_grid), 5);
    gtk_container_add(GTK_CONTAINER(scroller), app_grid);

    if (GtkWidget* character = make_character_image()) {
        gtk_overlay_add_overlay(GTK_OVERLAY(overlay), character);
        gtk_overlay_set_overlay_pass_through(GTK_OVERLAY(overlay), character, TRUE);
    }

    show_matching_apps("");
    gtk_widget_show_all(window);
    gtk_widget_grab_focus(search);
    gtk_main();
    return 0;
}
