
def clique(i,n):
    nodes = ""
    links = ""
    for i in range(i,i+n):
        nodes = nodes + "NODE n{}\n".format(i)
        links = links + "LINK n{} n{}\n".format(i,i+1)
    return (nodes,links)

links = ""
nodes = ""
for x in range(0,10):
    ans = clique(x*10,10)
    nodes += ans[0]
    links += ans[1]
print(nodes)
print(links)


    


