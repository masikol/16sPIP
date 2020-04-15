#!/bin/bash
#
#	installer.sh
#
#	This script will install 16sPIP and its dependencies. It has been tested with Ubuntu 14.04 LTS.
#
#	quick guide:
#
#	sudo bash installer.sh
# 
### Authors : Jiaojiao Miao <jjmiao1314@163.com>
# 
# Forked by Maxim Sikolenko <maximdeynonih@gmail.com>
#

if [[ $USER != root ]]; then
    echo "Please, run this script as root"
    exit 1
fi

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


exit 0


HEXPIP_BIN="$installdir/bin"


if [[ -z `grep ${HEXPIP_BIN}` ]]; then
    echo -e "Appending ${HEXPIP_BIN} to your PATH in ~/.bashrc\n"
    echo -e "\n\nPATH=${PATH}:${HEXPIP_BIN}\n" >> '~/.bashrc'
    PATH=$PATH:${HEXPIP_BIN}
fi

echo -e "Installing and updating required Ubuntu packages.\n"

## install & update Ubuntu packages
sudo apt update -y

if [[ -x `which curl` ]]; then
    apt install -y curl
fi

apt install -y make
apt install -y gcc
apt install -y g++
apt install -y g++-4.6
apt install -y libidn11
apt install -y build-essential
apt install -y enscript
apt install -y ghostscript
apt install -y perl
apt install -y python2
apt install -y python-dev
apt install -y python-pip
apt install -y python-numpy
apt install -y python-numpy
apt install -y python-biopython
apt install -y ps2pdf
apt upgrade -y

# Following programs are likely to be out of date in apt repos:
### install bwa
if [[ -z `which bwa` ]]; then
    apt install -y bwa
fi

### install picard-tools
if [[ -z `which picard-tools` ]]; then
    apt install -y picard-tools
fi

### install seq_crumbs
curl http://bioinf.comav.upv.es/downloads/seq_crumbs-0.1.9.tar.gz \
  --output seq_crumbs-0.1.9.tar.gz
tar -zvxf seq_crumbs-0.1.9.tar.gz
rm -v seq_crumbs-0.1.9.tar.gz
cd seq_crumbs-0.1.9
python2 setup.py install
cd $installdir
mv -v seq_crumbs-0.1.9/bin/* $HEXPIP_BIN
rm -rv seq_crumbs-0.1.9

### install blast+
curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.6.0/ncbi-blast-2.6.0+-x64-linux.tar.gz \
  --output ncbi-blast-2.6.0+-x64-linux.tar.gz
tar -zvxf ncbi-blast-2.6.0+-x64-linux.tar.gz
rm -v ncbi-blast-2.6.0+-x64-linux.tar.gz
mv -v ncbi-blast-2.6.0+/bin/* $HEXPIP_BIN
rm -rv ncbi-blast-2.6.0+

chmod u+x $HEXPIP_BIN/*

# Unpack database
cd ${installdir}/db
tar -zvxf 16S-completeBlastdb.tar.gz
tar -zvxf pathogensDB.tar.gz
unzip 16S-completeBwadb1.zip
unzip 16S-completeBwadb2.zip
unzip 16S-completeBwadb3.zip
