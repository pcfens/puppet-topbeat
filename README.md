# puppet-topbeat

[![Build Status](https://travis-ci.org/pcfens/puppet-topbeat.svg?branch=master)](https://travis-ci.org/pcfens/puppet-topbeat)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with topbeat](#setup)
    - [What topbeat affects](#what-topbeat-affects)
    - [Setup requirements](#setup-requirements)
    - [Beginning with topbeat](#beginning-with-topbeat)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)
    - [Public Classes](#public-classes)
    - [Private Classes](#private-classes)
    - [Public Defines](#public-defines)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The `topbeat` module installs and configures
[topbeat](https://www.elastic.co/products/beats/topbeat) to ship system performance
information to elasticsearch, logstash, or anything else that accepts the beats
protocol.

## Setup

### What topbeat affects

By default `topbeat` adds a software repository to your system, and installs topbeat along
with required configurations.

### Setup Requirements

The `topbeat` module depends on [`puppetlabs/stdlib`](https://forge.puppetlabs.com/puppetlabs/stdlib), and on
[`puppetlabs/apt`](https://forge.puppetlabs.com/puppetlabs/apt) on Debian based systems.

### Beginning with topbeat

`topbeat` can be installed with `puppet module install pcfens-topbeat` (or with r10k, librarian-puppet, etc.)

By default, topbeat ships system statistics (system load, cpu usage, swap usage, and memory usage),
per-process statistics, and disk mounts/usage.

## Usage

All of the default values in topbeat follow the upstream defaults (at the time of writing).

To ship system stats to [elasticsearch](https://www.elastic.co/guide/en/beats/topbeat/current/topbeat-configuration-options.html#elasticsearch-output):
```puppet
class { 'topbeat':
  output => {
    'elasticsearch' => {
     'hosts' => [
       'http://localhost:9200',
       'http://anotherserver:9200'
     ],
     'index'       => 'topbeat',
     'cas'         => [
        '/etc/pki/root/ca.pem',
     ],
    },
  },
}

```

To ship system stats through [logstash](https://www.elastic.co/guide/en/beats/topbeat/current/topbeat-configuration-options.html#logstash-output):
```puppet
class { 'topbeat':
  output => {
    'logstash'     => {
     'hosts' => [
       'localhost:5044',
       'anotherserver:5044'
     ],
     'loadbalance' => true,
    },
  },
}

```

[Shipper](https://www.elastic.co/guide/en/beats/topbeat/current/topbeat-configuration-options.html#configuration-shipper) and [logging](https://www.elastic.co/guide/en/beats/topbeat/current/topbeat-configuration-options.html#configuration-logging) options can be configured the same way, and are documented on the [elastic website](https://www.elastic.co/guide/en/beats/topbeat/current/_overview.html).

### Configuring Inputs

By default, topbeat ships everything that it can, but can be tuned to ship specific
information.

The full default hash looks like
```puppet
{
  period => 10,   # How often stats should be collected and sent, in seconds.
  procs  => [     # An array of what processes to send more detailed information on.
    '.*',
  ]
  stats  => {
    system     => true,   # Whether or not to ship system-wide information
    proc       => true,   # Whether or not individual process information should be shipped
    filesystem => true,   # Whether or not filesystem/disk information should be shipped
  }
}
```

Each component is documented more fully in the
[topbeat documentation](https://www.elastic.co/guide/en/beats/topbeat/current/topbeat-configuration-options.html#configuration-input).

## Reference
 - [**Public Classes**](#public-classes)
    - [Class: topbeat](#class-topbeat)
 - [**Private Classes**](#private-classes)
    - [Class: topbeat::config](#class-topbeatconfig)
    - [Class: topbeat::install](#class-topbeatinstall)
    - [Class: topbeat::params](#class-topbeatparams)
    - [Class: topbeat::repo](#class-topbeatrepo)
    - [Class: topbeat::service](#class-topbeatservice)
    - [Class: topbeat::install::linux](#class-topbeatinstalllinux)
    - [Class: topbeat::install::windows](#class-topbeatinstallwindows)

### Public Classes

#### Class: `topbeat`

Installs and configures topbeat.

**Parameters within `topbeat`**
- `package_ensure`: [String] The ensure parameter for the topbeat package (default: present)
- `manage_repo`: [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
- `service_ensure`: [String] The ensure parameter on the topbeat service (default: running)
- `service_enable`: [String] The enable parameter on the topbeat service (default: true)
- `config_file_mode`: [String] The permissions mode set on configuration files (default: 0644)
- `input`: [Hash] Will be converted to YAML for the input section of the configuration file (see documentation, and above)(default: {})
- `output`: [Hash] Will be converted to YAML for the required output section of the configuration (see documentation, and above)
- `shipper`: [Hash] Will be converted to YAML to create the optional shipper section of the topbeat config (see documentation)
- `logging`: [Hash] Will be converted to YAML to create the optional logging section of the topbeat config (see documentation)
- `conf_template`: [String] The configuration template to use to generate the main topbeat.yml config file
- `download_url`: [String] The URL of the zip file that should be downloaded to install topbeat (windows only)
- `install_dir`: [String] Where topbeat should be installed (windows only)
- `tmp_dir`: [String] Where topbeat should be temporarily downloaded to so it can be installed (windows only)
- `prospectors`: [Hash] Prospectors that will be created. Commonly used to create prospectors using hiera

### Private Classes

#### Class: `topbeat::config`

Creates the configuration files required for topbeat (but not the prospectors)

#### Class: `topbeat::install`

Calls the correct installer class based on the kernel fact.

#### Class: `topbeat::params`

Sets default parameters for `topbeat` based on the OS and other facts.

#### Class: `topbeat::repo`

Installs the yum or apt repository for the system package manager to install topbeat.

#### Class: `topbeat::service`

Configures and manages the topbeat service.

#### Class: `topbeat::install::linux`

Install the topbeat package on Linux kernels.

#### Class: `topbeat::install::windows`

Downloads, extracts, and installs the topbeat zip file in Windows.


## Limitations

This module doesn't load the [elasticsearch index template](https://www.elastic.co/guide/en/beats/topbeat/current/topbeat-getting-started.html#topbeat-template)
into elasticsearch (required when shipping directly to elasticsearch).

## Development

Pull requests and bug reports are welcome. If you're sending a pull request, please consider
writing tests if applicable.
