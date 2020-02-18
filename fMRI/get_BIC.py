import sys
#import pandas as pd
import numpy as np
import mvpa2.suite as mvpa2

fn = sys.argv[1] + 'res4d.nii.gz'
#fn = '/scratch/scratch/ucjtbob/narps1_only_entropy_model/narps_level1/sub001_run01.feat/stats/res4d.nii.gz'
#k = 11
print(fn)

ds = mvpa2.fmri_dataset(fn)

RSS = np.sum(np.power(ds.samples,2),axis=0)

k = int(sys.argv[2])
print(k, " PEs")

n = ds.shape[0]
print(n, " data points")

#this was to verify with sigmasquareds.nii.gz
#fn2 = '/scratch/scratch/ucjtbob/narps1_only_entropy_model/narps_level1/sub001_run01.feat/stats/sigmasquareds.nii.gz'
#ds2 = mvpa2.fmri_dataset(fn2)
#RSS2 = ds2.samples * (n-k)

BIC = k*np.log(n) + n*np.log(RSS/n)
BIC[~np.isfinite(BIC)] = 0
print(np.sum(BIC),' BIC')
print(BIC.shape)

ds.samples = BIC
print(ds.shape)
#print(ds)

nimg = mvpa2.map2nifti(ds)
nimg.to_filename(sys.argv[1] + 'BIC.nii.gz')
#nimg.to_filename(fn + 'BIC.nii.gz')
