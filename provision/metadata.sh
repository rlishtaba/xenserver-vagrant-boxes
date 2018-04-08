#!/bin/sh -eux

mkdir -p /etc;
cp /tmp/provision-metadata.json /etc/provision-metadata.json;
chmod 0444 /etc/provision-metadata.json;
rm -f /tmp/provision-metadata.json;
