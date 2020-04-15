# 16sPIP

16sPIP: A Comprehensive Analysis Pipeline for Rapid Pathogen Detection in Clinical Samples Based on 16S Metagenomic Sequencing

Version `S.1.0.b`; 2020-04-15 edition.

Forked by Maxim Sikolenko <maximdeynonih@gmail.com> at 2020-04-15 (forked version was 0.1.1).

## Introduction

16sPIP  was  developed  for  rapid  pathogen  detection  in  clinical  samples  based  on  16S metagenomic sequencing. 16sPIP is a comprehensive analysis pipeline with multiple integrated parts for the conversion of the data format, quality control, sequence filtering, rapid alignment, generation of the report, and other processes. It was designed with two analysis modes (i.e., the fast and sensitive mode) to enable usage under different working environments.

16sPIP has been tested on Ubuntu 16.04.


## Installation

### Create a Python2.X virtual environment (optional)

I recommend to create Python2 virtual environment before installing 16sPIP in order not to clutter up your system.

To do this, you should do the following:

1. Make sure that `python2` and `virtualenv` are installed.

2. Create a virtual environment:

```
virtualenv -p python2 /dir/to/install/virtualenv
```

3. Activate the environment:

```
source /dir/to/install/virtualenv/bin/activate
```

4. Then install 16sPIP (see "Install 16sPIP" section below).

5. Further, any time you use 16sPIP, you need to run `source /dir/to/install/virtualenv/bin/activate`.
   After using 16sPIP, you can deactivate the virtual environment by running this:

  ```
  deactivate
  ```

### Install 16sPIP

This version could be only installed in Linux system. If you already installed these programs, you could skip to the next step. 
The steps to install 16sPIP on a machine are as follows:

```
git clone https://github.com/masikol/16sPIP.git
cd 16sPIP
sudo bash installer.sh
```

## Dependencies

Following packages are required and **can be automatically** installed by "installer.sh":

- make
- gcc
- g++
- g++-4.6
- libidn11
- build-essential
- enscript
- ghostscript
- perl
- python2
- python-dev
- python-pip
- python-numpy
- python-numpy
- python-biopython
- ps2pdf
- curl (required just by "installer.sh")

Morever, 16sPIP depends on [bwa](https://github.com/lh3/bwa) and [picard-tools](https://github.com/broadinstitute/picard).

Note that they are likely to be out-of-date in apt repos, so I would recommend to install them from, e.g. github or anywhere else where the latest version is likely to be. However, if `bwa` and `picard-tools` are not installed and adde to PATH, "installer.sh" will install them automatically via `apt`.

But it is still not the end (!). 16sPIP also depends on [seq_crumbs](https://github.com/JoseBlanca/seq_crumbs) version 0.1.9 and [BLAST+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) version 2.6.0. "installer.sh" downloads and installs them automatically.

## Usage

You can use the following command to view help message:

```
bash 16sPIP.sh -h
```

1. To quickly screen 346 pathogens associated with human health:

```
bash 16sPIP.sh -i <forward> -r <reverse>
```
  
2. To identity the existence of other species as well as to study the population diversity of microbiome:

```
  bash 16sPIP.sh -i <forward> -r <reverse> -f fastq-p <reference_path> -m sensitive -t 8
```

3. If the sample is single-ended sequencing or double-ended sequencing hasbeen merged:

```
bash 16sPIP.sh -i <seq>-f <fastq|fasta>
```

4. To skip quality control, specigy `-s` flag:

```
bash 16sPIP.sh -i <forward> -r <reverse> -s
```

### Options

```
-h  Show this help and ignore all other switches

-i  Specify NGS file or pair-end forward reads for processing

-r  Specify pair-end reverse reads for processing

-f  Specify NGS file format (fastq/fasta/bam/sam/sff) [fastq]

-p  Specify the PATH for 16sPIP root directory

-v  Verification mode

-m  Specify the analysis mode: fast or sensitive [fast]

-t  Number of threads [1]
```