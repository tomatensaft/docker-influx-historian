## setup wsl/debian with external usb/ssd disk

### install debian

* preinstalled wsl2 is needed
* open powershell as adminisrator and type `wsl --install -d debian`
* maybe on problems with users and/or network, reset the winsock `netsh winsock reset`
* restart host machine and check if wsl is running correctly


### enable systemd and automount of windows drives
```
wsl --update --web-download
wsl --user root printf '[boot]\\nsystemd=true\\n' '>' /etc/wsl.conf
wsl --user root printf '\\n[automount]\\nenabled=true\\nroot=/mnt/\\noptions=\"umask=000,case=off\"\\n' '>>' /etc/wsl.conf
wsl --shutdown

wsl --user root systemctl status
wsl --set-default debian
```

### mount external usb drive for testing with drvfs

* format external usb drive in windows with ntfs
* determine windows drive letter - for example `g:`
* loging into the wsl2/debian instance, make a direcotry and mount the drive

```
mkdir /mnt/f
mount -t drvfs f: /mnt/f
```
