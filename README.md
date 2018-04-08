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
  * Add `packer` source and `gox` tool
  ```bash
  go get github.com/hashicorp/packer
  ```
  * Compile `packer`
  ```bash
  cd $GOPATH/src/github.com/hashicorp/packer
  go build -o bin/packer .;
  ```
  * Add `gox` tool to `GOPATH`
  ```bash
  go get github.com/mitchellh/gox;
  ```
  * Add `go-vnc` tool
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
cd <this repo path>/ubuntu

# export necessary variables into shell context
export HOST=my.xenhost.com
export USERNAME=root
export PASSWORD=password

# tell packer to make a base box
$GOPATH/bin/packer build \
      -var 'mirror=http://releases.ubuntu.com' \
      ubuntu-16.04-amd64.json
```

The process could take some time, make sure your build server can maintain duplex connection
to selected xenserver.

## Contacts

[Roman Lishtaba](roman@lishtaba.com)
