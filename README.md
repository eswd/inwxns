# Nameserver update for INWX

Shell script for updating your A and AAAA records at inwx [inwx](https://www.inwx.de/) with your current IPs.

This repo is a hork from nsupdate by Christian Busch (https://github.com/chrisb86/nsupdate.git), adapted to my needs.

Main difference:
* only A and AAAA records
* login information stored in global config
* replaced _nslookup_ with _dig_
* disable logging, if needed

## Requirements

In order to run you need to have _curl_ and _dig_ installed.

## Installation

* Get the repo. 
* Create a config file for each domain (IPv4 and IPv6) in inwxns.d/. Details see sample. Must end with .conf
* Create a globalconfig _global.conf_ with the INWX-Login. Details see global.conf.sample. 
* Change loggin and the IP-check site if you want.
* run inwxns.sh
