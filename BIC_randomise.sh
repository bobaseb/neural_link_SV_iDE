#!/bin/bash -l

# Batch script to run FSL on Myriad
#
# Oct 2015
#
# Based on serial.sh by:
#
# Owain Kenway, Research Computing, 16/Sept/2010

#$ -S /bin/bash

# 1. Request 1 hour of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=10:0:0

# 2. Request 4 gigabyte of RAM.
#$ -l mem=4G

# Note: some FSL programs are multi-threaded eg FEAT and you will need to
# use -pe smp 12 as well.
#$ -pe smp 1

# 3. Set the name of the job.
#$ -N narps1_randomise

# 6. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
#
# Note: this directory MUST exist before your job starts!
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucjtbob/Scratch/narps1_BIC_diffs_logs
# make n jobs run with different numbers
#$ -t 1-12

#1-12

job_num=$( expr $SGE_TASK_ID - 1 )

# 7. Setup FSL runtime environment

#The following two commands are needed to load FSL on Myriad.
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

# 8. Need this environment variable for FEAT and other methods eg bedpostx to
# stop job submission from within jobs and qrsh sessions.

export FSLSUBALREADYRUN=true

parent_dir=/scratch/scratch/ucjtbob #if on myriad

cd ${parent_dir}/narps1_BIC_diffs
BIC_diffs=(*)

BIC_diff=${BIC_diffs[$job_num]}

randomise -i ${parent_dir}/narps1_BIC_diffs/${BIC_diff} -o ${parent_dir}/BIC_diffs_results/${BIC_diff}_T.nii.gz -1 -T

#randomise -i OneSamp4D -o OneSampT -1 -v 5 -T (variance smoothing for fewer than 20 subs)
