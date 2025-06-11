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

#### Note on ximea cameras
For the ximea cameras, a driver has to be installed on the host machine. 
I was not able to make it work within the Docker image. The work around was to install the camera driver on the host, and then copied the necessary files into the respecty location in the Docker image 

```
wget https://www.ximea.com/getattachment/281fd5c5-3335-4279-a494-f49c004f00c6/XIMEA_Linux_SP.tgz
tar -xzf XIMEA_Linux_SP.tgz 
cd package 
sudo ./install 
cd .. && rm -rf package XIMEA_Linux_SP.tgz
```
### Docker



