# Release checklist

- Build the ISO from a clean Arch Linux build host. A first build completed on the current Arch environment; repeat from a clean host before release.
- Boot the ISO in a virtual machine using UEFI and BIOS where available.
- Install Arch in the VM and apply LightOS with the same setup script used for existing Arch systems.
- Verify Hyprland, Waybar, network, audio, screenshots, locking, and application launch.
- Audit committed files for machine names, personal paths, keys, tokens, and account data.
- Confirm redistribution rights for all included fonts, icons, wallpapers, and other artwork, then add required notices.
- The original project code is licensed under MIT; confirm any release-specific attribution requirements.
- Publish the generated checksum and document supported hardware and recovery steps for each release. A SHA256SUMS file is generated with the current ISO artifact.
