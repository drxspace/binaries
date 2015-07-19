# binaries

Prerequisites
-------------

```bash
sudo apt-get install 

```

```bash
cp -fv getkey.desktop $HOME/Desktop/
sudo cp -fv getkey.sh /usr/local/bin/getkey
sudo cp -fv mp42mkv.sh /usr/local/bin/mp42mkv

su -c '
	cp -fv startHLVB.sh /usr/local/bin/startHLVB
	cp -fv stoprunningVBs.sh /usr/local/bin/stoprunningVBs
	cp -fv shutdown.png /usr/share/pixmaps/
	desktop-file-install shutdown-headless.desktop
'

```


```bash
su -c '
	cp -fv Arch/new-kernel.sh /usr/local/sbin/new-kernel
	cp -fv Arch/update-sys.sh /usr/local/sbin/update-sys
	cp -fv Arch/yup.sh /usr/local/sbin/yup
	cp -fv Arch/ycc.sh /usr/local/sbin/ycc
'

```

