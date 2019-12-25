#!/bin/sh
# -------------------------------------------
# --          use Bourne shell             --
#$ -S /bin/sh
# -------------------------------------------

tmp_dir=$1
out_dir=$2
name=$3
weight=$4
n=$5

if [ -s $priors_file ]; then 
    matlab -nodisplay -nodesktop -nojvm -r "getWeightError('$tmp_dir','$out_dir','$name',$weight,$n)" > /dev/null < /dev/null
    
    if [ -s $out_dir"/$name.weight$weight.mat" ]; then 
        echo "deleting $tmp_dir/weight$weight.tmp*"
       rm -rf $tmp_dir/weight$weight.tmp*
    fi
    
fi
