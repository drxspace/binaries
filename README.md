# binaries

## Prerequisites

### Debian

```bash
sudo apt-get install yad xsel

```

## Installation

### All

```bash
	sudo -v

```

```bash
	cp -fv getkey.desktop $HOME/Desktop/
	cp -fv getpb.desktop $HOME/Desktop/
	sudo cp -fv sendclip.sh /usr/local/bin/sendclip
	sudo cp -fv guvok.sh /usr/local/bin/guvok
	sudo cp -fv mp42mkv.sh /usr/local/bin/mp42mkv
	sudo cp -fv termites.sh /usr/local/bin/termites
	sudo cp -fv vboxtestbuild.sh /usr/local/bin/vboxtestbuild

```

##### VirtualBoxes

```bash
sudo su -c '
	cp -fv startHLVB.sh /usr/local/bin/startHLVB
	cp -fv stoprunningVBs.sh /usr/local/bin/stoprunningVBs
	cp -fv shutdownVBs.png /usr/share/pixmaps/
	desktop-file-install shutdown-virtualboxes.desktop
'

```

### Debian

##### Re-enable Repositories version 2.1.0 (20160128)

```bash
sudo su -c '
	cp -fv Ubuntu/afterdistupgrade.sh /usr/local/bin/afterdistupgrade
	cp -fv Ubuntu/su-afterdistupgrade.sh /usr/local/bin/pkexec-afterdistupgrade
	cp -fv Ubuntu/org.freedesktop.pkexec.run-afterdistupgrade-as-root.policy /usr/share/polkit-1/actions/
	desktop-file-install Ubuntu/afterdistupgrade.desktop
'

```

### Arch

```bash
sudo su -c '
	cp -fv Arch/new-kernel.sh /usr/local/sbin/new-kernel
	cp -fv Arch/update-sys.sh /usr/local/sbin/update-sys
	cp -fv Arch/yup.sh /usr/local/sbin/yup
	cp -fv Arch/ycc.sh /usr/local/sbin/ycc
'

```

## Uninstall

### All

```bash
	sudo -v

```

```bash
	rm -fv $HOME/Desktop/getkey.desktop
	rm -fv $HOME/Desktop/getpb.desktop
	sudo rm -fv /usr/local/bin/sendclip
	sudo rm -fv /usr/local/bin/guvok
	sudo rm -fv /usr/local/bin/mp42mkv
	sudo rm -fv /usr/local/bin/termites
	sudo rm -fv /usr/local/bin/vboxtestbuild

```

##### VirtualBoxes

```bash
sudo su -c '
	rm -fv /usr/local/bin/startHLVB
	rm -fv /usr/local/bin/stoprunningVBs
	rm -fv /usr/share/pixmaps/shutdownVBs.png
	rm -fv /usr/share/applications/shutdown-virtualboxes.desktop
'

```

### Debian

##### Re-enable Repositories

```bash
sudo su -c '
	rm -fv /usr/local/bin/afterdistupgrade
	rm -fv /usr/local/bin/pkexec-afterdistupgrade
	rm -fv /usr/share/polkit-1/actions/org.freedesktop.pkexec.run-afterdistupgrade-as-root.policy
	rm -fv /usr/share/applications/afterdistupgrade.desktop
'

```

