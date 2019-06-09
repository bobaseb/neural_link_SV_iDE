source /etc/profile.d/modules.sh
module unload compilers
module load compilers/gnu/4.9.2
module load swig/3.0.7/gnu-4.9.2
module load python2/recommended
python

import sys
import pandas as pd
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

def compute_ratios(x_over_y,all_ratios):
    x_over_y_r=[]
    x_over_y_p=[]
    for ratio in all_ratios:
        x_over_y_r.append(stats.pearsonr(x_over_y,ratio)[0])
        x_over_y_p.append(stats.pearsonr(x_over_y,ratio)[1])
    return x_over_y_r, x_over_y_p

def contingencies(ds_all,nums):
    twobytwo=[]
    #8 both neg, 10 entropy neg & subval pos, 12 entropy pos & subval neg, 14 both pos
    for i in nums:#np.unique(ds_all):
        freq = float(np.sum(ds_all==i))
        print(i, freq)
        twobytwo.append(freq)
    twobytwo = twobytwo/np.sum(twobytwo)
    print(twobytwo)
    #no effects, SV-, SV+, DE-, DE+
    return twobytwo

def dffits(n,k):
    return 2 * np.sqrt( (k+1) / n)

on_myriad=0
if on_myriad==1:
    pwd = '/scratch/scratch/ucjtbob'
else:
    pwd = '/mnt/myriad2'
    import statsmodels.api as sm
    from statsmodels.formula.api import ols

G_L_2x2 = 1
if G_L_2x2==1:
    model_dir = '/narps_baseline_model' #'/narps0-5_gl_entropy' #
else:
    model_dir = '/narps1-5_subval_entropy' #

#fn1 = '/scratch/scratch/ucjtbob/narps1_only_subval_model/BIC_level2/BIC_medians.nii.gz'
#fn2 = '/scratch/scratch/ucjtbob/narps1_only_entropy_model/BIC_level2/BIC_medians.nii.gz'
#fn3 = '/scratch/scratch/ucjtbob/narps1_subval_entropy/BIC_level2/BIC_medians.nii.gz'
raccumbens = pwd + '/narps_masks_1mm/Right_Accumbens.nii.gz'
ramygdala = pwd + '/narps_masks_1mm/Right_Amygdala.nii.gz'
laccumbens = pwd + '/narps_masks_1mm/Left_Accumbens.nii.gz'
lamygdala = pwd + '/narps_masks_1mm/Left_Amygdala.nii.gz'
fmc = pwd + '/narps_masks_1mm/Frontal_Medial_Cortex.nii.gz'

make_intercept=0
if make_intercept==1:
    #make the intercept mask
    if G_L_2x2==1:
        intercept_pos_EqInd = pwd + model_dir + '/narps_level3/interceptEqInd.gfeat/cope1.feat/thresh_zstat1.nii.gz'
        intercept_pos_EqR = pwd + model_dir + '/narps_level3/interceptEqR.gfeat/cope1.feat/thresh_zstat1.nii.gz'
        intercept_neg_EqInd = pwd + model_dir + '/narps_level3/interceptEqInd.gfeat/cope1.feat/thresh_zstat2.nii.gz'
        intercept_neg_EqR = pwd + model_dir + '/narps_level3/interceptEqR.gfeat/cope1.feat/thresh_zstat2.nii.gz'
        fn1_EqInd = intercept_pos_EqInd
        fn1_EqR = intercept_pos_EqR
        fn2_EqInd = intercept_neg_EqInd
        fn2_EqR = intercept_neg_EqR
        msk = None
        ds1_EqInd = mvpa2.fmri_dataset(fn1_EqInd, mask=msk)
        ds1_EqR = mvpa2.fmri_dataset(fn1_EqR, mask=msk)
        ds2_EqInd = mvpa2.fmri_dataset(fn2_EqInd, mask=msk)
        ds2_EqR = mvpa2.fmri_dataset(fn2_EqR, mask=msk)
        ds3 = ds1_EqInd.samples + ds1_EqR.samples + ds2_EqInd.samples + ds2_EqR.samples
        ds3[ds3>0] = 1
        nimg = make_neurimg(ds1_EqInd,ds3)
        nimg.to_filename(pwd + model_dir + '/narps_level3/intercept_msk.nii.gz')
    else:
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

if G_L_2x2==1:
    intrcpt_msk_dir = '/narps_level3/intercept_msk.nii.gz'
else:
    intrcpt_msk_dir = '/narps_level3/interceptAllSubs.gfeat/cope1.feat/intercept_msk.nii.gz'

entropy_pos = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz' #11
entropy_neg = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz' #7
subval_pos = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/thresh_zstat1.nii.gz' #3
subval_neg = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/thresh_zstat2.nii.gz' #1

#entropy_Zs = pwd + model_dir + '/second_level_diffs/signed_diffs/zstat1s/entropies_z.nii.gz'
#subval_Zs = pwd + model_dir + '/second_level_diffs/signed_diffs/zstat1s/subval_z.nii.gz'

#gains/losses
gain_Zs = pwd + model_dir + '/second_level_diffs/signed_diffs/Gs_z.nii.gz'
loss_Zs = pwd + model_dir + '/second_level_diffs/signed_diffs/Ls_z.nii.gz'
#gain_Zs = pwd + '/narps0-5_gl_entropy' + '/second_level_diffs/signed_diffs/Gs_z.nii.gz'
#loss_Zs = pwd + '/narps0-5_gl_entropy' + '/second_level_diffs/signed_diffs/Ls_z.nii.gz'

#entropy_pos = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
#entropy_neg = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz'
#subval_pos = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz'
#subval_neg = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz'

entropy_betas = pwd + model_dir + '/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'
subval_betas = pwd + model_dir + '/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/pe1.nii.gz'

msk = pwd + model_dir + intrcpt_msk_dir
#msk = None
#msk = ramygdala
#corrfig_name = 'whole_brain_corr'

mk_plot=0
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

by_sub=1
if by_sub==0:
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
    _ = contingencies(ds_all,nums=[8,10,12,14])
    _ = contingencies(ds_all,np.unique(ds_all))
    #np.histogram(ds_all, bins=[0,1,3,7,8,10,11,12,14,100])
else:
    if G_L_2x2==1:
        ds_G_Zs = mvpa2.fmri_dataset(gain_Zs, mask=msk)
        ds_L_Zs = mvpa2.fmri_dataset(loss_Zs, mask=msk)
        conting_mode=1 #contingency mode
        if conting_mode==1:
            combos = ['Ls','Gs']#['G+', 'G-', 'L+', 'L-'] #['L+','G-','G+','both pos'] #
            now_nums = [3,11] #[1,3,7,11] #[3,7,11,14] #
            thresh_z = 2.3
            ds_G_Zmsk = np.logical_and(ds_G_Zs.samples<thresh_z,ds_G_Zs.samples>-thresh_z)
            ds_G_Zs.samples[ds_G_Zmsk] = 0
            ds_L_Zmsk = np.logical_and(ds_L_Zs.samples<thresh_z,ds_L_Zs.samples>-thresh_z)
            ds_L_Zs.samples[ds_L_Zmsk] = 0
        else:
            combos = ['both_neg', 'L+G-', 'L-G+', 'both_pos']
            now_nums = [8,10,12,14]
            thresh_z = 0
        ds_G_Zs.samples[ds_G_Zs.samples>thresh_z] = 11
        ds_G_Zs.samples[ds_G_Zs.samples<-thresh_z] = 11 #7
        ds_L_Zs.samples[ds_L_Zs.samples>thresh_z] = 3
        ds_L_Zs.samples[ds_L_Zs.samples<-thresh_z] = 3 #1
        ds_all = ds_G_Zs.samples + ds_L_Zs.samples
        ds_all = np.floor(ds_all)
    else:
        ds_entropy_Zs = mvpa2.fmri_dataset(entropy_Zs, mask=msk)
        ds_subval_Zs = mvpa2.fmri_dataset(subval_Zs, mask=msk)
        combos = ['both_neg', 'SV+DE-', 'SV-DE+', 'both_pos']
        now_nums = [8,10,12,14]
        ds_entropy_Zs.samples[ds_entropy_Zs.samples>0] = 11
        ds_entropy_Zs.samples[ds_entropy_Zs.samples<0] = 7
        ds_subval_Zs.samples[ds_subval_Zs.samples>0] = 3
        ds_subval_Zs.samples[ds_subval_Zs.samples<0] = 1
        ds_all = ds_entropy_Zs.samples + ds_subval_Zs.samples
    all_twobytwos = []
    for sub_ds in ds_all:
        all_twobytwos.append(contingencies(sub_ds,nums=now_nums))
    all_twobytwos = np.vstack(all_twobytwos)
    all_ratios_ij = []
    all_ratios_ij_combos=[]
    i=0
    for cat_i in range(all_twobytwos.shape[1]):
        j=0
        for cat_j in range(all_twobytwos.shape[1]):
            if cat_i!=cat_j:
                all_ratios_ij.append(np.array(all_twobytwos[:,cat_i]/all_twobytwos[:,cat_j]))
                all_ratios_ij_combos.append(combos[i]+'/'+combos[j])
            j+=1
        i+=1
    all_ratios_ij = np.vstack(all_ratios_ij)
    prtcpnts_n_model = pd.read_csv(pwd + model_dir + '/participants_and_model.csv')
    prtcpnts_n_model = prtcpnts_n_model[prtcpnts_n_model['ID'] != 13]
    prtcpnts_n_model = prtcpnts_n_model[prtcpnts_n_model['ID'] != 25]
    prtcpnts_n_model = prtcpnts_n_model[prtcpnts_n_model['ID'] != 30]
    prtcpnts_n_model = prtcpnts_n_model[prtcpnts_n_model['ID'] != 56]
    gain_over_loss=[]
    loss_over_gain=[]
    for sub in prtcpnts_n_model['ID'].unique():
        prtcpnts_n_model_sub = prtcpnts_n_model[prtcpnts_n_model['ID'] == sub]
        gain_over_loss.append(prtcpnts_n_model_sub['gain_coef'].unique()/prtcpnts_n_model_sub['loss_coef'].unique())
        loss_over_gain.append(prtcpnts_n_model_sub['loss_coef'].unique()/prtcpnts_n_model_sub['gain_coef'].unique())
    gain_over_loss = np.hstack(gain_over_loss)
    loss_over_gain = np.hstack(loss_over_gain)
    gain_over_loss_r_ij, gain_over_loss_p_ij = compute_ratios(gain_over_loss,all_ratios_ij)
    loss_over_gain_r_ij, loss_over_gain_p_ij = compute_ratios(loss_over_gain,all_ratios_ij)
    plt.plot(loss_over_gain,all_ratios_ij[0], '.')
    plt.xlabel('Loss aversion (behavior)', fontsize=30)
    plt.ylabel('# Loss voxels / # Gain voxels', fontsize=30)
    plt.show()
    if on_myriad==0:
        x1 = sm.add_constant(loss_over_gain)
        y1 = all_ratios_ij[0]
        rlm_model1 = sm.RLM(y1, x1, M=sm.robust.norms.HuberT())
        rlm_results1 = rlm_model1.fit()
        print(rlm_results1.summary())
        x2 = sm.add_constant(all_ratios_ij[0])
        y2 = loss_over_gain
        rlm_model2 = sm.RLM(y2, x2, M=sm.robust.norms.HuberT())
        rlm_results2 = rlm_model2.fit()
        print(rlm_results2.summary())
        dffits_thresh = dffits(len(y2),2.0)
        tmp_ds = np.vstack([x2[:,0],x2[:,1],y2]).T
        pd = pd.DataFrame(tmp_ds, columns = ['const','brain_voxel_ratio','beh_loss_aversion'])
        m1 = ols('brain_voxel_ratio ~ beh_loss_aversion',pd).fit()
        infl1 = m1.get_influence()
        sm_fr1 = infl1.summary_frame()
        outliers1 = np.where(np.abs(sm_fr1.dffits)>dffits_thresh)
        pd2 = pd.drop(outliers1[0])
        m2 = ols('brain_voxel_ratio ~ beh_loss_aversion',pd2).fit()
        print(m2.summary())
        m3 = ols('beh_loss_aversion ~ brain_voxel_ratio',pd2).fit()
        print(m3.summary())
        #x3 = sm.add_constant(pd2.brain_voxel_ratio)
        #rlm_model3 = sm.RLM(pd2.beh_loss_aversion, x3, M=sm.robust.norms.HuberT())
        #rlm_results3 = rlm_model3.fit()
        #print(rlm_results3.summary())
        #x4 = sm.add_constant(pd2.beh_loss_aversion)
        #rlm_model4 = sm.RLM(pd2.brain_voxel_ratio, x4, M=sm.robust.norms.HuberT())
        #rlm_results4 = rlm_model4.fit()
        #print(rlm_results4.summary())
        #m2 = ols('beh_loss_aversion ~ brain_voxel_ratio',pd).fit()
        #infl2 = m2.get_influence()
        #sm_fr2 = infl2.summary_frame()
        #outliers2 = np.where(np.abs(sm_fr2.dffits)>dffits_thresh)
