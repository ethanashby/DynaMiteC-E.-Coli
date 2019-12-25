% finds the impulse parameters and the prior that minimizes the error function for a single gene from the list of genes. 
% the results are saved to a temporary file, to be processed later with 'get_priors.m'
% INPUT:
%	data_file   - filename of .mat file, containing:
%				  	1. 'data' - a matrix; rows are genes and columns are expression values at time points.
%				  	2. 'x' - a row vector of time points
%                   3. 'stdev' - a row vector with the standard deviation of the params of the data (fit with no priors, then run std)
%	priors_file - filename of .mat file containing a matrix called 'priors'; rows are current priors, cols are parameters
%                 if priors_file==0, then do normal fit, without priors            
%	tmp_dir		- where temporary result files are saved
%	ind			- index of the gene in the list of genes
%	retries		- how many times to restart the CGD with random parameters
%	weight 		- the weight row vector. should be normalized!
% OUTPUT:
%	for each gene, a temporary file 'tmpX.mat' (X = ind) is saved with:
%		1. 'param' - the parameters that minimized the error function for this gene; row vector
%		2. 'clust' - the number of the prior which minimized the error function, which is also the number of the cluster 
%					 that this gene is assigned to; scalar

function checkWeight(data_file, priors_file, tmp_dir, ind, retries, weight)

    addpath('..');

    k=5;
    
    
    load (data_file, 'data', 'x', 'stdev');
    t = length(x);
    y = data(ind, :);
    
    w = weight./stdev;
    
    load (priors_file, 'priors');
    m = size(priors,1); 
    
    loo_ind = crossvalind('Kfold', k, t);
    tp = x(loo_ind);
    
    loo_val = y(loo_ind);
    
    err = nan(k,1);
    clusters = nan(k,1);
    
    for j = 1:k
    
        param = nan(1,7);
        clust = nan;
        score = inf;
       
        cur_y = y(1:t~=loo_ind(j));
        cur_x = x(1:t~=loo_ind(j));
        
        for i = 1:m
            if isnan(priors(i,1)), continue;  end
            try
                [p, s] = fit_impulse_params_priors(cur_x, cur_y, retries, 3, priors(i,:), w);
            
            if s < score
                param = p;
                clust = i;
                score = s;
            end
            
            catch e
            end
            

        end
        
        clusters(j) = clust;
        err(j) = (loo_val(j) - impulse(param, tp(j))).^2;
    end
    
    percent = getClustersPercent(clusters);
    err = nanmean(err,1);
    save(sprintf('%s/weight%g.tmp%i.mat', tmp_dir, weight, ind), 'err', 'percent');
    
end

function percent = getClustersPercent(C)

uniq = unique(C);
n = size(uniq,1);
percent = nan(n,1);

for i = 1:n
    percent(i) = sum(C==uniq(i));
end

percent = max(percent)/length(C);

end