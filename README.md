## Xenserver provider vagrant boxes (packer templates)

The following repo containing packer templates and default provisioning scripts
required to build base vagrant boxes and use them in your XEN server environment.

If you just want to try boxes out, not build them - go ahead and explore published `xenserver` boxes [here](https://app.vagrantup.com/rlishtaba).

## Xen virtualization stack

If you are not yet familiar with XEN virtualization - go ahead and study it [here](https://www.xenproject.org/)

## Packer tool

This repository using `packer` tool as base-box assembly tool. Particularly, it
is relying on official `xenserver` packer builder which is originally posted [here](https://github.com/xenserver/packer-builder-xenserver).

* Install `Golang` and export nessesary variables:
  * Download `golang` release from [here](https://golang.org/dl/)
  * Untar archive and prepare envirounment. Example will be using `golang` release `v1.9.5`.
  ```bash
  RELEASE="go1.9.5.linux-amd64";
  cd /tmp && curl -L -O "https://dl.google.com/go/${RELEASE}.tar.gz";
  tar -zxvf "${RELEASE}.tar.gz";
  mv -v go $HOME/go-1.9.5;
  rm -f "/tmp/${RELEASE}.tar.gz";
  ```
  * Export `golang` env variables
  ```bash
  export GOROOT=$HOME/go-1.9.5;
  export GOPATH=$HOME/go-workspace;
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin;
  ```
  * Add `packer` source to `GOPATH`
  ```bash
  go get github.com/hashicorp/packer;
  ```
  * Compile `packer`
  ```bash
  cd $GOPATH/src/github.com/hashicorp/packer;
  go build -o bin/packer .;
  ```
  * Add `gox` tool to `GOPATH`
  ```bash
  go get github.com/mitchellh/gox;
  ```
  * Add `go-vnc` tool to `GOPATH`
  ```bash
  go get github.com/mitchellh/go-vnc;
  ```

### XenServer packer.io builder

As I mentioned before, this repository using official `xen` packer builder built by `xenserver` team. I will supply detailed instructions of `how to compile` builder.

#### Compile Xen packer plugin

Once you have installed Packer, you must compile this plugin and install the resulting binary.

```bash
cd $GOPATH;
PROV="src/github.com/xenserver";
mkdir -p $PROV && cd $PROV;
git clone https://github.com/xenserver/packer-builder-xenserver.git;
cd packer-builder-xenserver;
./build.sh;
```

At this point you should be able to operate with proper version of `packer` builder.

## Building xenserver base box

The following snippet should give you an idea how to make your base-box of `ubuntu v16.04` image.

```bash
# change to workspace
cd <this repo path>/ubuntu;

# export necessary variables into shell context
export HOST=my.xenhost.com;
export USERNAME=root;
export PASSWORD=password;

# tell packer to make a base box
$GOPATH/bin/packer build \
      -only=xenserver-iso\
      -var 'mirror=http://releases.ubuntu.com' \
      ubuntu-16.04-amd64.json;
```

The process could take some time, make sure your build server can maintain duplex connection
to selected xenserver.

## ISO mirror alternatives

### Cent OS

```bash
$GOPATH/bin/packer build \
      -only=xenserver-iso\
      -var 'mirror=http://mirrors.kernel.org/centos' \
      centos-7.4-x86_64-minimal.json;
```

### Ubuntu

```bash
$GOPATH/bin/packer build \
      -only=xenserver-iso\
      -var 'mirror=http://releases.ubuntu.com' \
      ubuntu-16.04-amd64.json;
```

### Packaging your base boxes

This stage is written with assumption that `packer` biuld has been completed
successfuly.

* Upload produced `xva` file to file storge service/server
```bash
BOX_VERSION="0.1.0";
REPO="http://your-repo.com/repository/vagrant-boxes/xenserver";
BOX="ubuntu-16.04";

# Your remote binary repo destination URL/
URL="${REPO}/${BOX}/${VER}/export.xva";

# This is the product of packer build process.
LOCAL_XVA_BASE_BOX_FILE="${BOX}-${VER}.xva";

# Upload local box to your remote binary repo.
curl --upload $LOCAL_XVA_BASE_BOX_FILE $URL;
```

* Make new vagrant base box content files an then `tar` them into `.box` archive.
```bash

# Create vagrant provider metadata file.
echo "{\"provider\": \"xenserver\"}" > metadata.json;

# Create default vagrant file
cat > Vagrantfile <<EOF
Vagrant.configure(2) do |config|
  config.vm.provider :xenserver do |xs|
    xs.xva_url = "$URL"
  end
end
EOF

# Make a vagrant box archive
tar -cvf "${BOX}-${VER}.box" metadata.json Vagrantfile
```
* Upload `vagrant` box to your remote repository
```bash

# Upload vagrant box definition to your remote binary repository
curl --upload "${BOX}-${VER}.box" "${REPO}/${BOX}/${VER}/you-vagrant-base-vm.box";
```
* Create `vagrant` base box release or use mine
* Create new `Vagrantfile`
```bash
cat > Vagrantfile <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'rlishtaba/ubuntu-16.04.4-server'
  config.vm.box_version = '0.4.0'

  config.vm.provider :xenserver do |xs|
    xs.xs_host = 'your.xenserver.com'
    xs.xs_username = 'root'
    xs.xs_password = 'password'
    xs.pv = true
    xs.memory = 2048
    xs.use_himn = false
  end

  config.vm.network 'public_network', bridge: 'xenbr0'
end
EOF
```
* Execute `vagrant up`.

## List of vagrant box versions available @ Vagrant cloud

* [ubuntu-16.04.4-server](https://app.vagrantup.com/rlishtaba/boxes/ubuntu-16.04.4-server)
* [centos-7.4-minimal](https://app.vagrantup.com/rlishtaba/boxes/centos-7.4-minimal)

## Contacts

* [Roman Lishtaba](roman@lishtaba.com)
