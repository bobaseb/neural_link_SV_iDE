import numpy as np
import pandas as pd
import statsmodels.formula.api as sm
from statsmodels.tools.eval_measures import bic
import time
from scipy.stats import pearsonr

parent_dir = '/media/seb/HD_Numba_Juan/Dropbox/postdoc/NARPS/preprint1'
data_fn = parent_dir + '/participants_and_model.csv'

df = pd.read_csv(data_fn)
#list(df.columns.values)

#Check if the p_accept aligns with 4 levels of DV
DV_4levels_all = df[['participant_response','p_accept']]
DV_4levels_all_mn = DV_4levels_all.groupby(['participant_response']).mean()['p_accept']
DV_4levels_all_std = DV_4levels_all.groupby(['participant_response']).std()['p_accept']
DV_4levels_all_ranks = np.argsort(np.argsort(DV_4levels_all_mn.values)) #==[3,0,2,1]

DV_4levels_per_sub_mn = df.groupby(['participant_response','ID']).mean()['p_accept'].unstack(level=0)
DV_4levels_per_sub_mn = DV_4levels_per_sub_mn.drop([13,25,30,56])

bic_score_full = 0
bic_score_intercept = 0
bic_score_gain = 0
bic_score_loss = 0
num_subs = 0
good_ranks = 0
all_coefs = []
bic_all = []
bic_ranks = []
bad_subs_full_model = []
bad_bic_full_model = []
bad_rank_subs = []
bad_ranks = []
bad_probs = []
for sub in np.unique(df.ID):
    if sub == 13 or sub == 25 or sub==30 or sub==56:
        print('sub: ', sub, 'excluded')
        continue
    sub_df = df[df.ID==sub]
    #Check if the p_accept aligns with 4 levels of DV
    DV_vals = DV_4levels_per_sub_mn.loc[sub].values
    nan_idx = np.where(np.isnan(DV_vals))[0]
    DV_vals2 = [x for x in DV_vals if str(x) != 'nan']
    DV_4levels_sub_ranks = np.argsort(np.argsort(DV_vals2))
    DV_4levels_all_ranks2 = np.argsort(np.argsort(np.delete(DV_4levels_all_mn.values, nan_idx)))
    num_subs += 1
    if (DV_4levels_sub_ranks==DV_4levels_all_ranks2).all():
        good_ranks += 1
    else:
        bad_rank_subs.append(sub)
        bad_ranks.append(DV_4levels_sub_ranks)
        bad_probs.append(DV_vals2)
    #Run the logistic regressions
    X = sub_df[['gain','loss']]
    X['intercept'] = 1.0
    y = sub_df.accept
    #Run the full model
    model_full = sm.Logit(y, X, missing='drop')
    result_full = model_full.fit()
    #result.summary()
    coefficients_full = np.array(result_full.params)
    all_coefs.append(coefficients_full)
    bic_score_full += bic(result_full.llf,len(y),len(coefficients_full))
    #Run the intercept only
    model_intercept = sm.Logit(y, X['intercept'], missing='drop')
    result_intercept = model_intercept.fit()
    bic_score_intercept += bic(result_intercept.llf,len(y),1)
    #Run intercept & gain
    model_gain = sm.Logit(y, X[['gain', 'intercept']], missing='drop')
    result_gain = model_gain.fit()
    bic_score_gain += bic(result_gain.llf,len(y),2)
    #Run intercept & loss
    model_loss = sm.Logit(y, X[['loss', 'intercept']], missing='drop')
    result_loss = model_loss.fit()
    bic_score_loss += bic(result_loss.llf,len(y),2)
    bic_per_sub = [bic(result_full.llf,len(y),len(coefficients_full)), bic(result_intercept.llf,len(y),1),
    bic(result_gain.llf,len(y),2), bic(result_loss.llf,len(y),2)]
    bic_all.append(bic_per_sub)
    bic_ranks.append(np.argmin(bic_per_sub))
    if np.argmin(bic_per_sub)!=0: #0th index is the full model
        bad_subs_full_model.append(sub)
        bad_bic_full_model.append(bic_per_sub)

print('proportion of good ranks: ', good_ranks/float(num_subs)) #just 2 subs have strongly rejected inverted with weakly rejected

print('full, gain, loss, intercept')
print(bic_score_full, bic_score_gain, bic_score_loss, bic_score_intercept)
#full model wins for everyone

print('correlation between loss and gains coefficients:')
print(pearsonr(all_coefs[:,0], all_coefs[:,1]))

print('DV levels of p_accept:')
print(DV_4levels_all_mn)
print(DV_4levels_all_std)

#Time for plotting

import matplotlib.pyplot as plt
import seaborn as sns

plt.rcParams["figure.figsize"] = (20,10)
offset_points=(-5, -5)
fs = 18

#fig.canvas.draw()

#Plot BICs
plt.subplot(1, 3, 1)
bic_all = np.vstack(bic_all)
bic_all2 = np.hstack([bic_all[:,1:],bic_all[:,0].reshape(len(bic_all[:,0]),1)])
#bic_labels = np.tile(['Gain & Loss','Baseline','Gain only', 'Loss only'],len(bic_all))
bic_labels = np.tile(['Baseline\n (Intercept only)','Gain', 'Loss','Full\n (Gain & Loss)'],len(bic_all2))
sns.set_palette(sns.color_palette("PuBu"))
sns.stripplot(bic_labels, bic_all2.flatten(), jitter=True)
sns.despine()
#plt.plot(bic_labels, bic_all2.flatten(), '.')
plt.xlabel('Behavioral model', fontsize=fs)
plt.ylabel('Bayesian Information Criterion\n (BIC)', fontsize=fs)
plt.annotate('a', (1, 1),xytext=offset_points,xycoords='axes fraction',textcoords='offset points',ha='right', va='top',weight="bold", fontsize=fs)

#Plot the gain/loss coefficients
plt.subplot(1, 3, 2)
all_coefs = np.vstack(all_coefs)
plt.plot(all_coefs[:,0], all_coefs[:,1], 'k.')
plt.xlabel('Gain Coefficient\n (Full model)', fontsize=fs)
plt.ylabel('Loss Coefficient\n (Full model)', fontsize=fs)
plt.annotate('b', (1, 1),xytext=offset_points,xycoords='axes fraction',textcoords='offset points',ha='right', va='top',weight="bold", fontsize=fs)

#Plot DV levels
plt.subplot(1, 3, 3)
DV_4levels_for_plot = DV_4levels_per_sub_mn.values[:,[0,2,3,1]]
#DV_labels = np.tile(['Strongly accept','Strongly reject','Weakly accept', 'Weakly reject'],len(DV_4levels_per_sub_mn.values))
DV_labels = np.tile(['Strongly\n accept', 'Weakly\n accept', 'Weakly\n reject', 'Strongly\n reject'],len(DV_4levels_per_sub_mn.values))
#sns.palplot(sns.color_palette("RdGy_r"))
sns.set_palette(sns.color_palette("RdYlGn_r"))
sns.stripplot(DV_labels, DV_4levels_for_plot.flatten(), jitter=True)
sns.despine()
#plt.plot(DV_labels, DV_4levels_for_plot.flatten(), '.')
plt.xlabel('Participant response', fontsize=fs)
plt.ylabel('Mean probability of accepting gamble\n (Full model)', fontsize=fs)
plt.annotate('c', (1, 1),xytext=offset_points,xycoords='axes fraction',textcoords='offset points',ha='right', va='top',weight="bold", fontsize=fs)

#plt.savefig(parent_dir + '/figs/behavioral_model.png', bbox_inches='tight', dpi=300)
plt.show()
