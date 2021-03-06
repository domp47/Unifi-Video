#!/bin/bash

# Start up w/ the right umask
echo "[info] UMASK defined as '${UMASK}'." | ts '%Y-%m-%d %H:%M:%.S'
umask "${UMASK}"

# Options fed into unifi-video script
unifi_video_opts=""

# Graceful shutdown, used by trapping SIGTERM
function graceful_shutdown {
  echo -n "Stopping unifi-video... " | ts '%Y-%m-%d %H:%M:%.S'
  if /usr/sbin/unifi-video --nodetach stop; then
    echo "done."
    exit 0
  else
    echo "failed."
    exit 1
  fi
}

# Trap SIGTERM for graceful exit
trap graceful_shutdown SIGTERM

# Change user nobody's UID to custom or match unRAID.
echo "[info] PUID defined as '${PUID}'" | ts '%Y-%m-%d %H:%M:%.S'

# Set user unify-video to specified user id (non unique)
usermod -o -u "${PUID}" unifi-video &>/dev/null

# Change group users to GID to custom or match unRAID.
echo "[info] PGID defined as '${PGID}'" | ts '%Y-%m-%d %H:%M:%.S'

# Set group users to specified group id (non unique)
groupmod -o -g "${PGID}" unifi-video &>/dev/null

# Create logs directory
mkdir -p /var/lib/unifi-video/logs

# check for presence of perms file, if it exists then skip setting
# permissions, otherwise recursively set on volume mappings for host
if [[ ! -f "/var/lib/unifi-video/perms.txt" ]]; then
  echo "[info] No perms.txt found, setting ownership and permissions recursively on videos." | ts '%Y-%m-%d %H:%M:%.S'

  volumes=( "/var/lib/unifi-video" )

  # Set user and group ownership of volumes.
  if ! chown -R "${PUID}":"${PGID}" "${volumes[@]}"; then
    echo "[warn] Unable to chown ${volumes[*]}." | ts '%Y-%m-%d %H:%M:%.S'
  fi

  # Check for umask 002, set permissions to 775 folders and 664 files.
  if [[ "${UMASK}" -eq 002 ]]; then
    if ! chmod -R a=,a+rX,u+w,g+w "${volumes[@]}"; then
      echo "[warn] Unable to chmod ${volumes[*]}." | ts '%Y-%m-%d %H:%M:%.S'
    fi
  fi

  # Check for umask 022, set permissions to 755 folders and 644 files.
  if [[ "${UMASK}" -eq 022 ]]; then
    if ! chmod -R a=,a+rX,u+w "${volumes[@]}"; then
      echo "[warn] Unable to chmod ${volumes[*]}." | ts '%Y-%m-%d %H:%M:%.S'
    fi
  fi

  # Warn when neither umask 002 or 022 is set.
  if [[ "${UMASK}" -ne 002 ]] && [[ "${UMASK}" -ne 022 ]]; then
    echo "[warn] Umask not set to 002 or 022, skipping chmod." | ts '%Y-%m-%d %H:%M:%.S'
  fi

  echo "This file prevents permissions from being applied/re-applied to /config, if you want to reset permissions then please delete this file and restart the container." > /var/lib/unifi-video/perms.txt
else
  echo "[info] File perms.txt blocks chown/chmod of videos." | ts '%Y-%m-%d %H:%M:%.S'
fi

# No debug mode set via env, default to off
if [[ -z ${DEBUG} ]]; then
  DEBUG=0
fi

# Run with --debug if DEBUG=1
if [[ ${DEBUG} -eq 1 ]]; then
  echo "[debug] Running unifi-video service with --debug." | ts '%Y-%m-%d %H:%M:%.S'
  unifi_video_opts="--debug"
fi

echo -n "Starting mongodb..."
if mongod --fork --logpath /var/log/mongod.log; then
echo "done."
else
  echo "failed."
  exit 1
fi

# Run the unifi-video daemon the unifi-video way
echo -n "Starting unifi-video... " | ts '%Y-%m-%d %H:%M:%.S'
if /usr/sbin/unifi-video "${unifi_video_opts}" start; then
  echo "done."
else
  echo "failed."
  exit 1
fi

# Loop while we wait for shutdown trap
while true; do
  # When --tmpfs is used, container restarts cause these folders to go missing.
  if [[ ! -d /var/cache/unifi-video/exports ]]; then
    echo -n "Re-creating and setting ownership/permissions on /var/cache/unifi-video/exports... "
    mkdir -p /var/cache/unifi-video/exports
    chown unifi-video:unifi-video /var/cache/unifi-video/exports
    chmod 700 /var/cache/unifi-video/exports
    echo "done."
  fi

  if [[ ! -d /var/cache/unifi-video/hls ]]; then
    echo -n "Re-creating and setting ownership/permissions on /var/cache/unifi-video/hls... "
    mkdir -p /var/cache/unifi-video/hls
    chown unifi-video:unifi-video /var/cache/unifi-video/hls
    chmod 775 /var/cache/unifi-video/hls
    echo "done."
  fi
  sleep 5
done