import sys
#import pandas as pd
import numpy as np
import mvpa2.suite as mvpa2

fn1 = '/scratch/scratch/ucjtbob/narps1_only_subval_model/BIC_level2/BIC_medians.nii.gz'
fn2 = '/scratch/scratch/ucjtbob/narps1_only_entropy_model/BIC_level2/BIC_medians.nii.gz'
fn3 = '/scratch/scratch/ucjtbob/narps1_subval_entropy/BIC_level2/BIC_medians.nii.gz'

#fn_BIC_diff = '/scratch/scratch/ucjtbob//BIC_diffs_results/subval_minus_entropy_means.nii.gz_T.nii.gz_tfce_corrp_tstat1.nii.gz'
#ds_diff = mvpa2.fmri_dataset(fn_BIC_diff)

accumbens = '/scratch/scratch/ucjtbob/narps_masks/Accumbens_narps.nii.gz'
amygdala = '/scratch/scratch/ucjtbob/narps_masks/Amygdala_narps.nii.gz'
fmc = '/scratch/scratch/ucjtbob/narps_masks/Frontal_Medial_Cortex_narps.nii.gz'

msk = None

ds1 = mvpa2.fmri_dataset(fn1, mask=msk)
ds2 = mvpa2.fmri_dataset(fn2, mask=msk)
ds3 = mvpa2.fmri_dataset(fn3, mask=msk)

ds1 = mvpa2.remove_invariant_features(ds1)
ds2 = mvpa2.remove_invariant_features(ds2)
ds3 = mvpa2.remove_invariant_features(ds3)

bic_sums = [np.sum(ds1.samples),np.sum(ds2.samples),np.sum(ds3.samples)]
np.argsort(bic_sums)

bic_means = [np.mean(ds1.samples),np.mean(ds2.samples),np.mean(ds3.samples)]
np.argsort(bic_means)

#bic_means[0]/bic_means[1]
#bic_means

bic_mins = [np.min(ds1.samples),np.min(ds2.samples),np.min(ds3.samples)]
bic_medians = [np.median(ds1.samples),np.median(ds2.samples),np.median(ds3.samples)]

bic_medians[0]/bic_medians[1]
bic_medians
