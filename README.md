# 16sPIP
16sPIP: A Comprehensive Analysis Pipeline for Rapid Pathogen Detection in Clinical Samples Based on 16S Metagenomic Sequencing

#Version 0.1.1
#July2017

Introduction

16sPIP  was  developed  for  rapid  pathogen  detection  in  clinical  samples  based  on  16S metagenomic sequencing. 16sPIP is a comprehensive analysis pipeline with multiple integrated parts for the conversion of the data format, quality control, sequence filtering, rapid alignment, generation of the report, and other processes. It was designed with two analysis modes (i.e., the fast and sensitive mode) to enable usage under different working environments.
For  the  most  up  to  date  version  of  the  16sPIPsource  code,  go  to  this  website: https://github.com/jjmiao1314/16sPIP.git.
16sPIP has been tested on Ubuntu 14.04. It willlikely function properly on other Linux distributions, but this has not been tested.

Installation

This version could be only installed inLinux system. If you already installed these programs, you could skip to the next step. 
The steps to install 16sPIP on a machine are as follows:
(1)git clonehttps://github.com/jjmiao1314/16sPIP.git
(2)cd 16sPIP
(3)cd bin
(4)chmod 755 *
(5)sudo bash installer.sh
(6)cd ../db
(7)tar -zvxf 16S-completeBlastdb.tar.gz
   tar -zvxf pathogensDB.tar.gz
   unzip 16S-completeBwadb1.zip 16S-completeBwadb2.zip 16S-completeBwadb3.zip

Usage

<1> If the user wants to quickly screen 346 pathogens associated with human health:
  bash 16sPIP.sh -i <forward> -r <reverse>  
<2>If users want to identity the existence of other species as well as to study the population diversity of microbiome:
  bash 16sPIP.sh -i <forward> -r <reverse> -f fastq-p <reference_path> -m sensitive -t 8  
<3>If the sample is single-ended sequencing or double-ended sequencing hasbeen merged:
  bash 16sPIP.sh -i <seq>-f <fastq|fasta>  
<4>If the user wants to skip quality control:
  bash 16sPIP.sh -i <forward> -r <reverse> -s step2  
Note:You can use the following command to view more parameter usage information:
  bash 16sPIP.sh-h
