#!/bin/sh -eux

 yum install -y bzip2 tar perl gcc make
 yum install -y "kernel-devel-uname-r == $(uname -r)"
