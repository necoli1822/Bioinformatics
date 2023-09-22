from Bio import SeqIO
import sys
from pandas import DataFrame

gb = SeqIO.read(sys.argv[1],"gb")
key = int(sys.argv[2])

featureList = [ i for i in gb.features if i.type == "CDS" ]

locationSet = []

counter = len(featureList)
c = 0

while c < counter -1:
	fs = featureList[c].location.start.real
	fe = featureList[c].location.end.real
	rs = featureList[c+1].location.start.real
	re = featureList[c+1].location.end.real
	fl = featureList[c].qualifiers['locus_tag'][0]
	rl = featureList[c+1].qualifiers['locus_tag'][0]
	fst = featureList[c].strand
	rst = featureList[c+1].strand
	try:
		fg = featureList[c].qualifiers['gene'][0]
		rg = featureList[c+1].qualifiers['gene'][0]
	except:
		fg = featureList[c].qualifiers['locus_tag'][0]
		rg = featureList[c+1].qualifiers['locus_tag'][0]
	rawData = {'locus_tag':[fl,rl], 'gene':[fg,rg], 'start':[fs,rs], 'stop':[fe,re], 'strand':[fst,rst]}
	dfIndex = ['front','rear']
	df = DataFrame(rawData,index=dfIndex)
	locationSet.append(df)
	c += 1

#abs_fs = locationSet[0]['start']['front']
#abs_re = locationSet[-1]['stop']['rear']
#
#if key > abs_re or abs_fs > key:
#	print("The position is out of range.","The first CDS starts on {}.".format(abs_fs),"The last CDS ends on {}.".format(abs_re),sep="\n")
#else:
#	for l in locationSet:
#		fs = l['start']['front']
#		fe = l['stop']['front']
#		rs = l['start']['rear']
#		re = l['stop']['rear']
#		if key >= fe and rs >= key:
#			print("Position {} is intergenic.".format(key),l,sep="\n")
#		elif key >= fs and re >= key:
#			print("Position {} is in CDS.".format(key),l,sep="\n")
#		else:
#			pass


abs_fs = locationSet[0]['start']['front']
abs_re = locationSet[-1]['stop']['rear']

if key > abs_re or abs_fs > key:
	print("{},OutRange,{},{},{},{},{},{},{},{},{},{}".format(key,"","","","","","","","","",""))
else:
	for l in locationSet:
		fs = l['start']['front']
		fe = l['stop']['front']
		rs = l['start']['rear']
		re = l['stop']['rear']
		fl = l['locus_tag']['front']
		rl = l['locus_tag']['rear']
		fg = l['gene']['front']
		rg = l['gene']['rear']
		fst = l['strand']['front']
		rst = l['strand']['rear']
		if key >= fe and rs >= key:
			print("{},Intergenic,{},{},{},{},{},{},{},{},{},{}".format(key,fl,fg,fst,fs,fe,rl,rg,rst,rs,re))
		elif key >= fs and re >= key:
			print("{},CDS,{},{},{},{},{},{},{},{},{},{}".format(key,fl,fg,fst,fs,fe,rl,rg,rst,rs,re))
		else:
			pass
