# install_vagrant-cookbook

This script automates the installation of the needed applications and plugins 
for BQ SW-OPERATIONS/chef- projects.

## URL

* https://stash.bq.com/projects/SWOP/repos/ops-tools/browse/install_vagrant


## Supported Platforms

* ubuntu 14.0.4 LTS

## Usage

Download or send the script in files/default/install_vagrant.sh

Run it with

```
$ chmod +x install_vagrant.sh
```

In some point in time, the script will ask your password (sudo) and later to 
press <ENTER> to continue with the installation.

## Debugging

You can test the script and improve it by using kitchen.

```
$ kitchen create
```

Will create a kitchen machine without chef (DO NOT run kitchen converge on it)

Then with

```
$ scp -P 2222 files/default/install_vagrant.sh vagrant@localhost:./ 
```

You will have the abitily to test the script.

## TODO

* Would be perfect to mount a external file system inside the kitchen instance
* More OS support


## License and Authors

Author:: Jorge Moratilla (<jorge.moratilla@bq.com>)
