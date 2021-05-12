#!/usr/bin/env bash

# This script is an example.
# tested on Ubuntu 20.04

# variables 
password=$1
wd=$2

# please define environment variables for each package after installation

# install prerequisites
# edit /lib/systemd/system/spice-vdagentd.service if there is an error while installing txt2man etc.
# from "ExecStartPre=/bin/rm -f /var/run/spice-vdagentd/spice-vdagent-sock" to "ExecStartPre=/bin/sh -c '/bin/rm -f /var/run/spice-vdagentd/spice-vdagent-sock ; /bin/mkdir -p /var/run/spice-vdagentd'"
# then restart spice-vdagent "sudo systemctl start spice-vdagent"
echo "${password}" | sudo -S apt-get install -y coreutils build-essential g++ cmake git-all openssl libssl-dev zlib1g-dev libbz2-dev liblzma-dev autotools-dev autoconf autoconf-archive automake autopoint gettext pkg-config txt2man libjsoncpp-dev ruby-full python-is-python3

# install miniconda
wget -o ${wd}/Miniconda3-latest-Linux-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ${wd}/Miniconda3-latest-Linux-x86_64.sh -bf
rm ${wd}/Miniconda3-latest-Linux-x86_64.sh
cd ${wd}/miniconda3/bin/
echo "export PATH=\"$(pwd)\":\$PATH" >> ~/.bashrc
cd ${wd}
source ~/.bashrc

# install bioconda
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda update -y conda

# after conda installation
conda install -y -c bioconda blasr
conda install -y -c conda-forge -c bioconda -c defaults canu
conda install -y bowtie bowtie2
conda install -y kallisto

# HTSeq
pip3 install HTSeq



# clone packages and compile in order
# also need to set environment variable for each location of target package.

# bwa
git clone https://github.com/lh3/bwa.git ${wd}/bwa
cd ${wd}/bwa && make
cd ../

# primer3
git clone https://github.com/primer3-org/primer3.git ${wd}/primer3
cd ${wd}/primer3/src
make && make test
cd ${wd}

# AMRfinder
git clone https://github.com/ncbi/amr.git ${wd}/amr
cd ${wd}/amr
git checkout master
make
cd ${wd}

# htslib
wget -o ${wd}/htslib-1.12.tar.bz2 https://github.com/samtools/htslib/releases/download/1.12/htslib-1.12.tar.bz2
tar jxf ${wd}/htslib-1.12.tar.bz2
cd ${wd}/htslib-1.12/
sh configure && make
cd ${wd}

# samtools
# Build config.h.in (this may generate a warning about AC_CONFIG_SUBDIRS - please ignore it).
wget -o ${wd}/samtools-1.12.tar.bz2 https://github.com/samtools/samtools/releases/download/1.12/samtools-1.12.tar.bz2
tar jxf ${wd}/samtools-1.12.tar.bz2
rm ${wd}/samtools-1.12.tar.bz2
cd ${wd}/samtools-1.12/
autoheader
autoconf -Wno-syntax
sh configure
make
cd ${wd}

# bedtools2
wget -o ${wd}/bedtools-2.30.0.tar.gz https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz
tar zxf ${wd}/bedtools-2.30.0.tar.gz
rm ${wd}/bedtools-2.30.0.tar.gz
cd ${wd}/bedtools2/
make
cd ${wd}

# Entrez direct install script
# adjust target directory below
cd ~
/bin/bash
perl -MNet::FTP -e \
    '$ftp = new Net::FTP("ftp.ncbi.nlm.nih.gov", Passive => 1);
    $ftp->login; $ftp->binary;
    $ftp->get("/entrez/entrezdirect/edirect.tar.gz");'
gunzip -c edirect.tar.gz | tar xf -
rm edirect.tar.gz
builtin exit
export PATH=$PATH:$HOME/edirect >& /dev/null || setenv PATH "${PATH}:$HOME/edirect"
sh $HOME/edirect/setup.sh

# axel
# axel will be used with 6 connections below instead of wget
wget -o ${wd}/axel-2.17.10.tar.gz https://github.com/axel-download-accelerator/axel/releases/download/v2.17.10/axel-2.17.10.tar.gz
tar zxvf ${wd}/axel-2.17.10.tar.gz
rm ${wd}/axel-2.17.10.tar.gz
cd ${wd}/axel-2.17.10
./configure && make
source ~/.bashrc
cd ${wd}/

# IGV
axel -n6 -q -o ${wd}/IGV_2.9.4.zip https://data.broadinstitute.org/igv/projects/downloads/2.9/IGV_2.9.4.zip
unzip ${wd}/IGV_2.9.4.zip
rm ${wd}/IGV_2.9.4.zip

# MAUVE
axel -n6 -q -o ${wd}/mauve_linux_snapshot_2015-02-13.tar.gz http://darlinglab.org/mauve/snapshots/2015/2015-02-13/linux-x64/mauve_linux_snapshot_2015-02-13.tar.gz
tar zxf ${wd}/mauve_linux_snapshot_2015-02-13.tar.gz
rm ${wd}/mauve_linux_snapshot_2015-02-13.tar.gz

# BLAST+
axel -n6 -q -o ${wd}/ncbi-blast-2.11.0+-x64-linux.tar.gz https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.11.0+-x64-linux.tar.gz
tar zxf ${wd}/ncbi-blast-2.11.0+-x64-linux.tar.gz
rm ${wd}/ncbi-blast-2.11.0+-x64-linux.tar.gz

# SRA toolkit
axel -n6 -q -o ${wd}/sratoolkit.2.11.0-ubuntu64.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.11.0/sratoolkit.2.11.0-ubuntu64.tar.gz
tar zxf ${wd}/sratoolkit.2.11.0-ubuntu64.tar.gz
rm ${wd}/sratoolkit.2.11.0-ubuntu64.tar.gz

# hmmer
axel -n6 -q -o ${wd}/hmmer.tar.gz http://eddylab.org/software/hmmer/hmmer.tar.gz
tar zxf ${wd}/hmmer.tar.gz
rm ${wd}/hmmer.tar.gz
cd ${wd}/hmmer-3.3.2
sh configure
make && make check
cd ${wd}/

# fastQC
# download link of fastQC temporalily too slow
# axel -n6 -q "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip"
# unzip fastqc_v0.11.9.zip
# rm fastqc_v0.11.9.zip
# rather recommend fastp
wget -o ${wd}/fastp http://opengene.org/fastp/fastp
echo "${password}" | sudo -S chmod a+x ./fastp

# mafft
axel -n6 -q -o ${wd}/mafft_7.475-1_amd64.deb https://mafft.cbrc.jp/alignment/software/mafft_7.475-1_amd64.deb
sudo dpkg -i ${wd}/mafft_7.475-1_amd64.deb
rm ${wd}/mafft_7.475-1_amd64.deb

# BLAST ring image generator
axel -n6 -q -o ${wd}/BRIG-0.95-dist.zip https://downloads.sourceforge.net/project/brig/BRIG-0.95-dist.zip
unzip ${wd}/BRIG-0.95-dist.zip
rm ${wd}/BRIG-0.95-dist.zip

# SPAdes
axel -n6 -q -o ${wd}/SPAdes-3.15.2-Linux.tar.gz https://cab.spbu.ru/files/release3.15.2/SPAdes-3.15.2-Linux.tar.gz
tar zxf ${wd}/SPAdes-3.15.2-Linux.tar.gz
rm ${wd}/SPAdes-3.15.2-Linux.tar.gz

# QIIME2
# after activation of qiime2 environment (conda activate qiime2-2021.2), confirm installation with "qiime --help"
wget -o ${wd}/qiime2-2021.2-py36-linux-conda.yml https://data.qiime2.org/distro/core/qiime2-2021.2-py36-linux-conda.yml
conda env create -n qiime2-2021.2 --file qiime2-2021.2-py36-linux-conda.yml
rm ${wd}/qiime2-2021.2-py36-linux-conda.yml

# STAR
axel -n6 -q -o ${wd}/STAR-2.7.8a.tar.gz https://github.com/alexdobin/STAR/archive/2.7.8a.tar.gz
tar zxf ${wd}/STAR-2.7.8a.tar.gz
rm ${wd}/STAR-2.7.8a.tar.gz

# HISAT2
axel -n6 -q -o ${wd}/HISAT2 https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download
unzip ${wd}/HISAT2
rm ${wd}/HISAT2

# RSEM
# need to be installed "after" installing Bowtie, Bowtie2, STAR, and HISAT2
axel -n6 -q -o ${wd}/RSEM-1.3.3.tar.gz https://github.com/deweylab/RSEM/archive/v1.3.3.tar.gz
tar zxf ${wd}/RSEM-1.3.3.tar.gz
rm ${wd}/RSEM-1.3.3.tar.gz
cd ${wd}/RSEM-1.3.3
make
cd ${wd}

# add environment variable recursively
# need to manually confirm the versions of the tools and specify for each program
echo "# environment variable for default directory\nexport PATH=$PATH:$(find $(pwd) -type d -maxdepth 2 | paste -sd ":" -)" >> ~/.bashrc
