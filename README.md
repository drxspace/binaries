# binaries

## Prerequisites

### Debian

```bash
sudo apt-get install 

```

## Installation

### All

```bash
	sudo -v
	sudo cp -fv getkey.sh /usr/local/bin/getkey
	cp -fv getkey.desktop $HOME/Desktop/
	sudo cp -fv mp42mkv.sh /usr/local/bin/mp42mkv

```

##### VirtualBoxes, 

```bash
su -c '
	cp -fv startHLVB.sh /usr/local/bin/startHLVB
	cp -fv stoprunningVBs.sh /usr/local/bin/stoprunningVBs
	cp -fv shutdownVBs.png /usr/share/pixmaps/
	desktop-file-install shutdown-virtualboxes.desktop
'

```

### Debian

##### Re-enable Repositories version 1.0 (20151004), 

```bash
su -c '
	cp -fv Ubuntu/afterdistupgrade.sh /usr/local/bin/afterdistupgrade
	cp -fv Ubuntu/su-afterdistupgrade.sh /usr/local/bin/pkexec-afterdistupgrade
	cp -fv Ubuntu/org.freedesktop.pkexec.run-afterdistupgrade-as-root.policy /usr/share/polkit-1/actions/
	desktop-file-install Ubuntu/afterdistupgrade.desktop
'

```

### Arch

```bash
su -c '
	cp -fv Arch/new-kernel.sh /usr/local/sbin/new-kernel
	cp -fv Arch/update-sys.sh /usr/local/sbin/update-sys
	cp -fv Arch/yup.sh /usr/local/sbin/yup
	cp -fv Arch/ycc.sh /usr/local/sbin/ycc
'

```

## Uninstall

### All

##### VirtualBoxes, 

```bash
su -c '
	rm -fv /usr/local/bin/startHLVB
	rm -fv /usr/local/bin/stoprunningVBs
	rm -fv /usr/share/pixmaps/shutdownVBs.png
	rm -fv /usr/share/applications/shutdown-virtualboxes.desktop
'

```

### Debian

##### Re-enable Repositories, 

```bash
su -c '
	rm -fv /usr/local/bin/afterdistupgrade
	rm -fv /usr/local/bin/pkexec-afterdistupgrade
	rm -fv /usr/share/polkit-1/actions/org.freedesktop.pkexec.run-afterdistupgrade-as-root.policy
	rm -fv /usr/share/applications/afterdistupgrade.desktop
'

```

