#!/bin/sh
# -------------------------------------------
# --          use Bourne shell             --
#$ -S /bin/sh
# -------------------------------------------

data_file=$1
priors_file=$2
tmp_dir=$3
retries=$4
weight=$5
ind=$SGE_TASK_ID
 
matlab -nodisplay -nodesktop -nojvm -r "checkWeight('$data_file','$priors_file','$tmp_dir',$ind,$retries,$weight)" > /dev/null < /dev/null

