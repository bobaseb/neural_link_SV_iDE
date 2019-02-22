#!/bin/bash

#BIC script, run after level 1, relies on get_BIC.py           ***********add BIC if else check

#narps1_only_subval_model #narps1_subval_entropy #narps1_only_entropy_model
#uses res4d.nii.gz output from FEAT/FSL
curr_model=narps1_subval_entropy
model_dir=/scratch/scratch/ucjtbob/${curr_model}
parent_dir=${model_dir}/narps_level1
home_dir=/home/ucjtbob

#source /home/ucjtbob/Envs/pymvpa/bin/activate
source /etc/profile.d/modules.sh
module unload compilers
module load compilers/gnu/4.9.2
module load swig/3.0.7/gnu-4.9.2
module load python2/recommended

cd ${parent_dir}

subfldrs=(sub*/)
#subfldrs=(sub027_run03.feat/)
#echo $subfldrs
#exit 1

for sub_fldr in ${subfldrs[@]}
do

if [ -f "${parent_dir}/${sub_fldr}stats/BIC.nii.gz" ]; then
  #echo "there is BIC file for this sub, run"
  continue
fi

#exit 1

echo ${curr_model}
echo $sub_fldr
echo "no BIC file for this sub, run"

curr_dir=${parent_dir}/${sub_fldr}stats/

cd ${curr_dir}

k_tmp=(pe*.nii.gz)
k=${#k_tmp[@]}

echo $k

python ${home_dir}/narps_scripts/get_BIC.py ${curr_dir} ${k}

#exit 1
done

#exit 1

#Merge BICs across runs, compute means/medians

#The following two commands are needed to load FSL on Myriad.
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

#subfldrs=(sub027_run01.feat/ sub027_run02.feat/ sub027_run03.feat/ sub027_run04.feat/)
#echo ${subfldrs[@]}
#exit 1

mkdir ${model_dir}/BIC_level2
for sub_fldr in ${subfldrs[@]}
#${subfldrs[@]} #${subfldrs[@]:0:8}
do

SUBJ=${sub_fldr:3:3}
RUN=${sub_fldr:10:2}
#SUBJ_RUN=${sub_fldr:0:12}

curr_BIC=${parent_dir}/${sub_fldr}stats/BIC.nii.gz

mkdir ${model_dir}/BIC_level2/${SUBJ}
cp ${curr_BIC} ${model_dir}/BIC_level2/${SUBJ}/tmp_BIC_${RUN}.nii.gz

done

#exit 1

cd ${model_dir}/BIC_level2
bicfldrs=(*)
#bicfldrs=(027)
for bic_fldr in ${bicfldrs[@]}
do

cd $bic_fldr

fslmerge -t ${model_dir}/BIC_level2/BIC_sub${bic_fldr}.nii.gz tmp_BIC_01.nii.gz tmp_BIC_02.nii.gz tmp_BIC_03.nii.gz tmp_BIC_04.nii.gz

cd ..

rm -R $bic_fldr
fslmaths BIC_sub${bic_fldr}.nii.gz -Tmean BIC_sub${bic_fldr}_mean.nii.gz
fslmaths BIC_sub${bic_fldr}.nii.gz -Tmedian BIC_sub${bic_fldr}_median.nii.gz
done
