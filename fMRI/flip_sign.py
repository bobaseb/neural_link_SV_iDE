source /etc/profile.d/modules.sh
module unload compilers
module load compilers/gnu/4.9.2
module load swig/3.0.7/gnu-4.9.2
module load python2/recommended
python

import mvpa2.suite as mvpa2
import numpy as np
import os

def make_neurimg(parent_ds,child_ds):
    parent_ds.samples = child_ds
    print(parent_ds.shape)
    nimg = mvpa2.map2nifti(parent_ds)
    return nimg

pwd = '/scratch/scratch/ucjtbob'
model_dir = '/narps1-5_subval_entropy'
level = '/narps_level2'
msk = pwd + model_dir + '/narps_level3/interceptAllSubs.gfeat/cope1.feat/intercept_msk.nii.gz'

cope_num = 3 #1 intercept, 2 sv, 3 de

work_dir = pwd + model_dir + level
fldrs = os.listdir(work_dir)
fldrs.sort()

for fldr in fldrs:
    print(fldr)
    sub_fldr = work_dir + '/' + fldr
    z_stat1 = sub_fldr + '/cope' + str(cope_num) + '.feat/stats/zstat1.nii.gz' #cope3.feat is for entropy
    ds_tmp = mvpa2.fmri_dataset(z_stat1)
    ds_tmp.samples = ds_tmp.samples*-1
    nimg = mvpa2.map2nifti(ds_tmp)
    nimg.to_filename(sub_fldr + '/cope' + str(cope_num) + '.feat/stats/zstat2.nii.gz')

#compute which var wins w.r.t. absolute value
mn_dir = '/second_level_diffs/signed_diffs/flip_DE_sign' #'/second_level_diffs/signed_diffs/zstat1s' #
entropies = pwd + model_dir + mn_dir + '/entropies_z.nii.gz'
subvals = pwd + model_dir + mn_dir + '/subval_z.nii.gz'

ds_DE = mvpa2.fmri_dataset(entropies)
ds_SV = mvpa2.fmri_dataset(subvals)

ds_DE_mn = np.mean(ds_DE.samples,axis=0)
ds_SV_mn = np.mean(ds_SV.samples,axis=0)

DE_msk = np.abs(ds_DE_mn)>np.abs(ds_SV_mn)
SV_msk = np.abs(ds_DE_mn)<np.abs(ds_SV_mn)

nimg_SV = make_neurimg(ds_SV,SV_msk)
nimg_SV.to_filename(pwd + model_dir + mn_dir + '/subval_z_abs_bigger_msk.nii.gz')
nimg_DE = make_neurimg(ds_DE,DE_msk)
nimg_DE.to_filename(pwd + model_dir + mn_dir + '/entropies_z_abs_bigger_msk.nii.gz')
