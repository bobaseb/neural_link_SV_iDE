#!/bin/sh

# set paths
bids_path=#ADD FULL PATH HERE WITHOUT / AT THE END
event_files_path=#ADD FULL PATH HERE WITHOUT / AT THE END

# remove old event files
rm ${bids_path}/sub-*/func/*_events.tsv

# copy correct files
 for subcount in 001 002 003 004 005 006 008 009 010 011 013 014 015 016 017 018 019 020 021 022 024 025 026 027 029 030 032 033 035 036 037 038 039 040 041 043 044 045 046 047 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 066 067 068 069 070 071 072 073 074 075 076 077 079 080 081 082 083 084 085 087 088 089 090 092 093 094 095 096 098 099 100 102 103 104 105 106 107 108 109 110 112 113 114 115 116 117 118 119 120 121 123 124

do
     sub_str=sub-${subcount}
     files_to_copy=${event_files_path}/${sub_str}_task-MGT_run-*_events.tsv
     dest_path=${bids_path}/${sub_str}/func/
     cp ${files_to_copy} ${dest_path}
done

echo finished organizing files

# make sure files were copied successfully
echo number of event files should be 432. It is currently:
ls ${bids_path}/sub-*/func/sub-*MGT*_events.tsv | wc -l