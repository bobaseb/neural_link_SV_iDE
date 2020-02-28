import numpy as np
import pandas as pd
import statsmodels.formula.api as sm
from statsmodels.tools.eval_measures import bic
import time
from scipy.stats import pearsonr, ttest_rel

parent_dir = '/media/seb/HD_Numba_Juan/Dropbox/postdoc/NARPS/preprint1'
home = 1
if home==1:
    parent_dir = '/mnt/love12' + parent_dir

data_fn = parent_dir + '/participants_and_model.csv'

df = pd.read_csv(data_fn)
df.entropy = df.entropy + np.random.normal(0,0.00000001, len(df.entropy))

entropy_medians = df.groupby(['accept','ID']).median()['entropy'].unstack(level=0)
#entropy_medians = df.groupby(['ID']).median()['entropy']

def get_switch_prop(split_trials, sub_run_df):
    next_trials = split_trials + 1
    next_trials = next_trials[next_trials<=df.trial.max()] #trials shouldnt go over 64
    len_next_trials = len(next_trials)
    count_accept = 0
    for next_trial in next_trials:
        tmp_accept = sub_run_df.accept[sub_run_df.trial==next_trial]
        #print(next_high_trial, tmp_accept.iloc[0])
        if len(tmp_accept)==0 or tmp_accept.iloc[0]=='nan':
            len_next_trials -= 1
            continue
        count_accept += tmp_accept.iloc[0]
    try:
        accept_next_prop = float(count_accept)/len(next_trials)
    except:
        accept_next_prop = np.nan
    return accept_next_prop

def half_prop(accept_col = 1):
    all_highDE = []
    all_lowDE = []
    for sub in np.unique(df.ID):
        if sub == 13 or sub == 25 or sub==30 or sub==56:
            print('sub: ', sub, 'excluded')
            continue
        ind_DE = np.where(entropy_medians.index==sub)[0][0]
        median_DE = entropy_medians.iloc[ind_DE, accept_col]
        sub_df = df[df.ID==sub]
        #print(sub_df.shape, np.sum(sub_df.accept==0))
        #print(sub_df.shape)
        #break
        all_runs_high = []
        all_runs_low = []
        for run in sub_df.run.unique():
            sub_run_df = sub_df[sub_df.run==run]
            sub_run_df_response = sub_run_df[sub_run_df.accept==accept_col] #accept_col & response coding are the same, so this works
            sub_run_df_response_trials = sub_run_df_response.trial
            #sub_run_df_trials = sub_run_df.trial
            #sub_highDE_trials = sub_run_df_trials[sub_run_df.entropy>=median_DE]
            sub_highDE_response_trials = sub_run_df_response_trials[sub_run_df_response.entropy>=median_DE]
            accept_next_high = get_switch_prop(sub_highDE_response_trials, sub_run_df)
            all_runs_high.append(accept_next_high)
            #sub_lowDE_trials = sub_run_df_trials[sub_run_df.entropy<median_DE]
            sub_lowDE_response_trials = sub_run_df_response_trials[sub_run_df_response.entropy<median_DE]
            accept_next_low = get_switch_prop(sub_lowDE_response_trials, sub_run_df)
            all_runs_low.append(accept_next_low)
            #print(accept_next_high,accept_next_low)
            #break
        all_highDE.append(np.mean(all_runs_high))
        all_lowDE.append(np.mean(all_runs_low))
        #print(all_high_DE, all_low_DE)
        #break
    return np.array(all_highDE), np.array(all_lowDE)

accept_highDE, accept_lowDE = half_prop(accept_col = 1)
accept_lowConf = accept_highDE; accept_highConf = accept_lowDE #map to confidence
reject_highDE, reject_lowDE = half_prop(accept_col = 0)
reject_lowConf = reject_highDE; reject_highConf = reject_lowDE #map to confidence

ttest_rel(accept_lowConf,accept_highConf, nan_policy='omit')
print(np.nanmean(accept_lowConf), np.nanmean(accept_highConf))
print(np.nanstd(accept_lowConf), np.nanstd(accept_highConf))

ttest_rel(reject_lowConf,reject_highConf, nan_policy='omit')
print(np.nanmean(reject_lowConf), np.nanmean(reject_highConf))
print(np.nanstd(reject_lowConf), np.nanstd(reject_highConf))

final_arr = np.stack([accept_lowConf,accept_highConf,reject_lowConf,reject_highConf], axis=-1)
np.savetxt(parent_dir + '/accept_propr.csv', final_arr, delimiter=',')
