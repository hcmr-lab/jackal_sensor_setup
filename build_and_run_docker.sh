#!/bin/bash

# Script to build the Docker image and run a container

# --- Configuration ---
IMAGE_NAME="jackal_dev"
IMAGE_TAG="ubuntu_2004_ros1"
CONTAINER_NAME="jackal_dev"

ws_dir="catkin_ws" # Directory inside the container where the host workspace will be mounted
# This is the directory where your catkin workspace will be mounted inside the container.

# Action to perform: "build", "run", or "both" (default)
ACTION="${1:-both}"


# Host directory to map to /workspace in the container.
# This script assumes it's located in the same directory as your Dockerfile.
HOST_WORKSPACE_DIR_RAW="$(pwd)" # Using "." means the directory where the script is run.
                           # "$(pwd)" would also work but "." is often simpler here.

# Resolve to the canonical, absolute path, following all symlinks
HOST_WORKSPACE_DIR=$(readlink -f "${HOST_WORKSPACE_DIR_RAW}")
if [ ! -d "${HOST_WORKSPACE_DIR}" ]; then
    echo "Error: Resolved HOST_WORKSPACE_DIR '${HOST_WORKSPACE_DIR}' is not a directory."
    echo "       (Original path was: '${HOST_WORKSPACE_DIR_RAW}', resolved to '${HOST_WORKSPACE_DIR}')"
    exit 1
fi

# Dockerfile location (relative to this script's execution path)
DOCKERFILE_PATH="Dockerfile"

# Build context (directory containing files for the build, including Dockerfile)
BUILD_CONTEXT="."

# JupyterLab port on the host
#JUPYTER_HOST_PORT="8888"

# --- Build Docker Image ---
if [ "$ACTION" = "build" ] || [ "$ACTION" = "both" ]; then
    DO_BUILD=false
    if [ "$ACTION" = "build" ]; then
        echo "Action is 'build'. Preparing to build image '${IMAGE_NAME}:${IMAGE_TAG}'."
        DO_BUILD=true
    # For 'both' mode (default), check if image exists
    elif ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" >/dev/null 2>&1; then
        echo "Image '${IMAGE_NAME}:${IMAGE_TAG}' not found. Preparing to build for default 'both' mode."
        DO_BUILD=true
    else
        echo "Image '${IMAGE_NAME}:${IMAGE_TAG}' already exists. Skipping build for default 'both' mode."
    fi

    if [ "$DO_BUILD" = true ]; then
        echo "Building Docker image '${IMAGE_NAME}:${IMAGE_TAG}'..."

        # ==========================
        echo "Creating temporary directory for build context..."
        # Create a temporary directory for the build context if it doesn't exist
        mkdir -p tmp/usr/include/m3api/
        # Copy necessary files to the temporary directory
        sudo cp -r /usr/include/m3api/* tmp/usr/include/m3api/
        # Copy the Dockerfile to the temporary directory
        mkdir -p tmp/usr/lib
        # Copy the libm3api.so files to the temporary directory
        sudo cp -r /usr/lib/libm3api.so* tmp/usr/lib
        # ==========================

        # echo "pruning unused Docker images..." # Original script had this echo
        #docker prune -f # Original script had this commented
        echo "Dockerfile: ${DOCKERFILE_PATH}"
        echo "Build Context: ${BUILD_CONTEXT}"

        docker build --no-cache -t \
        "${IMAGE_NAME}:${IMAGE_TAG}" \
        -f "${DOCKERFILE_PATH}" \
        "${BUILD_CONTEXT}"

        rm -rf tmp # Clean up the temporary directory after build
        echo "Removed temporary directory 'tmp' after build."

        
        echo "Docker build command executed."
        if [ $? -ne 0 ]; then
            echo "Docker build failed. Exiting."
            exit 1
        fi
        echo "Docker image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
    fi
fi

# --- Prune unused Docker images (optional, uncomment to enable) ---
# echo "Pruning unused Docker images..."
# docker image prune -f

# --- Run Docker Container ---
if [ "$ACTION" = "run" ] || [ "$ACTION" = "both" ]; then
    # Ensure image exists before attempting to run
    if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" >/dev/null 2>&1; then
        echo "Error: Docker image '${IMAGE_NAME}:${IMAGE_TAG}' does not exist."
        if [ "$ACTION" = "run" ]; then
            echo "Please build it first (e.g., use './$(basename "$0") build' or './$(basename "$0")')."
        else # ACTION is "both", implies build failed or was unexpectedly skipped
            echo "Build may have failed or was not triggered. Cannot run."
        fi
        exit 1
    fi

    echo "Attempting to stop and remove existing container named '${CONTAINER_NAME}' (if any)..."
    docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true

    echo "Running Docker container '${CONTAINER_NAME}' from image '${IMAGE_NAME}:${IMAGE_TAG}'..."
    echo "  Host workspace mounted to /workspace: ${HOST_WORKSPACE_DIR}"
    #echo "  JupyterLab will be accessible on host at: http://localhost:${JUPYTER_HOST_PORT} (or http://<your-docker-host-ip>:${JUPYTER_HOST_PORT})"
    echo "  GPU access will be enabled."

    # -it: Interactive TTY
    # --rm: Automatically remove the container when it exits
    # --gpus all: Make all GPUs available (ensure your Docker and NVIDIA drivers support this)
    # -v: Mount host directory to container directory
    # -p: Map host port to container port
    # --name: Assign a name to the container
    # The last line is the command to run inside the container

    # If you prefer to just get a shell in the container instead of starting JupyterLab automatically,
    # comment out the docker run command above and uncomment the one below:



    xhost + # Allow X11 forwarding for GUI applications (if needed)

    docker run -it --rm \
        --privileged \
        --env="DISPLAY=$DISPLAY" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --name "${CONTAINER_NAME}" \
        -v "${HOST_WORKSPACE_DIR}:/${ws_dir}" \
        -v /etc/udev/rules.d:/etc/udev/rules.d \
        --device=/dev/xi* \
        --device=/dev/bus/usb \
        --volume=/dev:/dev \
        "${IMAGE_NAME}:${IMAGE_TAG}" \
        bash 
    
    echo "Container '${CONTAINER_NAME}' has exited."
fi

# Handle invalid action
if [ "$ACTION" != "build" ] && [ "$ACTION" != "run" ] && [ "$ACTION" != "both" ]; then
    echo "Invalid action: '${ACTION}'. Please use 'build', 'run', or leave blank (for 'both')."
    exit 1
fi