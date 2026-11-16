# LightOS Boot Animation

Official LightOS Plymouth boot animation featuring the progressive
Crimson Ink Awakening effect and rotating Blood Rose.

## Installation

From the main LightOS repository:

    sudo ./components/boot/install.sh

The installer copies the theme without activating it.

## Activation

    sudo plymouth-set-default-theme lightos-v12-crimson-ink
    sudo mkinitcpio -P

Reboot only after initramfs generation succeeds.

## Rollback

To restore the original LightOS-Cinematic theme:

    sudo plymouth-set-default-theme LightOS-Cinematic
    sudo mkinitcpio -P

## Compatibility

The internal Plymouth identifier remains lightos-v12-crimson-ink
for compatibility with existing LightOS installations.

The animation does not intentionally delay boot.
