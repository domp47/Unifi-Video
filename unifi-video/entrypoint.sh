#!/bin/bash

mongod --fork --logpath /var/log/mongod.log --dbpath /data

unifi-video -D start