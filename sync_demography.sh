#!/bin/env bash

#================================================================================#
# Filename   : sync_demo.sh                         
# Author     : Pedro Taucce                                
# Created    : November 4th,2023                           
# Last edit  : November 4th,2023                           
# Purpose    : Post installation Linux script to install software to do synchronous
# demographic analyzes                                                              
# Works on   : Ubuntu 22.04 LTS
# Installs   : R 4.x with babette and PipeMaster, R 3.6.3 with bGMYC, Rstudio-server                                                                              
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
	openjdk-17-jdk
	libssl-dev
	libfontconfig1-dev
	libcurl4-openssl-dev
	libxml2-dev
	libharfbuzz-dev
	libfribidi-dev
	libfreetype6-dev
	libpng-dev
	libtiff5-dev
	libjpeg-dev
	default-jdk
	r-cran-rjava
)

URL_bGMYC="https://nreid.github.io/assets/bGMYC_1.0.2.tar.gz"
URL_POPGENOME="https://cran.r-project.org/src/contrib/Archive/PopGenome/PopGenome_2.7.5.tar.gz"
URL_R3="https://cran.r-project.org/src/base/R-3/R-3.6.3.tar.gz"
URL_RSTUDIO_SERVER="https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.09.1-494-amd64.deb"

SOFTWARE="$HOME/software"

## Removing potential package locks in apt ##
sudo rm /var/lib/dpkg/lock-frontend;
sudo rm /var/cache/apt/archives/lock;

## Add repositories

# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

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
sudo Rscript -e 'install.packages(c("ape", "phytools","paran","remotes","devtools","rJava"), repos="https://cran.rstudio.com/")'
sudo Rscript -e 'install.packages("splits", repos="http://R-Forge.R-project.org")'
sudo Rscript -e 'devtools::install_bitbucket(c("richierocks/assertive.properties","richierocks/assertive.types","richierocks/assertive.strings","richierocks/assertive.datetimes","richierocks/assertive.data","richierocks/assertive.data.uk","richierocks/assertive.data.us","richierocks/assertive.code"))'
sudo Rscript -e 'devtools::install_bitbucket("richierocks/assertive")'
sudo Rscript -e 'remotes::install_github(c("richelbilderbeek/beastier","richelbilderbeek/mauricer","richelbilderbeek/beastierinstall"))'
sudo Rscript -e 'remotes::install_github("ropensci/babette")'
sudo Rscript -e 'beastierinstall::install_beast2()'


# Install from downloaded files
mkdir $SOFTWARE
mkdir $HOME/R3

wget -c "$URL_R3" -P "$SOFTWARE"
wget -c "$URL_bGMYC" -P "$SOFTWARE"
wget -c "$URL_POPGENOME" -P "$SOFTWARE"
wget -c "$URL_RSTUDIO_SERVER" -P "$SOFTWARE"

cd $SOFTWARE
tar -xvzf R-3.6.3.tar.gz
cd $SOFTWARE/R-3.6.3
./configure --prefix=$HOME/R3
make
sudo make install
cd ~
$HOME/R3/Rscript -e 'install.packages("ape", repos="https://cran.rstudio.com/")'
$HOME/R3/bin/R CMD INSTALL $SOFTWARE/bGMYC_1.0.2.tar.gz

# Install PipeMaster

sudo Rscript -e 'install.packages(c("abc","e1071","phyclust","ff","msm","ggplot2","foreach"),
               repos="http://cran.us.r-project.org")'
sudo R CMD INSTALL $SOFTWARE/PopGenome_2.7.5.tar.gz
sudo Rscript -e 'devtools::install_github("gehara/PipeMaster")' 

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
