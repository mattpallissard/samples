"""
tag: extract, distinct, binomial coefficient
"""

def extract(f, n, l):
    if n <=0:
        return [[]]
    if l == []:
        return []
    def with_h():
        h, *t = l
        return list(map(lambda lp: [h]+lp, extract("w/ ", n-1, t)))
    def without_h():
        return extract("w/o", n,l[1:])

    return with_h() + without_h()
print(extract("orig", 3,['a', 'b', 'c', 'd']))
