# fMRI analyses

The bash scripts mostly make calls to FSL 5.0.9 or other bash scripts in the repository. They were run on a high performance computing cluster called Myriad, at University College London (UCL), which required '#$' at the beginning of the script for commands sent to the scheduler. Some of the python scripts may have bash commands for the cluster at the top; it is safe to comment those out. 

The script order text file gives an overall idea of the pipeline. For example apply_brain_msk.sh and get_confounds.sh/get_confounds.py only needed to be run once. The other bash scripts needed to be run for every new GLM model at each level (i.e., 1-3). For each level of analysis, you will find a run*.sh script that will call a \*maker.sh script. The latter has a template for a FSL design text file which has some variables populated by the corresponding run*.sh script. Some scripts explore BIC comparisons of said models but were not used for any of the main analyses in the study. 
