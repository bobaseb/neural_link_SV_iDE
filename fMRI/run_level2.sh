#!/bin/bash -l

#Script number 5 after obtaining fmriprep data.
#Creates the fsf file based of a template and runs feat for level 2.
#Make sure you have created the narps_level2, narps_level2_logs and narps_fsf directories (see below).

# Batch script to run FSL on Myriad
#
# Oct 2015
#
# Based on serial.sh by:
#
# Owain Kenway, Research Computing, 16/Sept/2010

#$ -S /bin/bash

# 1. Request 1 hour of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=3:0:0

# 2. Request 4 gigabyte of RAM.
#$ -l mem=4G

# Note: some FSL programs are multi-threaded eg FEAT and you will need to
# use -pe smp 12 as well.
#$ -pe smp 1

# 3. Set the name of the job.
#$ -N narps_level2

# 6. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
#
# Note: this directory MUST exist before your job starts!
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /scratch/scratch/skgtdnb/narps1-5_subval_choice/narps_level2_logs
# -wd /home/ucjtbob/Scratch/narps1-5_subval_entropy/narps_level2_logs
# -wd /scratch/scratch/skgtdnb/narps1-5_subvalY_entropy/narps_level2_logs
# make n jobs run with different numbers
#$ -t 1-108

#range should be 1-108 to run all subjects

# 7. Setup FSL runtime environment

#The following two commands are needed to load FSL on Myriad.
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

# 8. Need this envionment variable for FEAT and other methods eg bedpostx to
# stop job submission from within jobs and qrsh sessions.

export FSLSUBALREADYRUN=true

#Set the fmri repetition time (TR) here.
TR=1.000000

which_scratch=skgtdnb #ucjtbob
#parent_dir=/scratch/scratch/ucjtbob #if on myriad
model=narps1-5_subval_choice #_choice #narps1-5_subvalY_entropy #narps1-5_subval_entropy
parent_dir=/scratch/scratch/${which_scratch}/${model}

#Main input directories.
LEVEL1DIR=${parent_dir}/narps_level1 #if on myriad
FMRIDIR=/scratch/scratch/ucjuogu/NARPS2/derivatives/fmriprep

#Main output directory.
OUTPUTDIR=${parent_dir}/narps_level2 #if on myriad

currdir=$(pwd)
cd $FMRIDIR
subfldrs=(sub*/)
cd $currdir

job_num=$( expr $SGE_TASK_ID - 1 )

SUBJ=${subfldrs[$job_num]:4:3}
echo subject $SUBJ

#echo ${LEVEL1DIR}/sub{$SUBJ}_run*.feat
all_runs=(${LEVEL1DIR}/sub${SUBJ}_run*.feat)
NUMRUNS=${#all_runs[@]} #4
echo $NUMRUNS runs

all_evs=(${LEVEL1DIR}/sub${SUBJ}_run01.feat/stats/cope*.nii.gz)
orig_evs=${#all_evs[@]} #3 #how many EVs in level 1 model?
echo $orig_evs EVs

#Change this output folder depending on which level you are running.
#This is where the FEAT output will go.
OUTPUT=\"${OUTPUTDIR}/sub${SUBJ}\"

if [ -d "${OUTPUTDIR}/sub${SUBJ}.gfeat/cope${orig_evs}.feat" ]; then
  echo cope ${orig_evs} directory exists
  #exit 1
else
  echo cope ${orig_evs} directory doesnt exist
  rm -R ${OUTPUTDIR}/sub${SUBJ}.gfeat
fi

#FSF file output directory.
FILE=${parent_dir}/narps_fsf/sub${SUBJ}.fsf

#Define the input FEAT directories.
FEATDIR1=${parent_dir}/narps_level1/sub${SUBJ}_run01.feat
FEATDIR2=${parent_dir}/narps_level1/sub${SUBJ}_run02.feat
FEATDIR3=${parent_dir}/narps_level1/sub${SUBJ}_run03.feat
FEATDIR4=${parent_dir}/narps_level1/sub${SUBJ}_run04.feat

#Also define where the structural template we are using is. Not really needed for level2.
#STRUCTREF=\"${parent_dir}/MNI152_T1_1mm_brain\" #if on myriad
MY_SCRATCH=/scratch/scratch/ucjtbob/
STRUCTREF=\"${MY_SCRATCH}/MNI152_T1_1mm_brain\"

#Create the .fsf file.
source /home/ucjtbob/narps_scripts/fMRI/narps_level2_fsf_maker.sh
wait

#Finally, run FEAT.
feat $FILE
wait
