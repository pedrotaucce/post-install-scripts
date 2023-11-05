#!/bin/env bash

#================================================================================#
# Filename   : phylo_and_biogeo.sh                         
# Author     : Pedro Taucce                                
# Created    : November 4th,2023                           
# Last edit  : November 4th,2023                           
# Purpose    : Post installation Linux script to install
# phylogeography and biogeography software                                                                
# Works on   : Ubuntu 22.04 LTS
# Installs   : R with some phylo and biogeography packages (e.g. ape, phytools, 
# BioGeoBears, splits) Rstudio-server, BEAST 2.7.5, IQTREE 2, MrBayes 3.2.7a, 
# Beagle library, mPTP                                                                       
# Known bugs :                                                                       
#================================================================================#


# MIT License {{{
#================================================================================#
# Copyright © 2023 Pedro Taucce                                  
#                                                           
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE. 
#
#Structure based on http://github.com/Diolinux/Linux-Mint-19.x-PosInstall         
#=================================================================================#
# End license }}}

## Verifying if user has speruser privileges

if [[ $EUID -ne 0 ]]; then
  echo "This script requires superuser privileges. Execute as sudo."
  exit 1
fi

## export $HOME to be /home/'user-id', or else $HOME]=/root because of sudo

export HOME="/home/$SUDO_USER"

## Creating variables

PACKAGES_TO_INSTALL=(
	software-properties-common 
	dirmngr
	r-base
	libssl-dev
	libcurl4-openssl-dev
	libfontconfig1-dev
	libxml2-dev
	libharfbuzz-dev
	libfribidi-dev
	libfreetype6-dev
	libpng-dev
	libtiff5-dev
	libjpeg-dev
	automake
	autoconf
	pkg-config
	autoconf-archive
	mpich
	libmagick++-dev
	cmake
	build-essential
	autoconf
	automake
	libtool
	git
	openjdk-11-jdk
	libgsl0-dev 
	flex
	bison 
	autotools-dev
)

URL_BEAST="https://github.com/CompEvol/beast2/releases/download/v2.7.5/BEAST.v2.7.5.Linux.x86.tgz"
URL_IQTREE="https://github.com/iqtree/iqtree2/releases/download/v2.2.2.6/iqtree-2.2.2.6-Linux.tar.gz"
URL_RSTUDIO_SERVER="https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.09.1-494-amd64.deb"

SOFTWARE="$HOME/software"

## Removing potential package locks in apt ##
sudo rm /var/lib/dpkg/lock-frontend;
sudo rm /var/cache/apt/archives/lock;

## Add repositories

# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y

## Preventing pop-up messages

sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf

## Update and Upgrade system
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade

## Install packages and software

# Install Ubuntu packages, including R 4.x and java

for package_name in ${PACKAGES_TO_INSTALL[@]}; do
  if ! dpkg -l | grep -q $package_name; then # Só instala se já não estiver instalado
    sudo apt install "$package_name" -y
  else
    echo "[INSTALLED] - $package_name"
  fi
done

# Install R packages

sudo Rscript -e 'install.packages(c("ape", "phytools","paran","devtools","rexpokit","cladoRcpp"))'
sudo Rscript -e 'install.packages("splits", repos="http://R-Forge.R-project.org")'
sudo Rscript -e 'devtools::install_github(repo="nmatzke/BioGeoBEARS")'

# Download software needed

wget -c "$URL_BEAST" -P "$SOFTWARE"
wget -c "$URL_IQTREE" -P "$SOFTWARE"
wget -c "$URL_RSTUDIO_SERVER" -P "$SOFTWARE"

# Clone git repos
cd $SOFTWARE
git clone --depth=1 https://github.com/NBISweden/MrBayes.git
git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
git clone https://github.com/Pas-Kapli/mptp.git


# Install Beagle library
cd $SOFTWARE/beagle-lib
mkdir build
cd build
cmake -DBUILD_CUDA=OFF -DBUILD_OPENCL=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr/local/ ..
sudo make install

# Install MrBayes
cd $SOFTWARE/MrBayes
mkdir build
cd build
../configure --with-mpi
make
sudo make install

# Install mPTP
cd $SOFTWARE/mptp
./autogen.sh
./configure
make
sudo make install

# Install IQTREE 2

cd $SOFTWARE
tar -xvzf iqtree-2.2.2.6-Linux.tar.gz
sudo cp $SOFTWARE/iqtree-2.2.2.6-Linux/bin/iqtree2 /usr/local/bin


# Install BEAST2.7.5

cd $SOFTWARE
tar -xvzf BEAST.v2.7.5.Linux.x86.tgz
sudo cp -r $SOFTWARE/beast/* /usr/local/

# Install RStudio Server

sudo apt install gdebi-core -y
sudo gdebi $SOFTWARE/rstudio-server-2023.09.1-494-amd64.deb -n

# System updating and cleaning
sudo apt update
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt clean

# Reboot your system

sudo reboot


