import sys
#import pandas as pd
import numpy as np
import mvpa2.suite as mvpa2

fn = sys.argv[1] + 'res4d.nii.gz'
print(fn)

ds = mvpa2.fmri_dataset(fn)

RSS = np.sum(np.power(ds.samples,2),axis=0)

k = int(sys.argv[2])
print(k, " PEs")

n = ds.shape[0]
print(n, " data points")

BIC = k*np.log(n) + n*np.log(RSS/n)
BIC[~np.isfinite(BIC)] = 0


print(np.sum(BIC),' BIC')
print(BIC.shape)

ds.samples = BIC

print(ds.shape)
print(ds)

ds.to_filename(sys.argv[1] + 'BIC.nii.gz')
