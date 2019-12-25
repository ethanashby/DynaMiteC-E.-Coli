% finds the impulse parameters and the prior that minimizes the error function for a single gene from the list of genes. 
% the results are saved to a temporary file, to be processed later with 'get_priors.m'
% INPUT:
%   option      - option for fit_impulse_params_priors
%                   1. not constrained, no priors (chechik model)
%                   2. constrained, no priors (improved chechik) default
%                   3. constrained, priors (our model)
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

function fit_gene(option, data_file, priors_file, tmp_dir, ind, retries, weight)
    
    param = nan(1,7);
    clust = nan;
    score = inf;
    
    load (data_file, 'data', 'x', 'stdev');
    y = data(ind, :); 
    
    if option~=3
        [param, ~] = fit_impulse_params_priors(x, y, retries, option);
        clust = 1; %dummy for get_priors
        save(sprintf('%s/tmp%i.mat', tmp_dir, ind), 'param', 'clust');
        return;
    end    
    
    weight = weight./stdev;
    
    load (priors_file, 'priors');
    m = size(priors,1); 

    for k = 1:m
      if isnan(priors(k,1)), continue;  end
      try 
        [p, s] = fit_impulse_params_priors(x, y, retries, option, priors(k,:), weight);
      catch e
        fid = fopen('error.txt', 'a');
        fprintf(fid, '%s\t%u\t%u\n%s\n---\n', priors_file, k, ind, getReport(e));
        fclose(fid);
        s = inf;
      end
   
      if s < score
        param = p;
        clust = k;
        score = s;
      end      
    end
    
    save(sprintf('%s/tmp%i.mat', tmp_dir, ind), 'param', 'clust');
    
end
