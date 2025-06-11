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


## 🛠️ Setup Instructions on the HOST

## 1.1 Install the XIMEA SDK on the Host
For the XIMEA cameras, a driver must be installed on the host machine. I was unable to get it working directly within the Docker image. The workaround was to install the camera driver on the host system and then copy the necessary files into the appropriate location inside the Docker image.

```
wget https://www.ximea.com/getattachment/281fd5c5-3335-4279-a494-f49c004f00c6/XIMEA_Linux_SP.tgz
tar -xzf XIMEA_Linux_SP.tgz 
cd package 
sudo ./install 
cd .. && rm -rf package XIMEA_Linux_SP.tgz
```

### 1.2. Check camera's feed using app
After installing the XIMEA's drivers, run the following command to check the camera feed.
```
 xiCamTool -L
```

**Note:** On the ubuntu Ubuntu 24.04.2 LTS, after installing the XIMEA's drivers, the app was generating a bug due to missing libtiff.so.5. 

If you're on a bleeding-edge Linux version (like Ubuntu 24.04 or a custom distro with only libtiff6), then:

```
ls /usr/lib/x86_64-linux-gnu/libtiff.so*
```
If you have libtiff.so.6 but not .5, you can try this (⚠ only if XIMEA tools are compatible — may crash):

```
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.6 /usr/lib/x86_64-linux-gnu/libtiff.so.5
```
### 1.3 Feed on terminal 

```
 lsusb | grep XIMEA
```

XIMEA camera serial numbers: 
```
NIR: 41102142
RGB: 14206951
```

If necessary change serial number in the launch file 

Run launch file: 
```
roslaunch ximea_ros_cam multiple_cams.launch
```


## 2.1 Install FLIR BOSON camera (the same should work within the Docker Image)

Verify if the system detects the device 
```
lsusb | grep FLIR
```

Many Boson models support UVC, so they work like webcam
```
v4l2-ctl --list-devices
```

It should return something like the following:
```
Boson: FLIR Video (usb-0000:00:14.0-7.3):
	/dev/video4 <-- This one should be used
	/dev/video5
	/dev/media2
```


It should be possible to visualize the video stream 
```
ffplay /dev/video4
```

### 2.2 Launch File configuration

This camera can be configured to RAW16 or YUV

### 🔬 RAW16 vs YUV – Core Differences

| Feature                  | RAW16                                              | YUV (e.g., YUYV, YUV422)                            |
|--------------------------|----------------------------------------------------|-----------------------------------------------------|
| **Bit Depth**            | 16 bits per pixel                                  | Typically 8 bits per channel                        |
| **Color Information**    | Grayscale or thermal raw values (1 channel)        | Luma + Chroma (Y + U/V)                             |
| **Compression**          | Uncompressed, raw sensor output                    | Color subsampling (chroma compressed)               |
| **Use Case**             | Scientific, radiometric, thermal applications      | Visual display, video streaming                     |
| **Data Format**          | One 16-bit value per pixel (e.g., 0–65535)         | Y (luminance) and U/V (color diffs), interleaved    |
| **Post-Processing Needed?** | Yes, you must normalize or color-map yourself    | No, directly viewable as color image                |
| **Thermal Accuracy**     | ✅ High – raw thermal info preserved                | ❌ Low – thermal info lost during conversion         |


# Docker

Build Docker Image 
```
sh build_and_run_docker.sh build
```

Run Docker Image 
```
sh build_and_run_docker.sh run
```


### Run multiple terminal sessions
1.1 Find container ID
```
docker ps
```

1.2 Open a new terminal and run the following command:
```
docker exec -it <container_name_or_id> bash
```

or run custom script 
```
sh  open_new_terminal_docker.sh <name of the container>
```



## Tools 

To analyze rosbags timestamp use:
```
rqt_bag
```
