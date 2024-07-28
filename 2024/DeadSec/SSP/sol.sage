from pwn import *
load(flatter.sage)
def solve(arr,s):
    M = identity_matrix(QQ, len(arr))
    M = M.augment(vector(arr))
    M = M.stack(vector([-1/2 for _ in range(len(arr))] + [-s]))
    try:
        M1= flatter(M)
        row = M1[0][:-1]
        ans=[]
        for cnt,i in enumerate(row):
            if i==1:
                ans.append(cnt)
        return ans
    except:
        M1 = M.LLL()
        for row in M.LLL():
         for row in (row, -row):
            if row[-1] == 0:
                subset = [i for i, x in enumerate(row[:-1]) if x+1/2==1]
                return subset
r = remote("35.224.11.111",32054)
r.sendline("0")
r.recv()
r.recvline()
for i in range(99):
 arr=r.recvuntil(b"\n")[:-1].decode()
 arr = arr.split(" ")
 arr = [int(i) for i in arr]
 s= arr[-1]
 arr = arr[:-1]
 ans=solve(arr,s)
 a1=str(ans)[1:-1].replace(','," ")
 r.sendline(a1)
r.recvline()
