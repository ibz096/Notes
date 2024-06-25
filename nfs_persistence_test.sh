#!/bin/bash

# Variables
NFS_SERVER="192.168.1.100"
NFS_SHARE="/exported_dir"
MOUNT_POINT="/mnt/nfs_share"
LOG_FILE="/tmp/nfs_persistence_test.log"
TEST_FILE="$MOUNT_POINT/testfile"
CHECK_INTERVAL=5 # Time in seconds between write attempts

# Function to mount the NFS share
mount_nfs() {
  echo "$(date): Mounting NFS share..." | tee -a "$LOG_FILE"
  sudo mount -t nfs "$NFS_SERVER:$NFS_SHARE" "$MOUNT_POINT" 2>>"$LOG_FILE"
}

# Function to check if NFS is mounted
is_mounted() {
  mountpoint -q "$MOUNT_POINT"
}

# Function to write to the NFS share
write_to_nfs() {
  echo "$(date): Writing to test file..." | tee -a "$LOG_FILE"
  echo "NFS test $(date)" >> "$TEST_FILE"
  if [ $? -eq 0 ]; then
    echo "$(date): Write successful" | tee -a "$LOG_FILE"
  else
    echo "$(date): Write failed" | tee -a "$LOG_FILE"
  fi
}

# Main script execution
echo "Starting NFS persistence test script..." | tee -a "$LOG_FILE"

# Create mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
  sudo mkdir -p "$MOUNT_POINT"
fi

# Initial mount
mount_nfs

# Start monitoring and writing to the NFS share
while true; do
  if is_mounted; then
    write_to_nfs
  else
    echo "$(date): NFS share is not mounted" | tee -a "$LOG_FILE"
    mount_nfs
  fi
  sleep "$CHECK_INTERVAL"
done
