#!/bin/bash
#
#   installer.sh
#
#   This script will install 16sPIP and its dependencies. It has been tested with Ubuntu 14.04 LTS.
#
#   quick guide:
#
#   bash installer.sh
# 
### Authors : Jiaojiao Miao <jjmiao1314@163.com>
# 
# Forked by Maxim Sikolenko <maximdeynonih@gmail.com>
#

print_help(){
    echo -e "$0 -- this script installs 16sPIP and its dependencies.\n"
    echo 'Usage:'
    echo -e "\n  bash installer.sh\n"
}



for opt in $@ ; do
    if [[ $opt == '-h' || $opt == '--help' || $opt == '-help' ]]; then
        print_help
        exit 0
    fi
done


installdir=`pwd`
echo -e "\nInstalling 16sPIP to $installdir"

main_script=${installdir}/bin/16sPIP.sh
echo "Configuring main script..."
sed -i "s|REF_PATH=TEMPORARY_STUB|REF_PATH=${installdir}|" ${main_script}

if [[ $? != 0 ]]; then
    echo "Cannot configure main script."
    echo "sed error. Aborting installation."
    exit 1
else 
    echo -e "Done\n"
fi


if [[ ! -d ${installdir}/bin || ! -d ${installdir}/db ]]; then
    echo -e "\nPlease, change your working directory to the root of folder downloaded from github."
    echo -e "I.e., your steps \e[4mbefore\e[0m running this script must be:"
    echo '  git clone https://github.com/masikol/16sPIP.git'
    echo '  cd 16sPIP'
    echo "And then you should run 'installer.sh:'"
    echo "  bash installer.sh"
    exit 1
fi

touch $installdir/test_file
if [[ $? != 0 ]]; then
    echo -e "\nSeems, you need root permissions"
    echo "Exitting..."
    exit 1
else
    rm $installdir/test_file
fi


HEXPIP_BIN="$installdir/bin"
envfile='~/.bashrc'


if [[ -z `grep "${HEXPIP_BIN}" ${envfile}` ]]; then
    echo -e "Appending ${HEXPIP_BIN} to your PATH in ${envfile}\n"
    echo -e "\n\nPATH=${PATH}:${HEXPIP_BIN}\n" >> ${envfile}
    PATH=$PATH:${HEXPIP_BIN}
fi

echo -e "Installing and updating required Ubuntu packages.\n"

## install & update Ubuntu packages
sudo apt update -y

if [[ -x `which curl` ]]; then
    apt install -y curl
fi

sudo apt install -y make
sudo apt install -y gcc
sudo apt install -y g++
sudo apt install -y g++-4.6
sudo apt install -y libidn11
sudo apt install -y build-essential
sudo apt install -y enscript
sudo apt install -y ghostscript
sudo apt install -y perl
sudo apt install -y python2
sudo apt install -y python-dev
sudo apt install -y python-pip
sudo apt install -y python-numpy
sudo apt install -y python-numpy
sudo apt install -y python-biopython
sudo apt upgrade -y

# Following programs are likely to be out of date in apt repos:
### install bwa
if [[ -z `which bwa` ]]; then
    sudo apt install -y bwa
fi

### install picard-tools
if [[ -z `which picard-tools` ]]; then
    sudo apt install -y picard-tools
fi

### install seq_crumbs
wget -c http://bioinf.comav.upv.es/downloads/seq_crumbs-0.1.9.tar.gz
tar -xzvf seq_crumbs-0.1.9.tar.gz
rm seq_crumbs-0.1.9.tar.gz
cd seq_crumbs-0.1.9
python2 setup.py install
cd $installdir
mv -v seq_crumbs-0.1.9/bin/* $HEXPIP_BIN
rm -r seq_crumbs-0.1.9

### install blast+
curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.6.0/ncbi-blast-2.6.0+-x64-linux.tar.gz --output ${installdir}/ncbi-blast-2.6.0+-x64-linux.tar.gz
tar -xzvf ncbi-blast-2.6.0+-x64-linux.tar.gz
rm ncbi-blast-2.6.0+-x64-linux.tar.gz
mv -v ncbi-blast-2.6.0+/bin/* $HEXPIP_BIN
rm -r ncbi-blast-2.6.0+

chmod u+x $HEXPIP_BIN/*

# Unpack database
cd ${installdir}/db
tar -zvxf 16S-completeBlastdb.tar.gz
tar -zvxf pathogensDB.tar.gz
unzip 16S-completeBwadb1.zip
unzip 16S-completeBwadb2.zip
unzip 16S-completeBwadb3.zip
