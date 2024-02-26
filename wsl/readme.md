## setup wsl2/debian with external usb/ssd disk
setup wsl system for use with a windows system and an external usb harddisk

### requirements
* preinstalled wsl2 is needed

### install wsl2/debian
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

### setup docker system
* open the shell of the wsl2/debian instance and login
* install and test docker
```
#directory for keyrings
sudo mkdir -m 0755 -p /etc/apt/keyrings

#update meta data and install curl
sudo apt update
sudo apt install curl

#download keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc
printf 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable' | sudo tee /etc/apt/sources.list.d/docker.list

#install docker engine/compose
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#test hello world
sudo docker run hello-world
```
