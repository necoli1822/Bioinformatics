print("a = [ [1,2,3], ['4','5','6'], [ float(i) for i in range(7,10) ] ]")
a = [ [1,2,3], ["4","5","6"], [ float(i) for i in range(7,10) ] ]
print("\n",a, sep="")
b = sum(a, [])
print("\n","b = sum(a, [])",sep="") 
print("\n",b, sep="")
