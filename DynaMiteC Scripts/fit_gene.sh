#!/bin/sh
# -------------------------------------------
# --          use Bourne shell             --
#$ -S /bin/sh

option=$1
data_file=$2
priors_file=$3
tmp_dir=$4
retries=$5
weight=$6
ind=$SGE_TASK_ID
 
matlab -nodisplay -nodesktop -nojvm -r "fit_gene($option,'$data_file','$priors_file','$tmp_dir',$ind,$retries,$weight)" > /dev/null < /dev/null

