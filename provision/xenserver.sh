#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
xenserver-iso|xenserver-pv)
    VER="7.11.0-1";
    REPO_HOST="http://nexus.ncr.systems";
    REPO_PATH="repository/xen-tools-ingress/iso";
    ISO="guest-tools-$VER.iso";
    cd $HOME_DIR;
    curl -L -O "${REPO_HOST}/${REPO_PATH}/${ISO}"
    mkdir -p /tmp/xenserver;
    mount -o loop $HOME_DIR/$ISO /tmp/xenserver;
    cd /tmp/xenserver/Linux
    ./install.sh -n \
        || echo "install.sh exited $? and is suppressed.";
    cd $HOME_DIR;
    umount /tmp/xenserver;
    rm -rf /tmp/xenserver;
    rm -f $HOME_DIR/*.iso;
    ;;
esac
