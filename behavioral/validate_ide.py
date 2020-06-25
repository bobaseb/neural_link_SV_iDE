import numpy as np
import pandas as pd
import statsmodels.api as sm
from scipy.stats import entropy
from scipy.stats import pearsonr,spearmanr
from matplotlib  import cm
from scipy import stats, optimize
from matplotlib import pyplot as plt
import os
import inspect
import dv_funcs
import time
import seaborn as sns

def write_bdm_funs(sub_df):
    sub_df = sub_df.reset_index()
    bdm_params = ['place_holder','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p']
    left_items = []
    right_items = []
    DVs = []
    for i in range(len(sub_df)):
        ind_left = sub_df['Left_Item'][i]
        ind_right = sub_df['Right_Item'][i]
        #left_items.append(bdm_params[ind_left])
        #right_items.append(bdm_params[ind_right])
        DVs.append(bdm_params[ind_right]+'-'+bdm_params[ind_left])
        #return np.array(left_items), np.array(right_items)
    with open(pwd + 'NARPS/preprint2/scripts/dv_funcs.py', 'w') as f:
        f.write("def dv_fun(params):\n")
        f.write("\ta,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p = params;\n")
        #f.write("\tprint(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p);\n")
        f.write("\tDV = [\n")
        for i in range(len(DVs)):
            item = DVs[i]
            if i==0:
                f.write("\t%s," % item)
            elif not i%10:
                f.write("\t%s,\n" % item)
            elif i==(len(DVs)-1):
                f.write("\t%s];\n" % item)
            else:
                f.write("\t%s," % item)
        #f.write("\tprint(DV);\n")
        f.write("\treturn DV")

def fit_logreg(params, choice):
    value = dv_funcs.dv_fun(params)
    #print(value)
    X = sm.add_constant(value)
    logit_mod = sm.Logit(choice, X)
    try:
        logit_res = logit_mod.fit(method='bfgs')
        return -logit_res.llf
    except:
        return 1000000000

def estim_DV(g0, choice):
    bnds = zip(np.zeros(len(g0)),np.tile(np.inf,len(g0)))
    #res = optimize.minimize(fit_logreg, g0, args=(choice), method="L-BFGS-B", bounds=bnds)
    res = optimize.minimize(fit_logreg, g0, args=(choice), method="BFGS")
    return res.x

def corr_eval(corrs):
    mn_corr = np.mean(corrs)
    std_corr = np.std(corrs)
    print(mn_corr, std_corr)
    print(stats.ttest_1samp(corrs,0))

def col_vectorize(vec):
    vec = np.array(vec)
    vec.shape = (len(vec),1)
    return vec

wfh = '1'
if wfh=='1':
    pwd = '/home/seb/Dropbox/postdoc/'
    #pwd = '/mnt/love12/media/seb/HD_Numba_Juan/Dropbox/postdoc/'
elif wfh=='0':
    pwd = '/media/seb/HD_Numba_Juan/Dropbox/postdoc/'

os.chdir(pwd + 'NARPS/preprint2/scripts/')

narps = pwd + 'NARPS/participants_and_model.csv'
bdm1 = pwd + 'Folke_De_Martino_NHB_2016_Github/data/exp1_main_data.csv'
bdm2 = pwd + 'Folke_De_Martino_NHB_2016_Github/data/exp2_main_data.csv'

#check NARPS correspondence
narps_df = pd.read_csv(narps)
narps_df['iDE'] = 1-narps_df['entropy']
subs = narps_df['ID'].unique()
labels = ['strongly_accept','strongly_reject','weakly_accept','weakly_reject']

all_mns = []
i=0
for sub in subs:
    sub_df = narps_df[narps_df['ID']==sub]
    sub_df['zSV'] = (sub_df['subjective_value'] - sub_df['subjective_value'].mean())/sub_df['subjective_value'].std()
    sub_df['EV'] = (sub_df['gain'] - sub_df['loss'])/2
    sub_df['EV_ratio'] = sub_df['gain']/sub_df['loss']
    sub_df['Risk'] = sub_df['gain'] + sub_df['loss']
    mns = sub_df[['iDE','participant_response']].groupby(['participant_response']).mean()
    if i==0:
        narps_df2 = sub_df
        i += 1
    else:
        narps_df2 = pd.concat([narps_df2,sub_df])
    if len(mns)!=4:
        mns = mns.reset_index()
        tmp_means = []
        for label in labels:
            if not np.any(mns['participant_response']==label):
                tmp_means.append(np.nan)
            else:
                tmp_means.append(mns[mns['participant_response']==label]['iDE'].values[0])
        all_mns.append(tmp_means)
    else:
        all_mns.append(mns.values.flatten())

all_mns = np.vstack(all_mns)
#tiled_labels = np.tile(labels,(len(all_mns),1))
#tiled_labels2 = tiled_labels[:,[1,3,2,0]]
labels2 = ['Strongly Reject','Weakly Reject','Weakly Accept','Strongly Accept']
all_mns2 = all_mns[:,[1,3,2,0]]

print('Strong iDE')
print(np.nanmean(all_mns2[:,[0,3]]))
print(np.nanstd(all_mns2[:,[0,3]]))

print('Weak iDE')
print(np.nanmean(all_mns2[:,[1,2]]))
print(np.nanstd(all_mns2[:,[1,2]]))

stats.ttest_ind(all_mns2[:,[0,3]].flatten(),all_mns2[:,[1,2]].flatten(), nan_policy='omit',  equal_var = False)

plot_response_conf = 0
if plot_response_conf:
    plt.figure(num=None, figsize=(20,10), dpi=100, facecolor='w', edgecolor='k')
    plt.plot(np.tile(range(4),(len(all_mns),1)),all_mns2, '.')
    plt.xticks(range(4), labels2)
    plt.xlabel('Participant response')
    plt.ylabel('Inverse decision entropy (iDE)')
    plt.show()

'''
plot_entropy = 1
if plot_entropy:
    fig = plt.figure(num=None, figsize=(20,10), dpi=100, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(121)
    ax.scatter(narps_df2['zSV'],-narps_df2['entropy'])
    ax.set_xlabel('SV')
    ax.set_ylabel('Inverse decision entropy (iDE)')
    ax2 = fig.add_subplot(122)
    ax2.plot(np.tile(range(4),(len(all_mns),1)),all_mns2-1, '.')
    plt.xticks(range(4), labels2)
    ax2.set_xlabel('Participant response')
    ax2.set_ylabel('Inverse decision entropy (iDE)')
    plt.show()
'''


plot_entropy = 0
if plot_entropy:
    fig = plt.figure(num=None, figsize=(20,10), dpi=100, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(121)
    params = {'mathtext.default': 'regular' }
    plt.rcParams.update(params)
    ax.scatter(narps_df['p_accept'],-narps_df['entropy'])
    ax.set_xlabel('$p_{accept}$')
    ax.set_ylabel('Inverse decision entropy (iDE)')
    ax2 = fig.add_subplot(122)
    ax2.plot(np.tile(range(4),(len(all_mns),1)),all_mns2-1, '.')
    plt.xticks(range(4), labels2)
    ax2.set_xlabel('Participant response')
    ax2.set_ylabel('Inverse decision entropy (iDE)')
    plt.show()

plot_entropy = 1
if plot_entropy:
    i=1
    fig = plt.figure(num=None, figsize=(20,10), dpi=100, facecolor='w', edgecolor='k')
    for sub in subs:
        if sub == 13 or sub==25 or sub==30 or sub==56:
            continue
        sub_df = narps_df2[narps_df['ID']==sub]
        plot_num_str = i #'10,11,'+str(i)
        ax = fig.add_subplot(10,11,int(plot_num_str))
        ax.scatter(sub_df['zSV'],-sub_df['entropy'])
        ax.set_xlabel('z-scored SV')
        ax.set_ylabel('iDE')
        i += 1
    plt.show()

narps_df2['EV'] = narps_df2['EV'] + np.random.normal(0,0.3,len(narps_df2['EV']))
narps_df2['Risk'] = narps_df2['Risk'] + np.random.normal(0,0.3,len(narps_df2['EV']))

choice = narps_df2['accept']
conflict= narps_df2['model_conflict']
zsv = narps_df2['zSV']
paccept = narps_df2['p_accept']
ev = narps_df2['EV']
evratio = narps_df2['EV_ratio']

#plt.scatter(zsv,paccept)
#plt.scatter(ev,conflict)
#plt.scatter(ev,choice)
#plt.hist(zsv)
#plt.hist(ev,bins=30)
#plt.hist(evratio,bins=30)
#plt.show()

#plot EV, Risk & Conflict
#narps_df3 = narps_df2[narps_df2['group']=='equalRange']
#narps_df3 = narps_df2[narps_df2['group']=='equalIndifference']
narps_df3 = narps_df2.copy()
pos_conflict = narps_df3[narps_df3['model_conflict']>0]
stats.ttest_1samp(pos_conflict['EV'],0)

indiff_point = 0
pos_conflict_pos_DV = pos_conflict[pos_conflict['EV']>indiff_point]
pos_conflict_neg_DV = pos_conflict[pos_conflict['EV']<indiff_point]
stats.ttest_ind(pos_conflict_pos_DV['EV'],np.abs(pos_conflict_neg_DV['EV']))

a_narps_df2 = narps_df3[narps_df3['accept']==0]
b_narps_df2 = narps_df3[narps_df3['accept']==1]

ev1 = a_narps_df2['EV']
risk1 = a_narps_df2['Risk']
conflict1 = a_narps_df2['model_conflict']
ev2 = b_narps_df2['EV']
risk2 = b_narps_df2['Risk']
conflict2 = b_narps_df2['model_conflict']

plot_some_scatters = 0
if plot_some_scatters:
    plt.scatter(ev1,conflict1,s=30, marker = 'o', label='reject' )
    plt.scatter(ev2,conflict2,s=30, marker = '+', label='accept' )
    plt.xlabel('EV')
    plt.ylabel('conflict')
    plt.legend(loc="upper left")
    plt.show()
    plt.scatter(ev1,risk1,s=30,c=conflict1, marker = 'o', cmap = cm.jet, label='reject' )
    plt.scatter(ev2,risk2,s=30,c=conflict2, marker = '+', cmap = cm.jet, label='accept' )
    cb = plt.colorbar()
    cb.set_label('conflict')
    plt.xlabel('EV')
    plt.ylabel('Risk')
    plt.legend(loc="upper left")
    plt.show()

#bdm experiment 1
# right-left = DV
# -1 = chose left
bdm1_df = pd.read_csv(bdm1)
subs = bdm1_df['Participant'].unique()

#estimate bdm values
bdm_init = 0
sprmns = []
prsns = []
nlls = []
bdm_sprmns = []
bdm_prsns = []
all_bdms = []
bdm_multipliers = []
x1s = []
i = 0
for sub in subs:
    sub_df = bdm1_df[bdm1_df['Participant']==sub]
    bdm_vals = []
    for item in np.sort(sub_df['Left_Item'].unique()):
        item_df = sub_df[sub_df['Left_Item']==item]
        bdm_vals.append(item_df['Left_Value'].unique()[0])
    if bdm_init:
        g0 = bdm_vals
    else:
        g0 = list(np.random.normal(10,1,16))
    choice = sub_df['Choice_minus_is_left']
    choice2 = np.array(choice.copy())
    choice = (choice + 1)/2
    write_bdm_funs(sub_df)
    dv_funcs = reload(dv_funcs)
    resx = estim_DV(g0, choice)
    all_bdms.append(resx)
    if spearmanr(bdm_vals, resx)[0]>spearmanr(bdm_vals, -resx)[0]:
        bdm_sprmns.append(spearmanr(bdm_vals, resx)[0])
        bdm_prsns.append(pearsonr(bdm_vals, resx)[0])
        bdm_multipliers.append(1)
    else:
        bdm_sprmns.append(spearmanr(bdm_vals, -resx)[0])
        bdm_prsns.append(pearsonr(bdm_vals, -resx)[0])
        bdm_multipliers.append(-1)
    value = dv_funcs.dv_fun(resx)
    conf = sub_df['Confidence']
    X = sm.add_constant(value)
    logit_mod = sm.Logit(choice, X)
    logit_res = logit_mod.fit(method='bfgs')
    x1s.append(logit_res.params['x1'])
    nlls.append(-logit_res.llf)
    subjDV = logit_res.params['const']+(logit_res.params['x1']*np.array(value))
    #print(logit_res.summary())
    #print(logit_res.prsquared, -logit_res.llf)
    preds = np.array(logit_res.predict(X))
    conflict = -(preds-0.5)*choice2
    preds.shape = (len(preds),1)
    preds2 = np.hstack([preds,1-preds])
    iDE = -entropy(preds2.transpose(), base=2)
    sprmn = spearmanr(conf,iDE)
    print(sprmn)
    sprmns.append(sprmn[0])
    prsn = pearsonr(conf,iDE)
    print(prsn)
    prsns.append(prsn[0])
    p_correct = []
    for j in range(len(preds)):
        if choice2[j]==1:
            p_correct.append(preds[j])
        elif choice2[j]==-1:
            p_correct.append(1-preds[j])
    value = col_vectorize(value); choice2 = col_vectorize(choice2)
    conf = col_vectorize(conf); conflict = col_vectorize(conflict)
    iDE = col_vectorize(iDE); subjDV = col_vectorize(subjDV)
    p_correct = col_vectorize(p_correct)
    subID = col_vectorize(sub_df['Participant'])
    trialID = col_vectorize(sub_df['trialID'])
    RT = col_vectorize(sub_df['RT'])
    SumVal = col_vectorize(sub_df['Summed_Value'])
    sub_arr = np.hstack([subID,trialID,RT,choice2,preds,value,subjDV,conflict,iDE,conf,p_correct,SumVal])
    sub_df2 = pd.DataFrame(sub_arr,columns=['ID','trial_num','RT','choice','p(choose_right_item)','DV','subjective_DV','conflict','iDE','confidence','p(correct)','sumval'])
    if i==0:
        bdm1_df2 = sub_df2
        i += 1
    else:
        bdm1_df2 = pd.concat([bdm1_df2,sub_df2])

bdm1_df2.to_csv(pwd + 'Folke_De_Martino_NHB_2016_Github/data/exp1_main_data2_estim_bdmvals.csv')

corr_eval(sprmns)
corr_eval(prsns)
corr_eval(bdm_sprmns)
corr_eval(bdm_prsns)

#use verbally reported bdms in DV (difference in value)
# right-left = DV
# -1 = chose left
bdm1_df = pd.read_csv(bdm1)
subs = bdm1_df['Participant'].unique()

sprmns2 = []
prsns2 = []
nlls2 = []
i = 0
for sub in subs:
    sub_df = bdm1_df[bdm1_df['Participant']==sub]
    choice = sub_df['Choice_minus_is_left']
    choice2 = np.array(choice.copy())
    choice = (choice + 1)/2
    value = sub_df['DV']
    conf = sub_df['Confidence']
    X = sm.add_constant(value)
    logit_mod = sm.Logit(choice, X)
    logit_res = logit_mod.fit()
    nlls2.append(-logit_res.llf)
    #print(logit_res.summary())
    print(logit_res.prsquared, -logit_res.llf)
    subjDV = logit_res.params['const']+(logit_res.params['DV']*value)
    preds = np.array(logit_res.predict(X))
    conflict = -(preds-0.5)*choice2
    preds.shape = (len(preds),1)
    preds2 = np.hstack([preds,1-preds])
    iDE = -entropy(preds2.transpose(), base=2)
    sprmn = spearmanr(conf,iDE)
    #print(sprmn)
    sprmns2.append(sprmn[0])
    prsn = pearsonr(conf,iDE)
    #print(prsn)
    prsns2.append(prsn[0])
    p_correct = []
    for j in range(len(preds)):
        if choice2[j]==1:
            p_correct.append(preds[j])
        elif choice2[j]==-1:
            p_correct.append(1-preds[j])
    value = col_vectorize(value); choice2 = col_vectorize(choice2)
    conf = col_vectorize(conf); conflict = col_vectorize(conflict)
    iDE = col_vectorize(iDE); subjDV = col_vectorize(subjDV)
    p_correct = col_vectorize(p_correct)
    subID = col_vectorize(sub_df['Participant'])
    trialID = col_vectorize(sub_df['trialID'])
    RT = col_vectorize(sub_df['RT'])
    SumVal = col_vectorize(sub_df['Summed_Value'])
    sub_arr = np.hstack([subID,trialID,RT,choice2,preds,value,subjDV,conflict,iDE,conf,p_correct,SumVal])
    sub_df2 = pd.DataFrame(sub_arr,columns=['ID','trial_num','RT','choice','p(choose_right_item)','DV','subjective_DV','conflict','iDE','confidence','p(correct)','Summed_Value'])
    if i==0:
        bdm1_df2 = sub_df2
        i += 1
    else:
        bdm1_df2 = pd.concat([bdm1_df2,sub_df2])

bdm1_df2.to_csv(pwd + 'Folke_De_Martino_NHB_2016_Github/data/exp1_main_data2.csv')

pchoose = bdm1_df2['p(choose_right_item)']
choice = bdm1_df2['choice']
dv = bdm1_df2['DV']
conflict = bdm1_df2['conflict']

plt.scatter(dv,pchoose)
#plt.scatter(dv,conflict)
#plt.scatter(dv,choice)
plt.hist(dv)
plt.show()

pos_conflict = bdm1_df2[bdm1_df2['conflict']>0]
stats.ttest_1samp(pos_conflict['DV'],0)

pos_conflict_pos_DV = pos_conflict[pos_conflict['DV']>0]
pos_conflict_neg_DV = pos_conflict[pos_conflict['DV']<0]
stats.ttest_ind(pos_conflict_pos_DV['DV'],np.abs(pos_conflict_neg_DV['DV']))

#plot DV, Summed Value & Conflict
a_bdm1_df2 = bdm1_df2[bdm1_df2['choice']<0]
b_bdm1_df2 = bdm1_df2[bdm1_df2['choice']>0]

x1 = a_bdm1_df2['DV']
y1 = a_bdm1_df2['Summed_Value']
z1 = a_bdm1_df2['conflict']
x2 = b_bdm1_df2['DV']
y2 = b_bdm1_df2['Summed_Value']
z2 = b_bdm1_df2['conflict']

plt.scatter(x1,z1,s=30, marker = 'o', label='chose left' )
plt.scatter(x2,z2,s=30, marker = '+', label='chose right' )
plt.xlabel('difference in value (right item minus left item)')
plt.ylabel('conflict')
plt.legend(loc="upper left")
plt.show()

plt.scatter(x1,y1,s=30,c=z1, marker = 'o', cmap = cm.jet, label='chose left' )
plt.scatter(x2,y2,s=30,c=z2, marker = '+', cmap = cm.jet, label='chose right' )
cb = plt.colorbar()
cb.set_label('conflict')
plt.xlabel('difference in value (right item minus left item)')
plt.ylabel('summed value')
plt.legend(loc="upper left")
plt.show()

def histplot(x,y):
    plt.hist2d(x, y, bins=30, cmap='Blues')
    cb = plt.colorbar()
    cb.set_label('counts in bin')
    plt.show()

corr_eval(sprmns2)
corr_eval(prsns2)

print(stats.ttest_rel(sprmns,sprmns2))
print(spearmanr(sprmns,sprmns2))
print(pearsonr(sprmns,sprmns2))

print(stats.ttest_rel(nlls,nlls2))
print(spearmanr(nlls,nlls2))
print(pearsonr(nlls,nlls2))

#check correlation matrix for NARPS
narps = pwd + 'NARPS/participants_and_model.csv'
narps_df = pd.read_csv(narps)
narps_df['iDE'] = -narps_df['entropy']
narps_df['p(correct)'] = -narps_df['model_conflict']
narps_df['SV'] = narps_df['subjective_value']
narps_df['p(accept)'] = narps_df['p_accept']
subs = narps_df['ID'].unique()
narps_ortho_corrs = []
narps_ortho_corrs2 = []
narps_ortho_corrs3 = []
narps_ortho_corrs4 = []
i = 0
for sub in subs:
    sub_df = narps_df[narps_df['ID']==sub]
    sub_df = sub_df[['SV','p(accept)','iDE','p(correct)']] #.drop(columns=['Unnamed: 0','ID','trial_num','RT'])
    sub_corr_mat = sub_df.corr(method='spearman')
    narps_ortho_corrs.append(spearmanr(sub_df['SV'],sub_df['iDE'])[0])
    narps_ortho_corrs2.append(spearmanr(sub_df['p(accept)'],sub_df['iDE'])[0])
    narps_ortho_corrs3.append(spearmanr(sub_df['SV'],sub_df['p(accept)'])[0])
    narps_ortho_corrs4.append(spearmanr(sub_df['iDE'],sub_df['p(correct)'])[0])
    if i==0:
        all_sub_corr_mats = sub_corr_mat
    else:
        all_sub_corr_mats += sub_corr_mat
    i += 1

print('SV & iDE')
print(np.mean(narps_ortho_corrs))
print(np.std(narps_ortho_corrs))
print(stats.ttest_1samp(narps_ortho_corrs,0))

print('p(accept) & iDE')
print(np.mean(narps_ortho_corrs2))
print(np.std(narps_ortho_corrs2))
print(stats.ttest_1samp(narps_ortho_corrs2,0))

print('SV & p(accept)')
print(np.mean(narps_ortho_corrs3))
print(np.std(narps_ortho_corrs3))
print(stats.ttest_1samp(narps_ortho_corrs3,0))

print('iDE & p(correct)')
print(np.mean(narps_ortho_corrs4))
print(np.std(narps_ortho_corrs4))
print(stats.ttest_1samp(narps_ortho_corrs4,0))

all_sub_corr_mats = all_sub_corr_mats/i
# plot the heatmap
fig = plt.figure(num=None, figsize=(30,10), dpi=100, facecolor='w', edgecolor='k')
ax0 = fig.add_subplot(131)
sns.heatmap(all_sub_corr_mats,
        xticklabels=all_sub_corr_mats.columns,
        yticklabels=all_sub_corr_mats.columns, annot = True, ax = ax0)
plt.title('NARPS')
#plt.show()

#check correlation matrix for BDM values
auction_df = pd.read_csv(pwd + 'Folke_De_Martino_NHB_2016_Github/data/exp1_main_data2.csv')
subs = auction_df['ID'].unique()
i = 0
bdm_ortho_corrs = []
bdm_ortho_corrs2 = []
for sub in subs:
    sub_df = auction_df[auction_df['ID']==sub]
    sub_df = sub_df[['DV','iDE','confidence','p(correct)']] #.drop(columns=['Unnamed: 0','ID','trial_num','RT'])
    sub_corr_mat = sub_df.corr(method='spearman')
    bdm_ortho_corrs.append(spearmanr(sub_df['confidence'],sub_df['iDE'])[0])
    bdm_ortho_corrs2.append(spearmanr(sub_df['p(correct)'],sub_df['iDE'])[0])
    if i==0:
        all_sub_corr_mats = sub_corr_mat
    else:
        all_sub_corr_mats += sub_corr_mat
    i += 1

print('confidence & iDE')
print(np.mean(bdm_ortho_corrs))
print(np.std(bdm_ortho_corrs))
print(stats.ttest_1samp(bdm_ortho_corrs,0))

print('p(correct) & iDE')
print(np.mean(bdm_ortho_corrs2))
print(np.std(bdm_ortho_corrs2))
print(stats.ttest_1samp(bdm_ortho_corrs2,0))

all_sub_corr_mats = all_sub_corr_mats/i
# plot the heatmap
#fig = plt.figure(num=None, figsize=(20,10), dpi=100, facecolor='w', edgecolor='k')
ax = fig.add_subplot(132)
sns.heatmap(all_sub_corr_mats,
        xticklabels=all_sub_corr_mats.columns,
        yticklabels=all_sub_corr_mats.columns, annot = True, ax = ax)
plt.title('BDM values')

#check correlation matrix for estimated values
estim_bdm_df = pd.read_csv(pwd + 'Folke_De_Martino_NHB_2016_Github/data/exp1_main_data2_estim_bdmvals.csv')
subs = estim_bdm_df['ID'].unique()
i = 0
for sub in subs:
    sub_df = estim_bdm_df[estim_bdm_df['ID']==sub]
    sub_df = sub_df[['DV','iDE','confidence','p(correct)']] #.drop(columns=['Unnamed: 0','ID','trial_num','RT'])
    sub_corr_mat = sub_df.corr(method='spearman')
    if i==0:
        all_sub_corr_mats = sub_corr_mat
    else:
        all_sub_corr_mats += sub_corr_mat
    i += 1

all_sub_corr_mats = all_sub_corr_mats/i
# plot the heatmap
ax2 = fig.add_subplot(133)
sns.heatmap(all_sub_corr_mats,
        xticklabels=all_sub_corr_mats.columns,
        yticklabels=all_sub_corr_mats.columns, annot = True, ax = ax2)
plt.title('Estimated BDM values')
plt.show()

#check BDM correlations together
both_dfs = auction_df.join(estim_bdm_df, rsuffix='_estim')

corr_mat = both_dfs.corr(method='spearman')

# plot the heatmap
sns.heatmap(corr_mat,
        xticklabels=corr_mat.columns,
        yticklabels=corr_mat.columns, annot = True)

plt.show()

#experiment 2
bdm2_df = pd.read_csv(bdm2)
subs = bdm2_df['Participant'].unique()

sprmns4 = []
prsns4 = []
for sub in subs:
    sub_df = bdm2_df[bdm2_df['Participant']==sub]
    choice = sub_df['Chose_Highest']
    #choice = sub_df['Chosen_Position'] #coded as {1,2,3}
    values = sub_df[['Value_Position_1', 'Value_Position_2', 'Value_Position_3']]
    sorted_values = np.sort(np.array(values),1)
    vals = sorted_values #sub_df['DV_Top'] #
    conf = sub_df['Conf']
    X = sm.add_constant(vals)
    logit_mod = sm.Logit(choice, X)
    logit_res = logit_mod.fit()
    #print(logit_res.summary())
    preds = np.array(logit_res.predict(X))
    preds.shape = (len(preds),1)
    preds2 = np.hstack([preds,1-preds])
    iDE = -entropy(preds2.transpose(), base=2)
    sprmn = spearmanr(conf,iDE)
    print(sprmn)
    sprmns4.append(sprmn[0])
    prsn = pearsonr(conf,iDE)
    print(prsn)
    prsns4.append(prsn[0])

corr_eval(sprmns4)
corr_eval(prsns4)
