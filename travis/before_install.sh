#!/bin/sh

echo "yes" | sudo apt-add-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install libgeos-dev libproj-dev libgdal1 libgdal1h
sudo apt-get install postgis postgresql-9.1-postgis
sudo apt-get install libgeos++-dev
