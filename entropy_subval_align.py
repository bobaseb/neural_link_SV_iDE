import sys
#import pandas as pd
import numpy as np
import mvpa2.suite as mvpa2
from scipy import stats

pwd = '/scratch/scratch/ucjtbob'

#fn1 = '/scratch/scratch/ucjtbob/narps1_only_subval_model/BIC_level2/BIC_medians.nii.gz'
#fn2 = '/scratch/scratch/ucjtbob/narps1_only_entropy_model/BIC_level2/BIC_medians.nii.gz'
#fn3 = '/scratch/scratch/ucjtbob/narps1_subval_entropy/BIC_level2/BIC_medians.nii.gz'
raccumbens = '/scratch/scratch/ucjtbob/narps_masks_1mm/Right_Accumbens.nii.gz'
ramygdala = '/scratch/scratch/ucjtbob/narps_masks_1mm/Right_Amygdala.nii.gz'
laccumbens = '/scratch/scratch/ucjtbob/narps_masks_1mm/Left_Accumbens.nii.gz'
lamygdala = '/scratch/scratch/ucjtbob/narps_masks_1mm/Left_Amygdala.nii.gz'
fmc = '/scratch/scratch/ucjtbob/narps_masks_1mm/Frontal_Medial_Cortex.nii.gz'

#make the intercept mask
intercept_pos = pwd + '/narps1_subval_entropy/narps_level3/interceptAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz'
intercept_neg = pwd + '/narps1_subval_entropy/narps_level3/interceptAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz'
fn1 = intercept_pos
fn2 = intercept_neg
msk = None
ds1 = mvpa2.fmri_dataset(fn1, mask=msk)
ds2 = mvpa2.fmri_dataset(fn2, mask=msk)
ds3 = ds1.samples + ds2.samples
ds3[ds3>0] = 1
ds1.samples = ds3
print(ds1.shape)
nimg = mvpa2.map2nifti(ds1)
nimg.to_filename(pwd + '/narps1_subval_entropy/narps_level3/interceptAllSubs.gfeat/cope1.feat/intercept_msk.nii.gz')


entropy_pos = pwd + '/narps1_subval_entropy/narps_level3/entropyAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz' #11
entropy_neg = pwd + '/narps1_subval_entropy/narps_level3/entropyAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz' #7
subval_pos = pwd + '/narps1_subval_entropy/narps_level3/subvalAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz' #3
subval_neg = pwd + '/narps1_subval_entropy/narps_level3/subvalAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz' #1

#entropy_pos = pwd + '/narps1_subval_entropy/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
#entropy_neg = pwd + '/narps1_subval_entropy/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz'
#subval_pos = pwd + '/narps1_subval_entropy/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
#subval_neg = pwd + '/narps1_subval_entropy/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz'

#entropy_pos = pwd + '/narps1_subval_entropy/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'
#subval_pos = pwd + '/narps1_subval_entropy/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'

#msk = pwd + '/narps1_subval_entropy/narps_level3/interceptAllSubs.gfeat/cope1.feat/intercept_msk.nii.gz'
msk = lamygdala
ds_entropy_pos = mvpa2.fmri_dataset(entropy_pos, mask=msk)
ds_entropy_neg = mvpa2.fmri_dataset(entropy_neg, mask=msk)
ds_subval_pos = mvpa2.fmri_dataset(subval_pos, mask=msk)
ds_subval_neg = mvpa2.fmri_dataset(subval_neg, mask=msk)

#ds_entropy = ds_entropy_neg.samples + ds_entropy_pos.samples
#ds_subval = ds_subval_neg.samples + ds_subval_pos.samples
#stats.pearsonr(ds_entropy[0],ds_subval[0])

ds_entropy_pos.samples[ds_entropy_pos.samples>0] = 11
ds_entropy_neg.samples[ds_entropy_neg.samples>0] = 7
ds_subval_pos.samples[ds_subval_pos.samples>0] = 3
ds_subval_neg.samples[ds_subval_neg.samples>0] = 1
ds_all = ds_entropy_pos.samples + ds_entropy_neg.samples + ds_subval_pos.samples + ds_subval_neg.samples

twobytwo=[]
#8 both neg, 10 entropy neg & subval pos, 12 entropy pos & subval neg, 14 both pos
for i in [8,10,12,14]:#np.unique(ds_all):
    freq = np.sum(ds_all==i)
    print(i, freq)
    twobytwo.append(freq)

twobytwo = twobytwo/np.sum(twobytwo)
print(twobytwo)

#np.histogram(ds_all, bins=[0,1,3,7,8,10,11,12,14,100])

stats.pearsonr(ds_entropy_pos.samples[0],ds_subval_pos.samples[0])
stats.pearsonr(ds_entropy_neg.samples[0],ds_subval_neg.samples[0])

#stats.pearsonr(ds_entropy_pos.samples[0],ds_subval_neg.samples[0])
