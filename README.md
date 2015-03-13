# Cookbook: mo_backup

Cookbook to perform application backups. This cookbook uses
[backup gem](http://meskyanichi.github.io/backup/v4/) to run the backups. Please
check the gem documentation for valid options on each supported type.

## Table of Contents

* [Development](#development)
  * [Current state](#current-state)
  * [Features planned](#features-planned)
* [Supported Platforms](#supported-platforms)
* [Recipes](#recipes)
* [Libraries](#libraries)
* [Attributes](#attributes)
* [Usage](#usage)
  * [Required attributes](#required-attributes)
  * [Required databag and databag items](#required-databag-and-databag-items)
    * [Application databag item](#application-databag-item)
    * [Storage databag item](#storage-databag-item)
    * [Mail databag item](#mail-databag-item)
  * [Backup recipe](#backup-recipe)
* [License](#license)
* [Authors](#authors)

## Development

This cookbook is still in development but can be used if current features cover
your needs.

### Current state

For now, this cookbook:

* Supports installing rbenv globally and the backup gem inside it.
* Provides a method to generate the backup configuration file (the model) for:
  * Application files.
  * MySQL, MongoDB and Redis databases.
* Supports:
  * Dropbox, Amazon S3, SCP and SFTP as storages.
  * Backup scheduling.
  * Compression with Gzip.
  * Mail relay configuration.
  * Encryption with OpenSSL.
  * Synchronization using Rsync.

### Features planned

Features to be implemented:

* Notifiers: not all alternatives are implemented
* Storages: not all alternatives are implemented
* Syncers: not all alternatives are implemented

## Supported Platforms

Tested on Ubuntu 14.04, should work on:

* Centos / Redhat / Fedora / Ubuntu / Debian.

## Recipes

This cookbook has only one recipe which is `install`, the one that sets up the
global rbenv environment and the backup gem inside that environment. Must be
run on every server that will execute backups with this cookbook.

## Resources

###`mo_backup`

Creates a model for backup specified archives to be backed up daily, weekly and
monthly. Unless a storage specifies a keep value, each period can specify a different
keep values

Supported attributes are:

* `name`: name of this backup. Name must not contain spaces
* `description`: description for this backup
* `user`: user to run backups as. Defaults to root
* `backup_directory`: directory relative to user's home directory where 
backup configuration will be stored. Defaults to `Backup/models`
* `notifiers`: hash of notifiers specifications
* `use_sudo`: will run tar using sudo
* `root`: specifies base path where relatives archives will be considered
* `archives`: array or string of archives to backup
* `exclude`: array or string of archives to exclude
* `compress`: compress backed up data
* `storages`: hash of storages specifications
* `databases`: hash of databases specifications
* `daily_keeps`: how many backups will be kept for daily backups. *May be
  overwritten by storages definition*
* `weekly_keeps`: how many backups will be kept for weekly backups. *May be
  overwritten by storages definition*
* `monthly_keeps`: how many backups will be kept for monthly backups. *May be
  overwritten by storages definition*
* `start_hour`: start hour to calculate a random backup hour range. Defaults to
  1
* `end_hour`: end hour to calculate a random hour range. Defaults to 7
* `week_day`: default week day to backup data weekly. Defaults to Sunday (0)
* `month_day`: default month day to backup data monthly

###`mo_backup_sync`

Creates a model for syncing specified directories 

Supported attributes are:

* `name`: name of this backup. Name must not contain spaces
* `description`: description for this backup
* `user`: user to run backups as. Defaults to root
* `backup_directory`: directory relative to user's home directory where 
* `directories`: array or string of directories to be synced
* `exclude`: array or string exclude directories to be excluded
* `syncers`: hash of syncers specifications. *If you specify irectories and
  exclude attributes inside a syncer definition, these attributes will be
overwritten by resource values*
* `every_minutes`: number used to specify when sync will be done every number
  minutes. When false sync minutes will be disabled
* `every_hours`: number used to specify when sync will be done every number
  hours. When false sync by hours will be disabled

### Storage, Notifier and Syncer definitions

Are hashes of keys valid for backup gem with its values. For more information
view gem documentation and `library/mo_backu_*.rb` files


## License

The MIT License (MIT)

Copyright (c) 2014 Christian Rodriguez & Leandro Di Tommaso

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Authors

* Author:: Christian Rodriguez (chrodriguez@gmail.com)
* Author:: Leandro Di Tommaso (leandro.ditommaso@mikroways.net)
* Author:: Nahuel Cuesta Luengo (nahuelcuestaluengo@gmail.com)
