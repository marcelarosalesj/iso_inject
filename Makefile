
all:
	@echo "Only make clean works right now"
clean:
	sudo umount custom-img/mnt
	sudo rm -rf custom-img
	sudo rm custom-*.iso
