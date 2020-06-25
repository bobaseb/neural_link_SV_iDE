import sys
import pandas as pd
import numpy as np
from numpy.polynomial.polynomial import polyfit
import matplotlib.pyplot as plt
import mvpa2.suite as mvpa2
from scipy import stats

def var_corrs(x, y, msk_list):
    for msk_i in msk_list:
        ds1 =  mvpa2.fmri_dataset(x, mask=msk_i)
        ds2 =  mvpa2.fmri_dataset(y, mask=msk_i)
        print(msk_i)
        print(stats.spearmanr(ds1.samples.T, ds2.samples.T, nan_policy='omit'))
        print(stats.pearsonr(ds1.samples.T, ds2.samples.T))

def corr_eval(corrs):
    mn_corr = np.mean(corrs)
    std_corr = np.std(corrs)
    print(mn_corr, std_corr)
    print(stats.ttest_1samp(corrs,0))


#model is 1_5subval_entropy

pwd = '/home/seb/Dropbox/postdoc/NARPS/review_preprint1/fmri'

which_msks = '/narps_masks' #'/narps_masks_1mm'

raccumbens = pwd + which_msks + '/Right_Accumbens.nii.gz'
ramygdala = pwd + which_msks + '/Right_Amygdala.nii.gz'
laccumbens = pwd + which_msks + '/Left_Accumbens.nii.gz'
lamygdala = pwd + which_msks + '/Left_Amygdala.nii.gz'
fmc = pwd + which_msks + '/Frontal_Medial_Cortex.nii.gz'

entropy_Zs = pwd + '/entropies_z.nii.gz'
subval_Zs = pwd + '/subval_z.nii.gz'

entropy_Zs3 = pwd + '/entropy_zstats_level3.nii.gz'
subval_Zs3 = pwd + '/subval_zstats_level3.nii.gz'

entropy_ts3 = pwd + '/entropy_tstats_level3.nii.gz'
subval_ts3 = pwd + '/subval_tstats_level3.nii.gz'

entropy_betas = pwd + '/entropy_betas.nii.gz'
subval_betas = pwd + '/subval_betas.nii.gz'

entropy_varcopes = pwd + '/entropy_varcopes.nii.gz'
subval_varcopes = pwd + '/subval_varcopes.nii.gz'

subval_split_posB = pwd + '/narps1-5_subval_split/narps_level3/SubValPosAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'
subval_split_negB = pwd + '/narps1-5_subval_split/narps_level3/SubValNegAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'
subval_split_entropyB = pwd + '/narps1-5_subval_split/narps_level3/EntropyAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'

subval_split_posZ = pwd + '/narps1-5_subval_split/narps_level3/SubValPosAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
subval_split_negZ = pwd + '/narps1-5_subval_split/narps_level3/SubValNegAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
subval_split_entropyZ = pwd + '/narps1-5_subval_split/narps_level3/EntropyAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'

#msk = pwd + '/intercept_msk.nii.gz'
#msk = None
msk = fmc# laccumbens# ramygdala# lamygdala # raccumbens#
#msk_list = [pwd + '/intercept_msk.nii.gz', fmc, laccumbens, ramygdala, lamygdala, raccumbens]
msk_list = [None]

var_corrs(subval_split_entropyB, subval_split_posB, msk_list)
var_corrs(subval_split_entropyB, subval_split_negB, msk_list)

var_corrs(subval_split_entropyZ, subval_split_posZ, msk_list)
var_corrs(subval_split_entropyZ, subval_split_negZ, msk_list)

#var_corrs(entropy_Zs3, subval_Zs3, msk_list)
#var_corrs(entropy_ts3, subval_ts3, msk_list)
