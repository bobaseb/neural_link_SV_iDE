#!/bin/bash

#Script number 3 after obtaining fmriprep data.
#Creates the fsf file based of a template and runs feat for level 1.
#Make sure you have created the narps_level1 and narps_fsf directories (see below).
#Also make sure you have made the standard MNI template accessible.

#The following two commands are needed to load FSL on Myriad.
#For some reason they don't work from within this script?
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

#Set the fmri repetition time (TR) here.
TR=1.000000

#Main input directories.
TMPDIR=/scratch/scratch/ucjuogu #if on myriad
#TMPDIR=/mnt/love12/home/seb/myriad #example directory if mounted locally
FMRIDIR=${TMPDIR}/NARPS2/derivatives/fmriprep
BEHAVIORDIR=${TMPDIR}/behavior

#Main (parent) output directory.
#OUTPUTDIR=/mnt/love12/home/seb/tmp_NARPS #example directory if mounted locally
OUTPUTDIR=/scratch/scratch/ucjtbob #if on myriad

currdir=$(pwd)
cd $FMRIDIR
subfldrs=(sub*/)
cd $currdir

for i in 0 #${!subfldrs[@]}
do

echo i=$i

SUBJ=${subfldrs[$i]:4:3}

echo subject $SUBJ

	for RUN in 01 #02 03 04
	do

	echo run $RUN

	#Remove the trailing zeros for some of the files below.
	SUBJr=$(echo ${SUBJ} | sed 's/^0*//')
  RUNr=$(echo ${RUN} | sed 's/^0*//')

	#Change this output folder depending on which level you are running.
	#This is where the FEAT output will go.
	OUTPUT=\"${OUTPUTDIR}/narps_level1/sub${SUBJ}_run${RUN}\"

	#FSF file output directory.
	#FILE=${TMPDIR}/sub${SUBJ}_run${RUN}.fsf
	FILE=${OUTPUTDIR}/narps_fsf/sub${SUBJ}_run${RUN}.fsf

	#Define the input image for FEAT here.
	INPUTIMG=\"${FMRIDIR}/sub-${SUBJ}/func/sub-${SUBJ}_task-MGT_run-${RUN}_bold_space-MNI152NLin2009cAsym_preproc_brain\"
	INPUTIMGr=${FMRIDIR}/sub-${SUBJ}/func/sub-${SUBJ}_task-MGT_run-${RUN}_bold_space-MNI152NLin2009cAsym_preproc_brain

	#Also define where the structural template we are using is.
	STRUCTREF=\"${OUTPUTDIR}/MNI152_T1_1mm_brain\" #if on myriad
  #STRUCTREF=\"/usr/local/fsl/data/standard/MNI152_T1_1mm_brain\" #example local directory

	#Setup some specific EVs.
	CONFOUND_EVS=\"${FMRIDIR}/sub-${SUBJ}/func/sub-${SUBJ}_task-MGT_run-${RUN}_bold_confounds_reduced.txt\"
	INTERCEPT_EV=\"${BEHAVIORDIR}/intercept/${SUBJr}_${RUNr}_intercept.txt\"
	GAINS_EV=\"${BEHAVIORDIR}/mc_gain/${SUBJr}_${RUNr}_mc_gain.txt\"
	LOSSES_EV=\"${BEHAVIORDIR}/mc_loss/${SUBJr}_${RUNr}_mc_loss.txt\"
	ENTROPY_EV=\"${BEHAVIORDIR}/mc_entropy/${SUBJr}_${RUNr}_mc_entropy.txt\"

	#Retrieve the number of volumes.
	VOLS=$(fslnvols ${INPUTIMGr})
	echo number of volumes ${VOLS}

	#Retrieve the number of voxels.
	fslnums=$(fslstats ${INPUTIMGr} -v)
	TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
	echo total voxels ${TOT_VOXELS}

	#Create the .fsf file.
	source narps_level1_fsf_maker.sh
	wait

	#Finally, run FEAT.
	feat $FILE
	wait

	done

done
