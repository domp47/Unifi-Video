#!/bin/bash

function graceful_shutdown {
  echo -n "Stopping unifi-video... "
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

mongod --fork --logpath /var/log/mongod.log --dbpath /db-data

# Run the unifi-video daemon the unifi-video way
echo -n "Starting unifi-video... "
if /usr/sbin/unifi-video --debug start; then
  echo "done."
else
  echo "failed."
  exit 1
fi

while true; do
  sleep 3
done