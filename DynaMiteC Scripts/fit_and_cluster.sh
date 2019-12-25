#!/bin/sh

#load configuration file
config_file=impulse.conf

if [ -f $config_file ]
then
    . $config_file
else 
    echo "ERROR: configuration file $config_file does not exist"
    exit
fi

usage="USGAE:\nfit_and_cluster.sh <from iteration> <until iteration>\nor\nfir_and_cluster.sh -nopriors"

mkdir -p $out_dir
mkdir -p $tmp_dir

if [ "$1" != "" ]
then
    cur_iter=$1
else
    echo $usage
    exit
fi

if [ "$2" != "" ] 
then
    iters=$2
else
    echo $usage
    exit
fi

echo data_file = $data_file
echo priors_file = $priors_file
echo out_dir = $out_dir
echo tmp_dir = $tmp_dir
echo weight  = $weight
echo retries = $retries
echo n = $n
echo from_iter = $cur_iter
echo until_iter = $iters

fit_option=3

if [ "$2" = "-nopriors" ]
then
    echo NO PRIORS!
    fit_option=2
    priors_file=0
    weight=0
fi

while [ $cur_iter -le $iters ]
do

    prev_iter=`expr $cur_iter - 1`
    hold_a="B$prev_iter$name"

    if [ $prev_iter -ne 0 ] 
    then
        
        priors_file="$out_dir/priors$prev_iter.mat"
    fi

    echo priors file = $priors_file

    qsub -wd $sh_dir -o $sge_out -j y -t 1-$n:1  -r y -N A$cur_iter$name -hold_jid $hold_a fit_gene.sh $fit_option $data_file $priors_file $tmp_dir $retries $weight
    qsub -wd $sh_dir -o $sge_out -j y -t 1-$n:$n -r y -N B$cur_iter$name -hold_jid A$cur_iter$name get_priors.sh $data_file $tmp_dir $out_dir $retries $cur_iter $n

   cur_iter=`expr $cur_iter + 1`
   
done