#!/bin/bash

#load configuration file
config_file=weight.conf


if [ -f $config_file ]
then
    . $config_file
else 
    echo "ERROR: configuration file $config_file does not exist"
    exit
fi

echo pnames  = ${priors_array[@]}
echo weights = ${weights_array[@]}
echo retries = $retries
echo n = $n

for i in $(seq 0 $((${#priors_array[@]} - 1)))
do 
    pname=${priors_array[i]}

    data_file="$input_base/$pname.mini.mat"
    priors_file="$input_base/$pname.priors.mat"
    out_dir="$output_base/$pname.output"
    tmp_dir="$output_base/$pname.tmp"
    
    mkdir -p $out_dir
    mkdir -p $tmp_dir
    
    echo data_file = $data_file
    echo priors_file = $priors_file
    echo name = $pname
    echo out_dir = $out_dir
    echo tmp_dir = $tmp_dir
    
    for j in $(seq 0 $((${#weights_array[@]} - 1)))
    do
        weight=${weights_array[j]}
        echo weight = $weight
        qsub -wd $sh_dir -o $sge_out -j y -t 1-$n:1  -r y -ac long -N A$weight$pname weightA.sh $data_file $priors_file $tmp_dir $retries $weight
        qsub -wd $sh_dir -o $sge_out -j y -t 1-$n:$n -r y -N B$weight$pname -hold_jid A$weight$pname weightB.sh $tmp_dir $out_dir $pname $weight $n
    done    
done
