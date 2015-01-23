# ltsp

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ltsp](#setup)
    * [What ltsp affects](#what-ltsp-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module is used to configure an ltsp server and the client images.
This has only been tested on Ubuntu.

## Module Description

This module will create an ltsp image, install puppet in it, and then run puppet from within the chroot
so you can manage the chroot like any other server. You have to give the client a particular cert name
so that the puppet master can tell the chroot puppet agent and host puppet agent apart.

This module will also install the ltsp package and any configuration files with it.

## Setup

### What ltsp affects

* Installs the ltsp packages
* Installs/manages any server configuration files needed.
* Installs/manages clients images in /opt/ltsp.

### Setup Requirements

* The ltsp class makes hiera lookups so you need that configured and ready.

## Usage

This module has 1 class:

    class { 'ltsp' :
        package => # The name of the package for ltsp. Can be an array.
    }

This module has 1 resource type:

    ltsp::image { 'resource title' :
        image                => # The name of this image. Defaults to title.
        image_cert           => # The cert name the image will use to connect to the pupper master.
        image_environment    => # The puppet environment for the image. Defaults to the current environment.
        image_puppetmater    => # The name of the puppet master. Defaults to the current puppet master.
        image_puppetmasterip => # The puppet master's ip. Defaults to the current master's ip.
    }

The ltsp class makes the following hiera lookups:

    ltsp::files:          # A hash containing any files that need to be installed on the ltsp server.
    ltsp::file_defaults:  # A hash of defaults for the files.
    ltsp::images:         # A hash containing all the images to install.
    ltsp::image_defaults: # A hash of defaults for the images.

Example yaml file:

    ltsp::package: ltsp
    ltsp::file_defaults:
        owner: 0
        group: 0
        mode:  '644'
    ltsp::files:
        /etc/ltsp/dhcp.conf:
            source: puppet:///
    ltsp::client_defaults:
        image_environment: production
    ltsp::clients:
        myimage64:
            image_cert: myimage64.exmaple.cert
        myimage32:
            image_cert: myimage32.example.cert

## Limitations

I've only tested this with Ubuntu's ltsp, but it should also work with Debian's. I don't have much hope for OpenSuse's ltsp, but 
feel free to try.

