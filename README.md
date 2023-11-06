# Post-Install Scripts for Evolutionary Biology Research

This repository contains post-installation scripts designed to simplify the setup of software commonly used in evolutionary biology research on [Ubuntu 22.04 LTS](https://releases.ubuntu.com/jammy/) (and potentially other compatible Linux distributions with minor modifications). These scripts are intended to automate the installation of essential tools, libraries, and packages to get you up and running quickly, specially if you are working with cloud computing and has to delete and rebuild virtual machines to save money.

## Features

Automates the installation of popular software packages used in phylogenetics, phylogeography, and biogeography research, such as:
- [BEAST2](https://github.com/CompEvol/beast2)
- [MrBayes](https://github.com/NBISweden/MrBayes)
- [IQ-TREE 2](http://www.iqtree.org)
- [R](https://www.r-project.org) and [R-Studio Server](https://posit.co/download/rstudio-server/)
- Many others

## Requirements

- [Ubuntu 22.04 LTS](https://releases.ubuntu.com/jammy/) (and potentially other compatible Linux distros).
- Internet access to download required packages and software.
- Superuser privileges (sudo).

## Scripts
- [phylo_and_biogeo.sh](https://github.com/pedrotaucce/post-install-scripts/blob/main/phylo_and_biogeo.sh) - focused on phylogenetics, species delimitation, and biogeography. Installs BEAST2, MrBayes, IQ-TREE 2, mPTP, Beagle Library (to improve phylogenetic analyses) and the last version of R with the packages SPlits (GMYC method) and BioGeoBEARS.
- [sync_demography.sh](https://github.com/pedrotaucce/post-install-scripts/blob/main/sync_demography.sh) - focused on finding and estimating synchronous demographic expansions from several species through ultrametric trees inferred in BEAST2 through R package [babette](https://github.com/ropensci/babette) and lineage delimitation in [bGMYC](https://nreid.github.io/software/). Demographic events are estimated in R package [PipeMaster](https://github.com/gehara/PipeMaster).

## Usage

### Downloading Individual Scripts

1. Choose one of the scripts above listed

2. Click on the script you want to use

3. On the script's page, click the "Download" button or right-click the "Raw" button and choose "Save Link As" to download the script to your computer

4. After downloading the script, you will have to give it permission to execute as a program. In the folder you have downloaded it, run 'chmod +x name_of_the_script.sh'. For example:
   
   ```bash
   chmod +x phylo_and_biogeo.sh
5. Then you can execute it using `sudo`. For example:

   ```bash
   sudo ./phylo_and_biogeo.sh

### Cloning the repository
1. Clone the repository to your local machine
   ```bash
   git clone https://github.com/pedrotaucce/post-install-scripts.git
2. Navigate to the repository folder
   ```bash
   cd post-install-scripts
3. Give it permission to execute as a program
   ```bash
   chmod +x name_of_the_script.sh
4. Execute script using 'sudo'
   ```bash
   sudo ./name_of_the_script.sh
## Contributing
If you'd like to contribute to this project or make improvements to the scripts, please feel free to:
- Suggest software packages to add to the existing scripts
- Suggest custom machine installations to be scripted
- Use and text the scripts and, if you find any bug, open a request here to report or e-mail me (pedrotaucce at gmail)
- Make your changes to improve the scripts and send feedback
  
## License

This repo is licensed under the MIT License. See the [LICENSE](https://github.com/pedrotaucce/post-install-scripts/blob/main/LICENSE) file for details.
