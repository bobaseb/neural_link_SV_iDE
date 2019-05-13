#!/bin/bash -l

#Script number 6 after obtaining fmriprep data.
#Creates the fsf file based of a template and runs feat for level 2.
#Make sure you have created the narps_level3, narps_level3_logs and narps_fsf directories (see below).

# Batch script to run FSL on Myriad
#
# Oct 2015
#
# Based on serial.sh by:
#
# Owain Kenway, Research Computing, 16/Sept/2010

#$ -S /bin/bash

# 1. Request 1 hour of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=48:0:0

#was 5 hours for NARPS

# 2. Request 4 gigabyte of RAM.
#$ -l mem=4G

# Note: some FSL programs are multi-threaded eg FEAT and you will need to
# use -pe smp 12 as well.
#$ -pe smp 1

# 3. Set the name of the job.
#$ -N narps_level3

# 6. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
#
# Note: this directory MUST exist before your job starts!
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucjtbob/Scratch/narps0-5_gl_entropy/narps_level3_logs
# make n jobs run with different numbers
#$ -t 1-9

#range should be 1-$NUMEVS to run all EVs (intercept,gains,losses,...entropy) for both conditions.
#up to $((compare_cond_num)) to compare conditions

# 7. Setup FSL runtime environment

#The following two commands are needed to load FSL on Myriad.
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

# 8. Need this environment variable for FEAT and other methods eg bedpostx to
# stop job submission from within jobs and qrsh sessions.

export FSLSUBALREADYRUN=true

#parent_dir=/scratch/scratch/ucjtbob #if on myriad
model=narps0-5_gl_entropy #narps1_subval_entropy
parent_dir=/scratch/scratch/ucjtbob/${model}

#Main input directories.
LEVEL2DIR=${parent_dir}/narps_level2 #if on myriad
FMRIDIR=/scratch/scratch/ucjuogu/NARPS2/derivatives/fmriprep

#Main output directory.
OUTPUTDIR=${parent_dir}/narps_level3 #if on myriad

#Setup some initial params
compare_cond_num=9 #job number that compares losses between EqInd & EqR conditions
NUMEVS=4 #How many EVs were in the level 1 model?
sep_cond=1 #separate by condition?

#Establish condition.
if [[ $((SGE_TASK_ID)) -lt $((NUMEVS + 1)) ]]; then
  condition=EqR #job number lower than $((NUMEVS + 1)) is equal range
elif [[ $((SGE_TASK_ID)) -eq $((compare_cond_num)) ]]; then
  condition=CompareLoss #job number $((compare_cond_num)) is to compare conditions
else
  condition=EqInd #job number greater than $((NUMEVS + 1)) is equal indifference
fi

if [[ $((sep_cond)) == $((0)) ]]; then
  condition=AllSubs #in case we just use all subjects
fi

echo condition $condition

#Establish which EV (COPE).
EVNUM=$((SGE_TASK_ID % NUMEVS))
if [[ $((EVNUM)) == 0 ]]; then
  EVNUM=${NUMEVS}
fi

if [[ $((SGE_TASK_ID)) == $((compare_cond_num)) ]]; then
  EVNUM=3 #this grabs the loss copes to compare conditions
fi

echo evnum $EVNUM

# Subjects to be excluded from level 3 analyses are 25 (inversed buttons), 13 & 56 (gains/losses outliers), & 30 (head movement).
# Even subject numbers are from the Equal Range condition.
# Odd subject numbers are from the Equal Indifference condition.

#Get the subject list.
currdir=$(pwd)
cd $FMRIDIR
subfldrs=(sub*/)
cd $currdir

#Separate subjects by condition.
EqualRange=()
EqualIndiff=()
for i in ${!subfldrs[@]}
do
SUBJ=${subfldrs[${i}]:4:3}
#Remove the trailing zeros.
SUBJNUM=$(echo ${SUBJ} | sed 's/^0*//')
#Skip excluded subjects (see above).
if [[ $((SUBJNUM)) == 13 ]] || [[ $((SUBJNUM)) == 25 ]] || [[ $((SUBJNUM)) == 30 ]] || [[ $((SUBJNUM)) == 56 ]]
then
  echo subject ${SUBJNUM} excluded
  continue
fi
#Cope filename.
fn=${LEVEL2DIR}/sub${SUBJ}.gfeat/cope${EVNUM}.feat/stats/cope1.nii.gz #assumes runs were just averaged
if [[ $((SUBJNUM % 2)) == 0 ]]; then
  EqualRange+=($fn) #for even number subjects
else
  EqualIndiff+=($fn) #for odd number subjects
fi
done

#Give the level 3 test a name. You can change based on level 1 model.
if [[ $((EVNUM)) == 1 ]]; then
  EV=intercept${condition}
elif [[ $((EVNUM)) == 2 ]]; then
  EV=gains${condition}
  #EV=subval${condition}
elif [[ $((EVNUM)) == 3 ]]; then
  if [[ $((SGE_TASK_ID)) == $((compare_cond_num)) ]]; then
    EV=CompareLoss
  else
    EV=losses${condition}
    #EV=entropy${condition}
  fi
elif [[ $((EVNUM)) == 4 ]]; then
  EV=entropy${condition} #this was for the entropy model
fi

echo Running level 3 on ${EV} Cope.

#Change this output folder depending on which level you are running.
#This is where the FEAT output will go.
OUTPUT=\"${OUTPUTDIR}/${EV}\"

#FSF file output directory.
FILE=${parent_dir}/narps_fsf/${EV}.fsf

#Define the input FEAT directories.
if [[ $((SGE_TASK_ID)) -lt $((NUMEVS + 1)) ]]; then
  INPUTCOPES=("${EqualRange[@]}") #job number lower than $((NUMEVS + 1)) is equal range
  NUMINPUTCOPES=${#EqualRange[@]}
else
  INPUTCOPES=("${EqualIndiff[@]}") #job number equal to or greater than $((NUMEVS + 1)) is equal indifference
  NUMINPUTCOPES=${#EqualIndiff[@]}
fi
#NumEqIndiffCopes=${#EqualIndiff[@]}
#NumEqRCopes=${#EqualRange[@]}
NUMINPUTCOPESALL=$((${#EqualIndiff[@]} + ${#EqualRange[@]}))

echo $NUMINPUTCOPESALL subjects total both conditions

#Also define where the structural template we are using is. Not really needed if using fmriprep data.
STRUCTREF=\"${parent_dir}/MNI152_T1_1mm_brain\" #if on myriad

#Select INPUTCOPES (changes for job number $((compare_cond_num)))
if [[ $((sep_cond)) -eq 1 ]]; then

if [[ $((SGE_TASK_ID)) -lt $((compare_cond_num)) ]]; then
INPUTCOPES2=("${INPUTCOPES[@]}")
else
INPUTCOPES2=("${EqualRange[@]}") #equal range condition first to be consistent with fsf template
INPUTCOPES2+=("${EqualIndiff[@]}")
fi

else

INPUTCOPES2=("${EqualRange[@]}") #equal range condition first to be consistent with fsf template
INPUTCOPES2+=("${EqualIndiff[@]}")
NUMINPUTCOPES=${NUMINPUTCOPESALL}
echo 'not separated by condition'

fi

#Define all the COPE paths & specs in .fsf format.
ALLCOPES=()
HIGHLEVEL=()
HIGHLEVELEqR=()
HIGHLEVELEqInd=()
GROUPMEM=()
for i in ${!INPUTCOPES2[@]}
do
ALLCOPES+=("# 4D AVW data or FEAT directory ($((i + 1)))")
ALLCOPES+=("set feat_files($((i + 1))) \"${INPUTCOPES2[${i}]}\"")
GROUPMEM+=("# Group membership for input $((i + 1))")
GROUPMEM+=("set fmri(groupmem.$((i + 1))) 1")

#outer if-then clause catches job $((compare_cond_num))
if [[ $((SGE_TASK_ID)) -lt $((compare_cond_num)) ]]; then
HIGHLEVEL+=("# Higher-level EV value for EV 1 and input $((i + 1))")
HIGHLEVEL+=("set fmri(evg$((i + 1)).1) 1")
elif [[ $((SGE_TASK_ID)) -eq $((compare_cond_num)) ]]; then

#inner if-then clause controls condition indicator for job $((compare_cond_num))
if [[ $((i)) -lt ${#EqualRange[@]} ]]; then
indicator1=1
indicator2=0
else
indicator1=0
indicator2=1
fi

HIGHLEVELEqR+=("# Higher-level EV value for EV 1 and input $((i + 1))")
HIGHLEVELEqR+=("set fmri(evg$((i + 1)).1) ${indicator1}")
HIGHLEVELEqInd+=("# Higher-level EV value for EV 2 and input $((i + 1))")
HIGHLEVELEqInd+=("set fmri(evg$((i + 1)).2) ${indicator2}")
fi

done

#Create the .fsf file.
if [[ $((SGE_TASK_ID)) -lt $((compare_cond_num)) ]]; then
source /home/ucjtbob/narps_scripts/narps_level3_fsf_maker.sh
else
source /home/ucjtbob/narps_scripts/narps_level3_fsf_maker_h9.sh
fi
wait

#Finally, run FEAT.
feat $FILE
wait
