#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from Bio import SeqIO
import sys

in_File = sys.argv[1]
out_FIle = sys.argv[2]

red = SeqIO.read(in_File,"fasta")
seq = '>' + red.name + '\n' + red.seq

with open(out_File,"w") as f:
    for i in seq:
        f.write(i)
    f.close()