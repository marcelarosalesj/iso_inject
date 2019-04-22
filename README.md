# iso_inject

## iso_inject Usage
```
# Inject to Ubuntu Desktop 16.04
./iso_inject.sh desktop
# Inject to Ubuntu Server 18.04
./iso_inject.sh serv18
```
Note: Right now Ubuntu Server 16.04 ISO injection is not working. Current process is relying on the manipulation of live image filesystem.

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
* https://serverfault.com/questions/930163/what-is-the-difference-between-ubuntu-server-and-ubuntu-server-live

