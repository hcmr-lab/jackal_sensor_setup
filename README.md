# Jackal
======

Common packages for Jackal, including messages and robot description. These are packages relevant
to all Jackal workspaces, whether simulation, desktop, or on the robot's own headless PC.

====
## Access onboard PC
Login: administrator
pass: clearpath
IP: 192.168.131.1

ssh administrator@192.168.131.1

======

## Installation on Host

## 🛠️ Setup Instructions

### 1. Install the XIMEA SDK on the Host
For the XIMEA cameras, a driver must be installed on the host machine. I was unable to get it working directly within the Docker image. The workaround was to install the camera driver on the host system and then copy the necessary files into the appropriate location inside the Docker image.

```
wget https://www.ximea.com/getattachment/281fd5c5-3335-4279-a494-f49c004f00c6/XIMEA_Linux_SP.tgz
tar -xzf XIMEA_Linux_SP.tgz 
cd package 
sudo ./install 
cd .. && rm -rf package XIMEA_Linux_SP.tgz
```
### Docker

Build Docker Image 
```
sh build_and_run_docker.sh build
```

Run Docker Image 
```
sh build_and_run_docker.sh run
```





