# sssd

Why this SSSD module, when there are so many others on the forge?

This is a minimalist SSSD module that supports incrementally building the config (via `/etc/sssd/conf.d`) or setting it all at once.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with sssd](#setup)
    * [Beginning with sssd](#beginning-with-sssd)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage the SSD package, config, and services.  You can manage some or all of these elements.  Additionally you can build the SSSD config incrementally via either the `$configs` parameter or by calling the `sssd::config` defined type yourself.

## Setup

### Beginning with sssd

Simply including the class is enough to get the packages and services.  If you want any running authentication domains, you'll need to add those.  Examples are included in the **Usage** section.

## Usage

The two parameters you probably care most about are `$main_config` and `$configs`.

The key thing to remember is if a `domain` is not listed within
```ini
[sssd]
domains=XXXXXXXXXXX
```
It will not be consulted.  So when dropping in overrides make sure to set the domain as you want it.

NOTE: `sssd` does not merge the config elements.  An override from inside `/etc/sssd/conf.d/*.conf` will **REPLACE** the entry defined earlier.  If you are defining domains somewhat dynamically, you'll need to get that sorted out.

### main\_config

This is a hash that gets mapped directly into `/etc/sssd/sssd.conf` (or your `$main_config_file`)

The "value" entries can be either a `String` or an `Array`.  In the case of an `Array`, the content will be automatically joined with a ', ' in your config file.  This should let you merge and knockout elements as needed and possibly have cleaner looking formatting.

```puppet
class { 'sssd':
  main_config => {
    sssd => {
      'setting' => ['value', 'a']
    },
    pam => {
      'setting' => 'value, a'
    },
    nss => {
      'setting' => 'value'
    },
    sudo => {
      'setting' => 'value'
    },
    domain/a => {
      'setting' => 'value'
    },
    domain/b => {
      'setting' => 'value'
    },
  }
}
```
or in hiera
```yaml
sssd::main_config:
  sssd:
    setting:
      - value
      - a
  pam:
    setting: 'value, a'
  nss:
    setting: value
  sudo:
    setting: value
  'domain/a':
    setting:value
  'domain/b':
    setting:value
```

These will produce
```ini
[sssd]
setting=value, a
[pam]
setting=value, a
[nss]
setting=value
[sudo]
setting=value
[domain/a]
setting=value
[domain/b]
setting=value
```

### configs

Items in the `$configs` hash are passed directly into the `sssd::config` defined type.

Their structure is basically the same as `main_config`, but with one extra layer of nesting.

```yaml
sssd::main_config:
  sssd:
    setting:
      - value
      - a
  pam:
    setting: 'value, a'
sssd::configs:
  'override sssd':
    filename: example.conf
    stanzas:
      sssd:
        setting:
          - value
          - b
  override_pam:
    stanzas:
      pam:
        debug: 0
```

This will produce the `$main_config` in `/etc/sssd/sssd.conf` and extra configs in `/etc/sssd/conf.d` containing the stanzas defined under each title.

```ini
# /etc/sssd/sssd.conf
[sssd]
setting=value, a
[pam]
setting=value, a
```

```ini
#/etc/sssd/conf.d/example.conf
[sssd]
setting:value, b
```

```ini
#/etc/sssd/conf.d/50-pam.conf
[pam]
debug=0
```

## Limitations

This module specifically does not manipulate files or services
that do not belong to sssd.  There are other modules on the forge
that can configure pam/[authselect](https://forge.puppet.com/modules/jcpunk/authselect)
and oddjob/`login.defs`.

If you want to manipulate the sssd startup units, I'd recommend the
`systemd::dropin` features from [puppet-systemd](https://forge.puppet.com/modules/puppet/systemd)

## Development

Hop on over to the git repo listed in `metadata.json`
