# LightOS projects

`LightOS` is the master repository and includes each application/component as a Git submodule. Clone with `git clone --recurse-submodules` to fetch the full source set. The master installer copies the desktop defaults and invokes the components' installers, so one recursive LightOS clone is enough for desktop setup.

- `LightOS` — Arch ISO profile and master project.
- `LightOS-Installer` — existing-Arch setup and bootstrap scripts.
- `LightOS-Settings` — GTK 4 Settings app with the Death Note Realm theme; its Support UI is disabled.
- `LightOS-Welcome` — GTK 4 first-run welcome app.
- `LightOS-Launcher` — GTK application launcher and its artwork.
- `LightOS-Workspace` — Hyprland workspace commands.
- `LightOS-Widgets` — Waybar system status helpers, buildable clock, and audio visualizers.
- The LightOS GRUB theme is kept in `system/grub/themes/LightOS` and installed with `./install/install-lightos.sh --apply --with-grub`.
- `LightOS-Updater` — Arch package update helper.
- `LightOS-Downloader` — standalone Qt 6 direct-URL downloader.
- `LightOS-Assets` — original scalable LightOS application, file-type, and status icons.

Each project has its own build/install instructions and license. The component repositories must be pushed before the master repository so that a recursive clone can fetch each pinned commit. No remote repository has been pushed by this workspace.

## Push order

Create each empty GitHub repository under `ne0k1r4`, then push each component from its local project directory:

```sh
for name in LightOS-Assets LightOS-Downloader LightOS-Settings LightOS-Welcome LightOS-Launcher LightOS-Workspace LightOS-Widgets LightOS-Updater LightOS-Installer; do
  git -C "$HOME/dev/projects/$name" push -u origin main
done
git -C "$HOME/dev/projects/LightOS" push -u origin main
```

Push the master last. It pins the component commit IDs in its submodule entries.
