#!/usr/bin/env python3
# bt-popup.py — LightOS Waybar bluetooth picker

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib
import subprocess
import threading
import re

# colors from style.css
C_PINK      = "#fd84cb"
C_PINK_HOT  = "#f738bd"
C_LIGHT     = "#fcedf9"
C_SOFT      = "#fed0f4"
C_DARK      = "#1e1e2e"
C_DIM       = "#2a1e2e"
C_MUTED     = "#888888"
C_SEP       = "#f0c8ec"

CSS = f"""
* {{
    font-family: LightOSNew12, sans-serif;
    font-size: 12px;
    font-weight: bold;
    border: none;
    outline: none;
    box-shadow: none;
}}

window {{
    background-color: transparent;
}}

#card {{
    background-color: {C_LIGHT};
    border-radius: 21px;
    border: 1.5px solid {C_PINK_HOT};
}}

#header {{
    background-color: {C_PINK};
    border-radius: 21px 21px 0px 0px;
    padding: 6px 10px;
    color: {C_DARK};
    font-size: 12px;
    font-weight: bold;
}}

#toggle-btn {{
    background-color: {C_DARK};
    color: {C_SOFT};
    border-radius: 21px;
    padding: 2px 10px;
    font-size: 11px;
    font-family: LightOSNew12, sans-serif;
    font-weight: bold;
    min-height: 0;
}}
#toggle-btn:hover {{
    background-color: {C_SOFT};
    color: {C_DARK};
}}
#toggle-btn.on {{
    background-color: {C_PINK_HOT};
    color: {C_DARK};
}}
#toggle-btn.on:hover {{
    background-color: {C_SOFT};
    color: {C_DARK};
}}

#sep {{
    background-color: {C_SEP};
    min-height: 1px;
    margin: 0px 10px;
}}

#scan-btn {{
    background-color: transparent;
    color: {C_MUTED};
    border-radius: 21px;
    padding: 3px 10px;
    font-size: 10px;
    font-family: LightOSNew12, sans-serif;
    font-weight: bold;
    min-height: 0;
    margin: 4px 8px 0px 8px;
}}
#scan-btn:hover {{
    background-color: {C_PINK};
    color: {C_DARK};
}}
#scan-btn.scanning {{
    color: {C_PINK_HOT};
}}

.device-row {{
    background-color: transparent;
    border-radius: 16px;
    padding: 1px 4px;
    margin: 2px 6px;
}}
.device-row:hover {{
    background-color: {C_PINK};
}}

.device-btn {{
    background-color: transparent;
    border-radius: 14px;
    padding: 6px 10px;
    color: {C_DARK};
    font-family: LightOSNew12, sans-serif;
    font-size: 12px;
    font-weight: bold;
    min-height: 0;
}}
.device-btn:hover {{
    background-color: transparent;
    color: {C_DARK};
}}
.device-btn.connected {{
    color: {C_PINK_HOT};
}}
.device-btn.connecting {{
    color: {C_MUTED};
}}

.battery-tag {{
    background-color: {C_DARK};
    color: {C_SOFT};
    border-radius: 21px;
    padding: 2px 8px;
    font-size: 10px;
    margin-right: 4px;
    min-height: 0;
}}
.battery-tag.connected {{
    background-color: {C_PINK_HOT};
    color: {C_DARK};
}}

#status-label {{
    color: {C_MUTED};
    padding: 10px 14px;
    font-size: 11px;
    font-weight: bold;
}}
""".encode()


# ── helpers ──────────────────────────────────────────────────────────────────

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        return ""

def bt_enabled():
    return "Powered: yes" in run("bluetoothctl show")

def toggle_bt():
    if bt_enabled():
        run("bluetoothctl power off")
    else:
        run("bluetoothctl power on")

def get_paired_devices():
    devices = []
    raw = run("bluetoothctl devices Paired")
    for line in raw.splitlines():
        m = re.match(r"Device ([0-9A-F:]+) (.+)", line)
        if not m:
            continue
        mac, name = m.group(1), m.group(2)
        info = run(f"bluetoothctl info {mac}")
        connected = "Connected: yes" in info
        bat = ""
        bat_m = re.search(r"Battery Percentage: 0x[0-9a-f]+ \((\d+)\)", info)
        if bat_m:
            bat = f"{bat_m.group(1)}%"
        devices.append((mac, name, connected, bat))
    # connected first
    devices.sort(key=lambda d: not d[2])
    return devices

def get_screen_size():
    display = Gdk.Display.get_default()
    monitor = display.get_primary_monitor()
    if monitor:
        geo = monitor.get_geometry()
        return geo.width, geo.height
    return 1920, 1080


# ── popup ─────────────────────────────────────────────────────────────────────

class BtPopup(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_keep_above(True)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)

        screen = Gdk.Screen.get_default()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.set_app_paintable(True)

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self._scanning = False
        self._connecting_mac = None
        self._spinner_chars = ["◐ ", "◓ ", "◑ ", "◒ "]
        self._spinner_idx = 0
        self._spinner_timer = None

        self._build_ui()

        self.connect("focus-out-event", lambda *_: Gtk.main_quit())
        self.connect("key-press-event", self._on_key)
        self.connect("draw", self._on_draw)

    def _on_draw(self, widget, cr):
        # transparent background so border-radius works
        cr.set_source_rgba(0, 0, 0, 0)
        cr.set_operator(1)  # CAIRO_OPERATOR_SOURCE
        cr.paint()
        cr.set_operator(2)  # CAIRO_OPERATOR_OVER
        return False

    def _build_ui(self):
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        outer.set_margin_top(6)
        outer.set_margin_bottom(6)
        outer.set_margin_start(6)
        outer.set_margin_end(6)
        self.add(outer)

        self.card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.card.set_name("card")
        self.card.set_size_request(230, -1)
        outer.pack_start(self.card, True, True, 0)

        # header
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        header.set_name("header")

        title = Gtk.Label(label="󰂯  Bluetooth")
        title.set_halign(Gtk.Align.START)
        title.set_hexpand(True)
        title.set_margin_start(4)
        header.pack_start(title, True, True, 0)

        self.toggle_btn = Gtk.Button()
        self.toggle_btn.set_name("toggle-btn")
        self.toggle_btn.set_margin_end(2)
        self.toggle_btn.connect("clicked", self._on_toggle)
        header.pack_end(self.toggle_btn, False, False, 0)

        self.card.pack_start(header, False, False, 0)

        # separator
        sep = Gtk.Box()
        sep.set_name("sep")
        sep.set_size_request(-1, 1)
        self.card.pack_start(sep, False, False, 0)

        # scan button
        scan_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.scan_btn = Gtk.Button(label="󰑐  Scan for devices")
        self.scan_btn.set_name("scan-btn")
        self.scan_btn.set_hexpand(True)
        self.scan_btn.connect("clicked", self._on_scan)
        scan_row.pack_start(self.scan_btn, True, True, 0)
        self.card.pack_start(scan_row, False, False, 0)

        # separator 2
        sep2 = Gtk.Box()
        sep2.set_name("sep")
        sep2.set_size_request(-1, 1)
        self.card.pack_start(sep2, False, False, 0)

        # device list
        self.list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.list_box.set_margin_top(4)
        self.list_box.set_margin_bottom(6)
        self.card.pack_start(self.list_box, True, True, 0)

        self._refresh_ui()

    def _position_window(self):
        self.show_all()
        sw, sh = get_screen_size()
        w, h = self.get_size()
        # 10px from right edge, 46px from top (just below waybar)
        x = sw - w - 10
        y = 46
        self.move(x, y)

    def _refresh_ui(self):
        for child in self.list_box.get_children():
            self.list_box.remove(child)

        enabled = bt_enabled()
        ctx = self.toggle_btn.get_style_context()

        if enabled:
            self.toggle_btn.set_label("ON")
            ctx.add_class("on")
            self.scan_btn.set_sensitive(True)
        else:
            self.toggle_btn.set_label("OFF")
            ctx.remove_class("on")
            self.scan_btn.set_sensitive(False)

        if not enabled:
            lbl = Gtk.Label(label="Bluetooth is off")
            lbl.set_name("status-label")
            lbl.set_halign(Gtk.Align.CENTER)
            self.list_box.pack_start(lbl, False, False, 0)
            self.show_all()
            return False

        devices = get_paired_devices()

        if not devices:
            lbl = Gtk.Label(label="No paired devices")
            lbl.set_name("status-label")
            lbl.set_halign(Gtk.Align.CENTER)
            self.list_box.pack_start(lbl, False, False, 0)
        else:
            for mac, name, connected, battery in devices:
                row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
                row.get_style_context().add_class("device-row")

                btn = Gtk.Button()
                btn.get_style_context().add_class("device-btn")
                btn.set_relief(Gtk.ReliefStyle.NONE)
                btn.set_hexpand(True)
                btn.set_halign(Gtk.Align.FILL)

                is_connecting = (self._connecting_mac == mac)

                if is_connecting:
                    btn.get_style_context().add_class("connecting")
                    spin = self._spinner_chars[self._spinner_idx % len(self._spinner_chars)]
                    btn.set_label(f"{spin} Connecting...")
                elif connected:
                    btn.get_style_context().add_class("connected")
                    btn.set_label(f"󰂱  {name}")
                else:
                    btn.set_label(f"󰂯  {name}")

                def on_click(b, m=mac, c=connected, ic=is_connecting):
                    if ic:
                        return
                    if c:
                        self._start_disconnect(m)
                    else:
                        self._start_connect(m)

                btn.connect("clicked", on_click)
                row.pack_start(btn, True, True, 0)

                if battery and not is_connecting:
                    bat = Gtk.Label(label=f"󰁹 {battery}")
                    bat.get_style_context().add_class("battery-tag")
                    if connected:
                        bat.get_style_context().add_class("connected")
                    bat.set_valign(Gtk.Align.CENTER)
                    row.pack_end(bat, False, False, 0)

                self.list_box.pack_start(row, False, False, 0)

        self.show_all()
        return False

    # ── connect/disconnect ────────────────────────────────────────────────────

    def _start_connect(self, mac):
        self._connecting_mac = mac
        self._refresh_ui()
        self._start_spinner()

        def do_connect():
            run(f"bluetoothctl connect {mac}")
            GLib.idle_add(self._on_connect_done)

        threading.Thread(target=do_connect, daemon=True).start()

    def _on_connect_done(self):
        self._stop_spinner()
        self._connecting_mac = None
        self._refresh_ui()
        GLib.timeout_add(800, Gtk.main_quit)
        return False

    def _start_disconnect(self, mac):
        def do_disconnect():
            run(f"bluetoothctl disconnect {mac}")
            GLib.idle_add(self._refresh_ui)
        threading.Thread(target=do_disconnect, daemon=True).start()

    # ── spinner ───────────────────────────────────────────────────────────────

    def _start_spinner(self):
        self._spinner_idx = 0
        self._spinner_timer = GLib.timeout_add(200, self._tick_spinner)

    def _tick_spinner(self):
        if self._connecting_mac is None:
            return False
        self._spinner_idx += 1
        self._refresh_ui()
        return True

    def _stop_spinner(self):
        if self._spinner_timer:
            GLib.source_remove(self._spinner_timer)
            self._spinner_timer = None

    # ── scan ─────────────────────────────────────────────────────────────────

    def _on_scan(self, btn):
        if self._scanning:
            return
        self._scanning = True
        self.scan_btn.set_label("󰑐  Scanning...")
        self.scan_btn.get_style_context().add_class("scanning")

        def do_scan():
            subprocess.Popen(
                "bluetoothctl scan on",
                shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL
            )
            import time
            time.sleep(6)
            run("bluetoothctl scan off")
            GLib.idle_add(self._on_scan_done)

        threading.Thread(target=do_scan, daemon=True).start()

    def _on_scan_done(self):
        self._scanning = False
        self.scan_btn.set_label("󰑐  Scan for devices")
        self.scan_btn.get_style_context().remove_class("scanning")
        self._refresh_ui()
        return False

    # ── toggle ────────────────────────────────────────────────────────────────

    def _on_toggle(self, btn):
        toggle_bt()
        GLib.timeout_add(700, self._refresh_ui)

    # ── keyboard ─────────────────────────────────────────────────────────────

    def _on_key(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()

    def run(self):
        self._position_window()
        self.present()
        Gtk.main()


if __name__ == "__main__":
    popup = BtPopup()
    popup.run()
