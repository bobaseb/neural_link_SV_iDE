#!/bin/bash -l

#Script number 3 after obtaining fmriprep data.
#Creates the fsf file based of a template and runs feat for level 1.
#Make sure you have created the narps_level1 and narps_fsf directories (see below).
#Also make sure you have made the standard MNI template accessible.

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
#originally 5 hours, then 10 hours

# 2. Request 4 gigabyte of RAM.
#$ -l mem=4G

# Note: some FSL programs are multi-threaded eg FEAT and you will need to
# use -pe smp 12 as well.
#$ -pe smp 1

# 3. Set the name of the job.
#$ -N narps_level1_run4

# 6. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
#
# Note: this directory MUST exist before your job starts!
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucjtbob/Scratch/narps1_subval_entropy/narps_level1_logs
# make n jobs run with different numbers
#$ -t 1-108

curr_model=narps1_subval_entropy #place above for logs as well & change MODEL!!!
#narps1_only_subval_model #narps1_subval_entropy #narps1_only_entropy_model

#range should be 1-108 to run all subjects

#OJO: Folders that need to be in place prior to running are narps_level1_logs, narps_level1, narps_fsf
#For each run, change job name and RUN variable below

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

#Main input directories.
TMPDIR=/scratch/scratch/ucjuogu #if on myriad
#TMPDIR=/mnt/love12/home/seb/myriad #example directory if mounted locally
FMRIDIR=${TMPDIR}/NARPS2/derivatives/fmriprep
BEHAVIORDIR=${TMPDIR}/behavior

#Main (parent) output directory.
#OUTPUTDIR=/mnt/love12/home/seb/tmp_NARPS #example directory if mounted locally
#OUTPUTDIR=/scratch/scratch/ucjtbob #if on myriad
OUTPUTDIR=/scratch/scratch/ucjtbob/${curr_model}

currdir=$(pwd)
cd $FMRIDIR
subfldrs=(sub*/)
cd $currdir

#for i in 0 #${!subfldrs[@]}
#do
#echo i=$i

job_num=$( expr $SGE_TASK_ID - 1 )

SUBJ=${subfldrs[$job_num]:4:3}
echo subject $SUBJ

#for RUN in 01 #02 03 04
#do

RUN=04
echo run $RUN

#Remove the trailing zeros for some of the files below.
SUBJr=$(echo ${SUBJ} | sed 's/^0*//')
RUNr=$(echo ${RUN} | sed 's/^0*//')

#Change (or create) this output folder depending on which level you are running.
#This is where the FEAT output will go.
OUTPUT=\"${OUTPUTDIR}/narps_level1/sub${SUBJ}_run${RUN}\"

if [ ! -f "${OUTPUTDIR}/narps_level1/sub${SUBJ}_run${RUN}.feat/thresh_zstat3.nii.gz" ]; then
  rm -R ${OUTPUTDIR}/narps_level1/sub${SUBJ}_run${RUN}.feat/stats
fi

if [ -d "${OUTPUTDIR}/narps_level1/sub${SUBJ}_run${RUN}.feat/stats" ]; then
  echo 'stats directory exists'
  exit 1
else
  echo 'stats directory doesnt exist'
  rm -R ${OUTPUTDIR}/narps_level1/sub${SUBJ}_run${RUN}.feat
fi

#FSF file output directory.
#FILE=${TMPDIR}/sub${SUBJ}_run${RUN}.fsf
FILE=${OUTPUTDIR}/narps_fsf/sub${SUBJ}_run${RUN}.fsf

#Define the input image for FEAT here.
INPUTIMG=\"${FMRIDIR}/sub-${SUBJ}/func/sub-${SUBJ}_task-MGT_run-${RUN}_bold_space-MNI152NLin2009cAsym_preproc_brain\"
INPUTIMGr=${FMRIDIR}/sub-${SUBJ}/func/sub-${SUBJ}_task-MGT_run-${RUN}_bold_space-MNI152NLin2009cAsym_preproc_brain

#Also define where the structural template we are using is.
STRUCTREF=\"${OUTPUTDIR}/MNI152_T1_1mm_brain\" #if on myriad
#STRUCTREF=\"/usr/local/fsl/data/standard/MNI152_T1_1mm_brain\" #example local directory

#Setup some specific EV paths.
CONFOUND_EVS=\"${FMRIDIR}/sub-${SUBJ}/func/sub-${SUBJ}_task-MGT_run-${RUN}_bold_confounds_reduced.txt\"
INTERCEPT_EV=\"${BEHAVIORDIR}/intercept/${SUBJr}_${RUNr}_intercept.txt\"
GAINS_EV=\"${BEHAVIORDIR}/mc_gain/${SUBJr}_${RUNr}_mc_gain.txt\"
LOSSES_EV=\"${BEHAVIORDIR}/mc_loss/${SUBJr}_${RUNr}_mc_loss.txt\"
ENTROPY_EV=\"${BEHAVIORDIR}/mc_entropy/${SUBJr}_${RUNr}_mc_entropy.txt\"
SUBVAL_EV=\"${BEHAVIORDIR}/mc_subjective_value/${SUBJr}_${RUNr}_mc_subjective_value.txt\"

#Setup the current model
#ev_names=(Intercept Gains Losses)
#ev_paths=(${INTERCEPT_EV} ${GAINS_EV} ${LOSSES_EV})
ev_names=(Intercept SubVal Entropy) #SubVal is subjective value
ev_paths=(${INTERCEPT_EV} ${SUBVAL_EV} ${ENTROPY_EV})

#ev_names=(Intercept Entropy) #SubVal is subjective value
#ev_paths=(${INTERCEPT_EV} ${ENTROPY_EV})

#ev_names=(Intercept SubVal) #SubVal is subjective value
#ev_paths=(${INTERCEPT_EV} ${SUBVAL_EV})

#EV num
orig_evs=${#ev_names[@]}
real_evs=$((${orig_evs}*2)) #2x for temporal derivatives
contrasts=${orig_evs} #same as orig_evs if testing main effects

#Retrieve the number of volumes.
VOLS=$(fslnvols ${INPUTIMGr})
echo number of volumes ${VOLS}

#Retrieve the number of voxels.
fslnums=$(fslstats ${INPUTIMGr} -v)
TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
echo total voxels ${TOT_VOXELS}

#Create the .fsf file.
source /home/ucjtbob/narps_scripts/narps_level1_fsf_maker.sh
wait

#Finally, run FEAT.
feat $FILE
wait

#done

#done
