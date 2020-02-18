#!/bin/bash
#to be sourced from run_level1.sh
echo '' > $FILE
cat >> $FILE <<EOF

# FEAT version number
set fmri(version) ${FSLv}

# Are we in MELODIC?
set fmri(inmelodic) 0

# Analysis level
# 1 : First-level analysis
# 2 : Higher-level analysis
set fmri(level) 1

# Which stages to run
# 0 : No first-level analysis (registration and/or group stats only)
# 7 : Full first-level analysis
# 1 : Pre-processing
# 2 : Statistics
set fmri(analysis) 7

# Use relative filenames
set fmri(relative_yn) 0

# Balloon help
set fmri(help_yn) 0

# Run Featwatcher
set fmri(featwatcher_yn) 0

# Cleanup first-level standard-space images
set fmri(sscleanup_yn) 0

# Output directory
set fmri(outputdir) ${OUTPUT}

# TR(s)
set fmri(tr) ${TR}

# Total volumes
set fmri(npts) ${VOLS}

# Delete volumes
set fmri(ndelete) 0

# Perfusion tag/control order
set fmri(tagfirst) 1

# Number of first-level analyses
set fmri(multiple) 1

# Higher-level input type
# 1 : Inputs are lower-level FEAT directories
# 2 : Inputs are cope images from FEAT directories
set fmri(inputtype) 2

# Carry out pre-stats processing?
set fmri(filtering_yn) 1

# Brain/background threshold, %
set fmri(brain_thresh) 10

# Critical z for design efficiency calculation
set fmri(critical_z) 5.3

# Noise level
set fmri(noise) 0.66

# Noise AR(1)
set fmri(noisear) 0.34

# Motion correction
# 0 : None
# 1 : MCFLIRT
set fmri(mc) 1

# Spin-history (currently obsolete)
set fmri(sh_yn) 0

# B0 fieldmap unwarping?
set fmri(regunwarp_yn) 0

# GDC Test
set fmri(gdc) ""

# EPI dwell time (ms)
set fmri(dwell) 0.7

# EPI TE (ms)
set fmri(te) 35

# % Signal loss threshold
set fmri(signallossthresh) 10

# Unwarp direction
set fmri(unwarp_dir) y-

# Slice timing correction
# 0 : None
# 1 : Regular up (0, 1, 2, 3, ...)
# 2 : Regular down
# 3 : Use slice order file
# 4 : Use slice timings file
# 5 : Interleaved (0, 2, 4 ... 1, 3, 5 ... )
set fmri(st) 0

# Slice timings file
set fmri(st_file) ""

# BET brain extraction
set fmri(bet_yn) 0

# Spatial smoothing FWHM (mm)
set fmri(smooth) 5

# Intensity normalization
set fmri(norm_yn) 0

# Perfusion subtraction
set fmri(perfsub_yn) 0

# Highpass temporal filtering
set fmri(temphp_yn) 1

# Lowpass temporal filtering
set fmri(templp_yn) 0

# MELODIC ICA data exploration
set fmri(melodic_yn) 0

# Carry out main stats?
set fmri(stats_yn) 1

# Carry out prewhitening?
set fmri(prewhiten_yn) 1

# Add motion parameters to model
# 0 : No
# 1 : Yes
set fmri(motionevs) 0
set fmri(motionevsbeta) ""
set fmri(scriptevsbeta) ""

# Robust outlier detection in FLAME?
set fmri(robust_yn) 0

# Higher-level modelling
# 3 : Fixed effects
# 0 : Mixed Effects: Simple OLS
# 2 : Mixed Effects: FLAME 1
# 1 : Mixed Effects: FLAME 1+2
set fmri(mixed_yn) 2

# Higher-level permutations
set fmri(randomisePermutations) 5000

# Number of EVs
set fmri(evs_orig) ${orig_evs}
set fmri(evs_real) ${real_evs}
set fmri(evs_vox) 0

# Number of contrasts
set fmri(ncon_orig) ${contrasts}
set fmri(ncon_real) ${contrasts}

# Number of F-tests
set fmri(nftests_orig) 0
set fmri(nftests_real) 0

# Add constant column to design matrix? (obsolete)
set fmri(constcol) 0

# Carry out post-stats steps?
set fmri(poststats_yn) 1

# Pre-threshold masking?
set fmri(threshmask) ""

# Thresholding
# 0 : None
# 1 : Uncorrected
# 2 : Voxel
# 3 : Cluster
set fmri(thresh) 3

# P threshold
set fmri(prob_thresh) 0.05

# Z threshold
set fmri(z_thresh) 3.1

# Z min/max for colour rendering
# 0 : Use actual Z min/max
# 1 : Use preset Z min/max
set fmri(zdisplay) 0

# Z min in colour rendering
set fmri(zmin) 2

# Z max in colour rendering
set fmri(zmax) 8

# Colour rendering type
# 0 : Solid blobs
# 1 : Transparent blobs
set fmri(rendertype) 1

# Background image for higher-level stats overlays
# 1 : Mean highres
# 2 : First highres
# 3 : Mean functional
# 4 : First functional
# 5 : Standard space template
set fmri(bgimage) 1

# Create time series plots
set fmri(tsplot_yn) 1

# Registration to initial structural
set fmri(reginitial_highres_yn) 0

# Search space for registration to initial structural
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(reginitial_highres_search) 90

# Degrees of Freedom for registration to initial structural
set fmri(reginitial_highres_dof) 3

# Registration to main structural
set fmri(reghighres_yn) 0

# Search space for registration to main structural
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(reghighres_search) 90

# Degrees of Freedom for registration to main structural
set fmri(reghighres_dof) BBR

# Registration to standard image?
set fmri(regstandard_yn) 1

# Use alternate reference images?
set fmri(alternateReference_yn) 0

# Standard image
set fmri(regstandard) ${STRUCTREF}

# Search space for registration to standard space
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(regstandard_search) 90

# Degrees of Freedom for registration to standard space
set fmri(regstandard_dof) 3

# Do nonlinear registration from structural to standard space?
set fmri(regstandard_nonlinear_yn) 0

# Control nonlinear warp field resolution
set fmri(regstandard_nonlinear_warpres) 10

# High pass filter cutoff
set fmri(paradigm_hp) 100

# Total voxels
set fmri(totalVoxels) ${TOT_VOXELS}


# Number of lower-level copes feeding into higher-level analysis
set fmri(ncopeinputs) 0

# 4D AVW data or FEAT directory (1)
set feat_files(1) ${INPUTIMG}

# Add confound EVs text file
set fmri(confoundevs) 1

# Confound EVs text file for analysis 1
set confoundev_files(1) ${CONFOUND_EVS}

EOF

#Setup EVs loop
for pre_ev_num in ${!ev_names[@]}
do
ev_num=$( expr $pre_ev_num + 1 )
cat >> $FILE <<EOF
# EV ${ev_num} title
set fmri(evtitle${ev_num}) "${ev_names[$pre_ev_num]}"

# Basic waveform shape (EV ${ev_num})
# 0 : Square
# 1 : Sinusoid
# 2 : Custom (1 entry per volume)
# 3 : Custom (3 column format)
# 4 : Interaction
# 10 : Empty (all zeros)
set fmri(shape${ev_num}) 3

# Convolution (EV ${ev_num})
# 0 : None
# 1 : Gaussian
# 2 : Gamma
# 3 : Double-Gamma HRF
# 4 : Gamma basis functions
# 5 : Sine basis functions
# 6 : FIR basis functions
set fmri(convolve${ev_num}) 3

# Convolve phase (EV ${ev_num})
set fmri(convolve_phase${ev_num}) 0

# Apply temporal filtering (EV ${ev_num})
set fmri(tempfilt_yn${ev_num}) 1

# Add temporal derivative (EV ${ev_num})
set fmri(deriv_yn${ev_num}) 1

# Custom EV file (EV ${ev_num})
set fmri(custom${ev_num}) ${ev_paths[$pre_ev_num]}

EOF

for (( i=0; i<=${orig_evs}; i++ ))
do
cat >> $FILE <<EOF
# Orthogonalise EV ${ev_num} wrt EV ${i}
set fmri(ortho${ev_num}.${i}) 0

EOF
done

done

#General contrast intro
cat >> $FILE <<EOF

# Contrast & F-tests mode
# real : control real EVs
# orig : control original EVs
set fmri(con_mode_old) orig
set fmri(con_mode) orig

EOF

#Real EV contrasts
for pre_ev_num in ${!ev_names[@]}
do
ev_num=$( expr $pre_ev_num + 1 )
cat >> $FILE <<EOF

# Display images for contrast_real ${ev_num}
set fmri(conpic_real.${ev_num}) 1

# Title for contrast_real ${ev_num}
set fmri(conname_real.${ev_num}) "${ev_names[$pre_ev_num]}Cope"

EOF

for (( i=1; i<=${real_evs}; i++ ))
do
ev_alter_num=$(($ev_num * 2 - 1))
if [[ $((i)) -eq $((ev_alter_num)) ]]
then
  indicator=1
else
  indicator=0
fi
cat >> $FILE <<EOF
# Real contrast_real vector ${ev_num} element ${i}
set fmri(con_real${ev_num}.${i}) ${indicator}

EOF
done

done

#Original EV contrasts
for pre_ev_num in ${!ev_names[@]}
do
ev_num=$( expr $pre_ev_num + 1 )
cat >> $FILE <<EOF

# Display images for contrast_orig ${ev_num}
set fmri(conpic_orig.${ev_num}) 1

# Title for contrast_orig ${ev_num}
set fmri(conname_orig.${ev_num}) "${ev_names[$pre_ev_num]}Cope"

EOF

for (( i=1; i<=${orig_evs}; i++ ))
do
if [[ $((i)) -eq $((ev_num)) ]]
then
  indicator=1
else
  indicator=0
fi
cat >> $FILE <<EOF
# Real contrast_orig vector ${ev_num} element ${i}
set fmri(con_orig${ev_num}.${i}) ${indicator}

EOF
done

done

#Contrast intro
cat >> $FILE <<EOF

# Contrast masking - use >0 instead of thresholding?
set fmri(conmask_zerothresh_yn) 0

EOF

#Contrast loop
for pre_ev_num in ${!ev_names[@]}
do
ev_num=$( expr $pre_ev_num + 1 )
for (( i=1; i<=${orig_evs}; i++ ))
do
if [[ $((i)) -eq $((ev_num)) ]]
then
  continue
fi
cat >> $FILE <<EOF
# Mask real contrast/F-test ${ev_num} with real contrast/F-test ${i}?
set fmri(conmask${ev_num}_${i}) 0
EOF
done
done

#Final info
cat >> $FILE <<EOF

# Do contrast masking at all?
set fmri(conmask1_1) 0

##########################################################
# Now options that don't appear in the GUI

# Alternative (to BETting) mask image
set fmri(alternative_mask) ""

# Initial structural space registration initialisation transform
set fmri(init_initial_highres) ""

# Structural space registration initialisation transform
set fmri(init_highres) ""

# Standard space registration initialisation transform
set fmri(init_standard) ""

# For full FEAT analysis: overwrite existing .feat output dir?
set fmri(overwrite_yn) 0

EOF