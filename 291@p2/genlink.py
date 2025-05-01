n = 700

for i in range(0,n):
    print("NODE n{}".format(i))

for i in range(0,n-1):
    print("LINK n{} n{}".format(i,i+1))

print("LINK n{} n{}".format(n-1,0))
