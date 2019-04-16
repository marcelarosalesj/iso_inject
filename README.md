# iso_inject

## iso_inject Usage
```
./iso_inject.sh desktop
```
Right now only desktop ISO injection is working.

## QEMU commands
```
qemu-img create -f raw target.img 30G
qemu-system-x86_64 -enable-kvm -m 2048 -boot d -hda target.img -cdrom custom-ubuntu-16.04.6-desktop-amd64.iso
qemu-system-x86_64 -enable-kvm -m 2048 -hda target.img
```

## Documentation and references

* You can generate StarlingX deb packages using this project https://github.com/starlingx-staging/stx-packaging
* https://help.ubuntu.com/community/InstallCDCustomization
* https://nathanpfry.com/how-to-customize-an-ubuntu-installation-disc/


