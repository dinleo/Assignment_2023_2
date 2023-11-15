import random

a = [0 for _ in range(10000)]

for n in range(10000):
    for i in range(len(a)):
        a[i] += (2*random.randint(0,1) - 1)

    if(n % 100 == 0):
        print(n)
print(sum(a)/10000)