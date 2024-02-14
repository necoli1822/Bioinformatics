import random

gen_col = lambda n: ["#%06x" % random.randint(0, 0xFFFFFF) for _ in range(n)]

get_col(23)
