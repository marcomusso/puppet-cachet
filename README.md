# puppet-cachet

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with cachet](#setup)
    * [What cachet affects](#what-cachet-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cachet](#beginning-with-cachet)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
    * [Running tests](#running-tests)

## Overview

This module installs a [Cachet](https://cachethq.io/) status page.

## Module Description

This module will install PHP5.5 from Webtatic and the postgres96 client libraries if you want to use a remote database.
Cachet will be installed directly from the github repo specified in the parameter `repo_url`.

There is no guarantee that this module will work, use it at your own risk :)

It's currently only tested and used on CentOS7.

## Setup

### What cachet affects

This module will add the postgres96 and webtatic repos to your system (if `$manager_repo` is `true`).

### Setup Requirements

This module needs these modules (see .fixtures):

- vcsrepo
- apache
- concat
- firewall

### Beginning with cachet

In your main module you should take care of setting up the YUM environment (if `$manage_repo` is `false` which is the default) and call the main `::cachet` class.

This module will install and configure an Apache virtual host based on `$server_name` and install in `/opt/cachet` by default.

It's pretty limited but it's a start.

## Usage

    class { '::cachet':
      manage_repo       => true,
      server_name       => 'status.mydomain.com',
      database_host     => 'mydatabasehost.example.com',
      database_port     => '5432',
      database_name     => 'my_status_page',
      database_user     => 'my_status_page_ser',
      database_password => 'my_status_page_assword',
      sslkey            => 'my ssl key',
      sslcert           => 'my ssl cert',
      sslchain          => 'my ssl chain',
    }

You can avoid installing apache (and provide your own web server with php support) by setting `manage_apache => false` but if you do you need to supply you cert/key/chain file **contents** (not a path to a file!).

The Cachet configuration (env file) will be created based on the template and the values supplied as the class attributes (see `init.pp`, more to come).

APP_KEY will be generated during application installation (in v2.3.x).

## Reference

Here, list the classes, types, providers, facts, etc contained in your module. This section should include all of the under-the-hood workings of your module so people know what the module is touching on their system but don't need to mess with things. (We are working on automating this section!)

### Classes

#### Public Classes
* `cachet`: Main class

#### Private Classes
* `cachet::params`: Manages cachet default parameters.
* `cachet::install`: Manages cachet installation.
* `cachet::config`: Manages cachet configuration.
* `cachet::apache`: Manages the cachet web server.

### Parameters

#### cachet

##### manage_repos

Bool. If this module should try to add repos (default: `false`).

##### database_host

String. Database host (without port) (default: `''` that means using sqlite).

##### database_port

String. Database port.

##### database_name

String. Database name.

##### database_user

String. Database user.

##### database_password

String. Database password.

##### database_prefix

String. Database prefix for objects. (default no prefix)

##### repo_url

String. Full URL of the cachet repo (default: `https://github.com/cachethq/Cachet.git`).

##### git_branch

String. the git ref/branch to the actual code (default: `v2.3.10`).

##### install_dir

String. Full path of installation directory for Cachet.

##### server_name

String. The FQDN of the webserver vhost that will serve the application.

##### sslkey

String. The actual SSL key to pass to Apache (probably you want to encrypt that in hiera).

##### sslcert

String. The actual SSL cert to pass to Apache (probably you want to store that in hiera or in your module).

##### sslchain

String. The optional SSL cert chain to pass to Apache (probably you want to store that in hiera or in your module).

##### env_file

String. Content of the env file (possibly coming from an erb from the calling manifest).

## Limitations

This module is tested only on CentOS 7 and with the postegres 9.6 client libraries.

## Development

### Running tests

Install gems for development and testing.
```
$ bundle install
```

Run rspec tests
```
$ bundle exec rake spec
```

Validate puppet syntax and puppet-lint
```
$ bundle exec rake validate
```

Run acceptance tests. This requires vagrant and virtualbox.
```
$ bundle exec rake acceptance
```
