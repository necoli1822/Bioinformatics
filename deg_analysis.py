#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, sys, subprocess, re
from axel import axel # pip install axel-wrapper
from BCBio import GFF
from Bio import Entrez, SeqIO # pip install biopython
import HTSeq # pip install HTSeq
import pysam

# NCBI`s SRA Toolkit is needed. You can download from "https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit" for precompiled version.


Entrez.email = sys.argv[1]
run_acc = sys.argv[2]
ref_acc = sys.argv[3]
threads = sys.argv[4]


# will update for wget and curl support
def sra_downloader(run,threads):
    regex = re.compile('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', re.IGNORECASE)
    handle = Entrez.efetch(db="sra", id=run, rettype="xml")
    xml = handle.read().decode("utf-8")
    handle.close() 
    urls = re.findall(regex,xml)
    urls = [ i for i in urls if "<" not in i and ">" not in i ]
    link = ""
    
    def selector():
        print("\nFrom which link do you want to donwload runfile?\n")
        for i in range(len(urls)):
            print(i,urls[i])
        sel = int(input("Enter number indicated. [default is 0]: ") or "0")
        nonlocal link
        link = urls[sel]
    
    def axel_download(selected_link):
        try:
            axel(selected_link, num_connections=threads)
        except:
            print("\nUrl is not working: '{}'.\nTry different url.".format(selected_link))
        else:
            print("\nDownloaded {} from {}.".format(run,selected_link))
            os.rename(selected_link.split("/")[-1],"{}.sra".format(run))
    
    while True:
        selector()
        try:
            axel_download(link)
        except:
            print("The link you selected is not working. Try different link.")
        else:
            break


# NCBI SRA Toolkit is mendatory.
def run_to_fastq(run, threads):
    print("Transforming sra runfile {} to fastq.\n<Progress>".format(run))
    subprocess.run(['fasterq-dump', '-p', '-e', str(threads), '-S', run]) # slower when run in python


def fastp(in_fastq, out_fastq, threads):
    print("Trimming fastq files with fastp.")
    subprocess.Popen(["fastp","-i",in_fastq,"-o",out_fastq,"-w",str(threads)], shell=False)
    #os.system('fastp -i {} -o {} -w {}'.format(in_fastq, out_fastq, threads))
    #discarded using os.system


def gb_downloader(acc):
    handle = Entrez.efetch(db="nucleotide",id=acc,rettype="gb",retmode="text")
    gb = SeqIO.read(handle,"gb")
    SeqIO.write(gb, "{}.gb".format(acc), "genbank")


def fas_downloader(acc):
    handle = Entrez.efetch(db="nucleotide",id=acc,rettype="fasta",retmode="text")
    fas = SeqIO.read(handle,"fasta")
    SeqIO.write(fas, "{}.fna".format(acc), "fasta")


def gb_to_gff(in_file,out_file):
    in_handle = open(in_file)
    out_handle = open(out_file, "w")
    GFF.write(SeqIO.parse(in_handle, "genbank"), out_handle)
    in_handle.close()
    out_handle.close()
    return "{} is written.".format(out_file)


def gff_to_gtf(in_file,out_file):
    gff = []
    gtf = []
    with open(in_file,"r") as f1:
        gff = [ i for i in f1 if i[0] != "#" and i.split("\t")[2] == "CDS" ]
        for k in range(len(gff)):
            gtf.append(gff[k].split("\t")[:8] + [i for i in gff[k].split("\t")[8].split(";") if i.startswith("locus_tag")] + [i for i in gff[k].split("\t")[8].split(";") if i.startswith("protein_id")])
    mod_index = []
    for i in gtf:
        if len(i) != 10:
            mod_index.append(gtf.index(i))
    for index in mod_index:
        gtf[index].append(gtf[index][8].replace("locus_tag","protein_id"))
    with open(out_file,"w") as f2:
        for line in gtf:
            f2.write("\t".join(line[0:8]) + "\t" + line[8] + ";" + line[9] + "\n")
    f1.close()
    f2.close()


def samtools_view(in_sam, out_bam, threads):
    with open(out_bam, "wb") as f:
        f.write(pysam.view("-@", str(threads), "-S", "-b", in_sam))
    f.close()


def samtools_sort(in_bam, sort_bam, threads):
    pysam.sort("-@", str(threads), "-o", sort_bam, in_bam)


def samtools_index(sort_bam, threads):
    pysam.index("-@",str(threads),sort_bam)
    
    
def samtools_idxstats_mapped(sort_bam):
    idx = pysam.idxstats(sort_bam)
    return int(idx.strip("\n").split("\t")[2])


def count_reads(sam_file,gtf):
    counts = {}
    gtf_file = HTSeq.GFF_Reader(gtf,end_included=True)
    cds = HTSeq.GenomicArrayOfSets("auto",stranded=False)
    sam_file = HTSeq.SAM_Reader(sam_file)
    for feature in gtf_file:
        if feature.type == "CDS":
            cds[feature.iv] += feature.name
    for feature in gtf_file:
        if feature.type == "CDS":
            counts[feature.name] = 0
    for alnmt in sam_file:
        if alnmt.aligned:
            iset = None
            for iv2, step_set in cds[alnmt.iv].steps():
                if iset is None:
                    iset = step_set.copy()
                else:
                    iset.intersection_update(step_set)
            if len(iset) == 1:
                counts[list(iset)[0]] += 1
    return counts


def gtf_count(gtf):
    gtf_dict = {}
    gtf_file = open(gtf,"r")
    for l in gtf_file:
        length = int(l.strip("\n").split("\t")[4]) - int(l.strip("\n").split("\t")[3]) + 1
        gene = l.strip("\n").split("\t")[8].split(";")[0].split("=")[1]
        gtf_dict[gene] = length
    return gtf_dict
    

def rpkm_count(count_dict,length_dict,total_read):
    rpkm_dict = {}
    for gene in count_dict.keys():
        readPerGene = count_dict[gene]
        geneLen = length_dict[gene]
        rpkm = (1000000000*readPerGene/(float)(total_read))/geneLen
        rpkm_dict[gene] = rpkm
    return rpkm_dict




