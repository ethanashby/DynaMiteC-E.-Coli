#!/bin/sh
# -------------------------------------------
# --          use Bourne shell             --
#$ -S /bin/sh
# -------------------------------------------
          
data_file=$1
tmp_dir=$2
out_dir=$3
retries=$4
iter=$5
n=$6

matlab -nodisplay -nodesktop -nojvm -r "get_priors('$data_file','$tmp_dir','$out_dir',$retries,$iter,$n)" > /dev/null < /dev/null