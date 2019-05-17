source /etc/profile.d/modules.sh
module unload compilers
module load compilers/gnu/4.9.2
module load swig/3.0.7/gnu-4.9.2
module load python2/recommended
python

import sys
#import pandas as pd
import numpy as np
from numpy.polynomial.polynomial import polyfit
import matplotlib.pyplot as plt
import mvpa2.suite as mvpa2
from scipy import stats

def make_neurimg(parent_ds,child_ds):
    parent_ds.samples = child_ds
    print(parent_ds.shape)
    nimg = mvpa2.map2nifti(parent_ds)
    return nimg

pwd = '/scratch/scratch/ucjtbob'
model_dir = '/narps1-5_subval_entropy'

#fn1 = '/scratch/scratch/ucjtbob/narps1_only_subval_model/BIC_level2/BIC_medians.nii.gz'
#fn2 = '/scratch/scratch/ucjtbob/narps1_only_entropy_model/BIC_level2/BIC_medians.nii.gz'
#fn3 = '/scratch/scratch/ucjtbob/narps1_subval_entropy/BIC_level2/BIC_medians.nii.gz'
raccumbens = '/scratch/scratch/ucjtbob/narps_masks_1mm/Right_Accumbens.nii.gz'
ramygdala = '/scratch/scratch/ucjtbob/narps_masks_1mm/Right_Amygdala.nii.gz'
laccumbens = '/scratch/scratch/ucjtbob/narps_masks_1mm/Left_Accumbens.nii.gz'
lamygdala = '/scratch/scratch/ucjtbob/narps_masks_1mm/Left_Amygdala.nii.gz'
fmc = '/scratch/scratch/ucjtbob/narps_masks_1mm/Frontal_Medial_Cortex.nii.gz'

make_intercept=0
if make_intercept==1:
    #make the intercept mask
    intercept_pos = pwd + model_dir + '/narps_level3/interceptAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz'
    intercept_neg = pwd + model_dir + '/narps_level3/interceptAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz'
    fn1 = intercept_pos
    fn2 = intercept_neg
    msk = None
    ds1 = mvpa2.fmri_dataset(fn1, mask=msk)
    ds2 = mvpa2.fmri_dataset(fn2, mask=msk)
    ds3 = ds1.samples + ds2.samples
    ds3[ds3>0] = 1
    nimg = make_neurimg(ds1,ds3)
    nimg.to_filename(pwd + model_dir + '/narps_level3/interceptAllSubs.gfeat/cope1.feat/intercept_msk.nii.gz')


entropy_pos = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz' #11
entropy_neg = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz' #7
subval_pos = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz' #3
subval_neg = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz' #1

#entropy_pos = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
#entropy_neg = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz'
#subval_pos = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
#subval_neg = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz'

entropy_betas = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'
subval_betas = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'

msk = pwd + model_dir + '/narps_level3/interceptAllSubs.gfeat/cope1.feat/intercept_msk.nii.gz'
#msk = None
#msk = ramygdala
#corrfig_name = 'whole_brain_corr'

mk_plot=1
if mk_plot==1:
    #from matplotlib.pyplot import figure
    #figure(num=None, figsize=(8, 6), dpi=80, facecolor='w', edgecolor='k')
    ds_entropy_betas =  mvpa2.fmri_dataset(entropy_betas, mask=msk)
    ds_subval_betas =  mvpa2.fmri_dataset(subval_betas, mask=msk)
    z_entropy_betas = (ds_entropy_betas.samples - np.mean(ds_entropy_betas.samples))/np.std(ds_entropy_betas.samples)
    z_subval_betas = (ds_subval_betas.samples - np.mean(ds_subval_betas.samples))/np.std(ds_subval_betas.samples)
    ds_mean_betas = (z_subval_betas - z_entropy_betas)/2
    x = z_entropy_betas[0]
    y = z_subval_betas[0]
    stats.pearsonr(x,y)
    mk_mn_betas=0
    if mk_mn_betas==1:
        nimg = make_neurimg(ds_entropy_betas,ds_mean_betas)
        nimg.to_filename(pwd + model_dir + '/narps_level3/mn_subval_entropy_betas.nii.gz')
    # Fit with polyfit
    b, m = polyfit(y, x, 1)
    plt.plot(x, y, '.')
    plt.plot(x, b + m * x, '-')
    plt.xlabel('Decision entropy', fontsize=30)
    plt.xticks(fontsize = 20)
    plt.ylabel('Subjective Value', fontsize=30)
    plt.yticks(fontsize = 20)
    plt.subplots_adjust(left=0.25, bottom=0.25)
    #plt.savefig(corrfig_name + '.png', bbox_inches='tight')
    plt.show()

ds_entropy_pos = mvpa2.fmri_dataset(entropy_pos, mask=msk)
ds_entropy_neg = mvpa2.fmri_dataset(entropy_neg, mask=msk)
ds_subval_pos = mvpa2.fmri_dataset(subval_pos, mask=msk)
ds_subval_neg = mvpa2.fmri_dataset(subval_neg, mask=msk)

stats.pearsonr(ds_subval_pos.samples[0],ds_entropy_pos.samples[0])
stats.pearsonr(ds_subval_pos.samples[0],ds_entropy_neg.samples[0])
stats.pearsonr(ds_subval_neg.samples[0],ds_entropy_neg.samples[0])
stats.pearsonr(ds_subval_neg.samples[0],ds_entropy_pos.samples[0])

#stats.pearsonr(ds_entropy_pos.samples[0],ds_subval_neg.samples[0])

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
    freq = float(np.sum(ds_all==i))
    print(i, freq)
    twobytwo.append(freq)

twobytwo = twobytwo/np.sum(twobytwo)
print(twobytwo)

#below only works if you mask for significant effects
#no effects, SV-, SV+, DE-, DE+
twobytwo=[]
for i in np.unique(ds_all):
    freq = float(np.sum(ds_all==i))
    print(i, freq)
    twobytwo.append(freq)

twobytwo = twobytwo/np.sum(twobytwo)
print(twobytwo)
print(np.unique(ds_all))
#np.histogram(ds_all, bins=[0,1,3,7,8,10,11,12,14,100])
