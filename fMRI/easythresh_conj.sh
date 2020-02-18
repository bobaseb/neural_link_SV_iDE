#!/bin/sh

#   easythresh_conj - quick method of getting conjunction stats
#                     outside of feat  
#
# 
#   A modified version of easythresh by Thomas Nichols
# 
#   easythresh by Stephen Smith and Mark Jenkinson, FMRIB Image
#   Analysis Group 
#
#   Copyright (C) 1999-2007 University of Oxford
#
#   Part of FSL - FMRIB's Software Library
#   http://www.fmrib.ox.ac.uk/fsl
#   fsl@fmrib.ox.ac.uk
#   
#   Developed at FMRIB (Oxford Centre for Functional Magnetic Resonance
#   Imaging of the Brain), Department of Clinical Neurology, Oxford
#   University, Oxford, UK
#   
#   
#   LICENCE
#   
#   FMRIB Software Library, Release 4.0 (c) 2007, The University of
#   Oxford (the "Software")
#   
#   The Software remains the property of the University of Oxford ("the
#   University").
#   
#   The Software is distributed "AS IS" under this Licence solely for
#   non-commercial use in the hope that it will be useful, but in order
#   that the University as a charitable foundation protects its assets for
#   the benefit of its educational and research purposes, the University
#   makes clear that no condition is made or to be implied, nor is any
#   warranty given or to be implied, as to the accuracy of the Software,
#   or that it will be suitable for any particular purpose or for use
#   under any specific conditions. Furthermore, the University disclaims
#   all responsibility for the use which is made of the Software. It
#   further disclaims any liability for the outcomes arising from using
#   the Software.
#   
#   The Licensee agrees to indemnify the University and hold the
#   University harmless from and against any and all claims, damages and
#   liabilities asserted by third parties (including claims for
#   negligence) which arise directly or indirectly from the use of the
#   Software or the sale of any products based on the Software.
#   
#   No part of the Software may be reproduced, modified, transmitted or
#   transferred in any form or by any means, electronic or mechanical,
#   without the express permission of the University. The permission of
#   the University is not required if the said reproduction, modification,
#   transmission or transference is done without financial return, the
#   conditions of this Licence are imposed upon the receiver of the
#   product, and all original and amended source code is included in any
#   transmitted product. You may be held legally responsible for any
#   copyright infringement that is caused or encouraged by your failure to
#   abide by these terms and conditions.
#   
#   You are not permitted under this Licence to use this Software
#   commercially. Use for which any financial return is received shall be
#   defined as commercial use, and includes (1) integration of all or part
#   of the source code or the Software into a product for sale or license
#   by or on behalf of Licensee to third parties or (2) use of the
#   Software or any derivative of it for research with the final aim of
#   developing software products for sale or license to a third party or
#   (3) use of the Software or any derivative of it for research with the
#   final aim of developing non-software products for sale or license to a
#   third party, or (4) use of the Software to provide any service to an
#   external organisation for which payment is received. If you are
#   interested in using the Software commercially, please contact Isis
#   Innovation Limited ("Isis"), the technology transfer company of the
#   University, to negotiate a licence. Contact details are:
#   innovation@isis.ox.ac.uk quoting reference DE/1112.

Usage() {
    echo ""
    echo "Provides conjuction thresholding outside of feat.  IF, however, relevant feat"
    echo "directory is available, specify the smoothness estimate with -s option"
    echo "to get more accurate P-values."
    echo " "
    echo "Usage: easythresh_conj [-s SmoothEst] <raw_zstat1> <raw_zstat2> <brain_mask> <cluster_z_thresh> <cluster_prob_thresh> <background_image> <output_root> [--mm]"
    echo " "
    echo "e.g.:  easythresh_conj stats/zstat1 stats/zstat2 mask 2.3 0.01 example_func grot"
    echo "or, more accurately,"
    echo "       easythresh_conj -s stats/smoothness stats/zstat1 stats/zstat2 mask 2.3 0.01 example_func grot"
    echo ""
    echo "Or:    easythresh_conj <stat1> <stat2> <stat_thresh> <background_image> <output_root>"
    echo "e.g.:  easythresh_conj stats/zstat1 stats/zstat2 2.3 example_func grot"
    echo ""
    exit 1
}

if [ "$6" = "" ] ; then
    [ "$5" = "" ] && Usage
    ${FSLDIR}/bin/fslmaths $1 -min $2 zstat_min_$5
    MAX=`${FSLDIR}/bin/fslstats zstat_min_$5 -R | awk '{print $2}'`
    ${FSLDIR}/bin/overlay 1 0 $4 -a zstat_min_$5 $3 $MAX rendered_$5
    ${FSLDIR}/bin/slicer rendered_$5 -A 750 rendered_$5.png
    exit
fi

if [ "$1" = "-s" ] ; then
    SmoEst="$2"
    shift 2
fi

[ "$7" = "" ] && Usage

${FSLDIR}/bin/fslmaths $1 -min $2 zstat_min_$7

if [ "$SmoEst" = "" ] ; then
    # estimate image smoothness
    SM1=`${FSLDIR}/bin/smoothest -z $1 -m $3`
    SM2=`${FSLDIR}/bin/smoothest -z $2 -m $3`
    
    DLH1=`echo $SM1 | awk '{print $2}'`
    DLH2=`echo $SM2 | awk '{print $2}'`
    # Average DLH
    DLH=`echo "( $DLH1 + $DLH2 ) / 2.0" | bc -l`   
    # #  Take max of DLH's (worst roughness) - More conservative option
    # DLH=`echo "if ($DLH1 > $DLH2) $DLH1 else $DLH2" | bc`
    
    VOLUME=`echo $SM1 | awk '{print $4}'`  # Same mask, so volume should be identical

    RESELS1=`echo $SM1 | awk '{print $6}'`
    RESELS2=`echo $SM2 | awk '{print $6}'`
    # Average RESELS
    RESELS=`echo "( $RESELS1 + $RESELS2 ) / 2.0" | bc -l`
    # # Take max of RESELS (most conservative) - More conservative option
    # RESELS=`echo "if ($RESELS1 > $RESELS2) $RESELS1 else $RESELS2" | bc`
else
    if [ ! -f $SmoEst ] ; then
	echo Cannot find smoothness estimate
	exit
    fi
    DLH=`grep    DLH    $SmoEst | awk '{print $2}'`
    VOLUME=`grep VOLUME $SmoEst | awk '{print $2}'`
    RESELS=`grep RESELS $SmoEst | awk '{print $2}'`
fi

#echo "$DLH $VOLUME $RESELS"


# run clustering after fixing stats header for talspace
${FSLDIR}/bin/fslmaths zstat_min_$7 -mas $3 thresh_$7
${FSLDIR}/bin/fslcpgeom $6 thresh_$7
echo ${FSLDIR}/bin/cluster -i thresh_$7 -t $4 -p $5 --volume=$VOLUME -d $DLH -o cluster_mask_$7 --othresh=thresh_$7 $8
${FSLDIR}/bin/cluster -i thresh_$7 -t $4 -p $5 --volume=$VOLUME -d $DLH -o cluster_mask_$7 --othresh=thresh_$7 $8 > cluster_$7.txt

if [ `${FSLDIR}/bin/fslstats cluster_mask_$7 -R | awk '{print $2}'` = "0.000000" ] ; then
    echo 'No clusters to render!'
    exit
fi

# colour rendering
MAX=`${FSLDIR}/bin/fslstats thresh_$7 -R | awk '{print $2}'`
${FSLDIR}/bin/overlay 1 0 $6 -a thresh_$7 $4 $MAX rendered_thresh_$7
${FSLDIR}/bin/slicer rendered_thresh_$7 -A 750 rendered_thresh_$7.png

