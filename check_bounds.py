import sys

def check(file):
    mins = [float('inf')]*3
    maxs = [float('-inf')]*3
    with open(file, 'r') as f:
        for line in f:
            if line.startswith('v '):
                parts = list(map(float, line.split()[1:4]))
                for i in range(3):
                    mins[i] = min(mins[i], parts[i])
                    maxs[i] = max(maxs[i], parts[i])
    print(f"{file} bounds: min={mins} max={maxs}")

check('models/me_alpaca_mini.obj')
check('models/notloc_alpaca.obj')
