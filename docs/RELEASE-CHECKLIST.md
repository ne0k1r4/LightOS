# Release checklist

- Build the ISO from a clean Arch Linux build host.
- Boot the ISO in a virtual machine using UEFI and BIOS where available.
- Install Arch in the VM and apply LightOS with the same setup script used for existing Arch systems.
- Verify Hyprland, Waybar, network, audio, screenshots, locking, and application launch.
- Audit committed files for machine names, personal paths, keys, tokens, and account data.
- Confirm redistribution rights for all included fonts, icons, wallpapers, and other artwork, then add required notices.
- Decide and add a license for the original project code.
- Publish checksums and document supported hardware and recovery steps for each release.
