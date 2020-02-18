import sys
import pandas as pd
import numpy as np

print(sys.argv[1])

fn = sys.argv[1]

#fn = '/scratch/scratch/ucjuogu/NARPS2/derivatives/fmriprep/sub-001/func/sub-001_task-MGT_run-01_bold_confounds.tsv'

file_data = pd.read_csv(fn,sep='\t')

reduced_confounds = file_data.loc[:,['FramewiseDisplacement','X','Y','Z','RotX','RotY','RotZ']]

reduced_confounds.loc[0,'FramewiseDisplacement'] = 0

np.savetxt(fn[:-4] + '_reduced.txt', reduced_confounds.values, fmt='%f')
