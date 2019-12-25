% calculates new priors according to fitting results.
% INPUT:
%	data_file - filename of .mat file, containing:
%				  	1. 'data' - a matrix; rows are genes and columns are expression values at time points.
%				  	2. 'x' - a row vector of time points
%	tmp_dir   - where temporary files called 'tmpX.mat' for each gene were saved. each file contains:
%					1. 'param' - the parameters that minimized the error function for this gene; row vector
%					2. 'clust' - the number of the prior which minimized the error function, which is also the number of the cluster 
%								 that this gene is assigned to; scalar
%	out_dir	  - where output files should be saved.
%	retries   - how many times to restart the CGD with random parameters to compute the priors
% 	iter      - the current iter
%	n         - how many genes
% OUTPUT:
%	for each gene, the following output files are saved in out_dir:
%	1. 'iterX.mat' contains: 
%		a. 'clusters' - a column vector, each row contains the cluster assignment for each gene
%		b. 'params'   - a matrix, each row contains the parameters that minimized the error function for each gene
%	2. 'priorsX.mat' contatins 'priors' for that iteration				

function get_priors(data_file, tmp_dir, out_dir, retries, iter, n)	

load(data_file, 'data', 'x');

if nargin<6, n = size(data,1); end

params   = nan(n,7);
clusters = nan(n,1);

for i = 1:n
    load (sprintf('%s/tmp%i.mat', tmp_dir, i), 'clust', 'param');
    params(i,:) = param;
    clusters(i) = clust;
end

m = max(clusters);
priors = nan(m,7);

for k = 1:m
    genes = data(clusters == k, :); 
    if size(genes, 1) > 0
        avg = mean(genes, 1); 
        [priors(k,:),~] = fit_impulse_params_priors(x, avg, retries, 2); 
    else
        priors(k,:) = nan(1,7); 
    end
end

save(sprintf('%s/iter%u.mat', out_dir, iter), 'clusters', 'params');
save(sprintf('%s/priors%u.mat', out_dir, iter), 'priors');

end
