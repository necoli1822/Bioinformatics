#!/usr/bin/env bash

# put password for first variable
password=$1

# please define environment variables for each package

# install prerequisites
# edit /lib/systemd/system/spice-vdagentd.service if there is an error while installing txt2man etc.
# from "ExecStartPre=/bin/rm -f /var/run/spice-vdagentd/spice-vdagent-sock" to "ExecStartPre=/bin/sh -c '/bin/rm -f /var/run/spice-vdagentd/spice-vdagent-sock ; /bin/mkdir -p /var/run/spice-vdagentd'"
# then restart spice-vdagent "sudo systemctl start spice-vdagent"
echo "${password}" | sudo -S apt-get install -y coreutils build-essential g++ cmake git-all openssl libssl-dev zlib1g-dev libbz2-dev liblzma-dev autotools-dev autoconf autoconf-archive automake autopoint gettext pkg-config txt2man libjsoncpp-dev ruby-full python-is-python3

# install miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -bf
rm Miniconda3-latest-Linux-x86_64.sh
cd miniconda3/bin/
echo "export PATH=\"$(pwd)\":\$PATH" >> ~/.bashrc
cd ../../
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
git clone https://github.com/lh3/bwa.git
cd bwa && make
cd ../

# primer3
git clone https://github.com/primer3-org/primer3.git primer3
cd primer3/src
make && make test
cd ../../

# AMRfinder
git clone https://github.com/ncbi/amr.git
cd amr
git checkout master
make
cd ../

# htslib
wget https://github.com/samtools/htslib/releases/download/1.12/htslib-1.12.tar.bz2
tar jxf htslib-1.12.tar.bz2
cd htslib-1.12/
sh configure && make
cd ../

# samtools
# Build config.h.in (this may generate a warning about AC_CONFIG_SUBDIRS - please ignore it).
wget https://github.com/samtools/samtools/releases/download/1.12/samtools-1.12.tar.bz2
tar jxf samtools-1.12.tar.bz2
rm samtools-1.12.tar.bz2
cd samtools-1.12/
autoheader
autoconf -Wno-syntax
sh configure
make
cd ../

# bedtools2
wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz
tar zxf bedtools-2.30.0.tar.gz
rm bedtools-2.30.0.tar.gz
cd bedtools2/
make
cd ../

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
wget https://github.com/axel-download-accelerator/axel/releases/download/v2.17.10/axel-2.17.10.tar.gz
tar zxvf axel-2.17.10.tar.gz
rm axel-2.17.10.tar.gz
cd axel-2.17.10
./configure && make
source ~/.bashrc
cd ../

# IGV
axel -n6 -q https://data.broadinstitute.org/igv/projects/downloads/2.9/IGV_2.9.4.zip
unzip IGV_2.9.4.zip
rm IGV_2.9.4.zip

# MAUVE
axel -n6 -q http://darlinglab.org/mauve/snapshots/2015/2015-02-13/linux-x64/mauve_linux_snapshot_2015-02-13.tar.gz
tar zxf mauve_linux_snapshot_2015-02-13.tar.gz
rm mauve_linux_snapshot_2015-02-13.tar.gz

# BLAST+
axel -n6 -q https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.11.0+-x64-linux.tar.gz
tar zxf ncbi-blast-2.11.0+-x64-linux.tar.gz
rm ncbi-blast-2.11.0+-x64-linux.tar.gz

# SRA toolkit
axel -n6 -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.11.0/sratoolkit.2.11.0-ubuntu64.tar.gz
tar zxf sratoolkit.2.11.0-ubuntu64.tar.gz
rm sratoolkit.2.11.0-ubuntu64.tar.gz

# hmmer
axel -n6 -q http://eddylab.org/software/hmmer/hmmer.tar.gz
tar zxf hmmer.tar.gz
rm hmmer.tar.gz
cd hmmer-3.3.2
sh configure
make && make check
cd ../

# fastQC
# download link of fastQC temporalily too slow
# axel -n6 -q "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip"
# unzip fastqc_v0.11.9.zip
# rm fastqc_v0.11.9.zip
# rather recommend fastp
wget  http://opengene.org/fastp/fastp
echo "${password}" | sudo -S chmod a+x ./fastp

# mafft
axel -n6 -q https://mafft.cbrc.jp/alignment/software/mafft_7.475-1_amd64.deb
sudo dpkg -i mafft_7.475-1_amd64.deb
rm mafft_7.475-1_amd64.deb

# BLAST ring image generator
axel -n6 -q https://downloads.sourceforge.net/project/brig/BRIG-0.95-dist.zip
unzip BRIG-0.95-dist.zip
rm BRIG-0.95-dist.zip

# SPAdes
axel -n6 -q https://cab.spbu.ru/files/release3.15.2/SPAdes-3.15.2-Linux.tar.gz
tar zxf SPAdes-3.15.2-Linux.tar.gz
rm SPAdes-3.15.2-Linux.tar.gz

# QIIME2
# after activation of qiime2 environment (conda activate qiime2-2021.2), confirm installation with "qiime --help"
wget https://data.qiime2.org/distro/core/qiime2-2021.2-py36-linux-conda.yml
conda env create -n qiime2-2021.2 --file qiime2-2021.2-py36-linux-conda.yml
rm qiime2-2021.2-py36-linux-conda.yml

# STAR
axel -n6 -q https://github.com/alexdobin/STAR/archive/2.7.8a.tar.gz
tar zxf STAR-2.7.8a.tar.gz
rm STAR-2.7.8a.tar.gz

# HISAT2
axel -n6 -q https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download
unzip download
rm downlaod

# RSEM
# need to be installed "after" installing Bowtie, Bowtie2, STAR, and HISAT2
axel -n6 -q https://github.com/deweylab/RSEM/archive/v1.3.3.tar.gz
tar zxf RSEM-1.3.3.tar.gz
rm RSEM-1.3.3.tar.gz
cd RSEM-1.3.3
make
cd ../

# add environment variable recursively
# need to manually confirm the versions of the tools and specify for each program
echo "# environment variable for default directory\nexport PATH=$PATH:$(find $(pwd) -type d -maxdepth 2 | paste -sd ":" -)" >> ~/.bashrc
