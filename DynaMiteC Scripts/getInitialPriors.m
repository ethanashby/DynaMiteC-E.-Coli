% finds initial set of k priors for given data, using kmeans according to specified distance measure.
% resulting initial priors and clusters will be saved in outfile.
% also, creates a mini-dataset, with maximum 'mini_size' values from each cluster, which can save some time when calculating the weight.
% plots a graph of the initial clusters and initial priors on top each cluster.
% INPUT:
%	datafile - filename of .mat file, containing:
%               1. 'data' - a matrix; rows are genes and columns are expression values at time points.
%				2. 'x' - a row vector of time points
%               3. 'stdev' - a row vector with the standard deviation of the params of the data (fit with no priors, then run std)
%   k        - number of wanted priors/clusters
%   outname  - name of output .mat file (without extension! '.priors.mat' will be appended to the outname), where initial priors and clusters will be saved.
%   dist     - distance measure for kmeans. 'correlation' (default) or 'sqEuclidean'
% OUTPUT:
%	priors   - the resulting initial priors
% OUTPUT-FILES:  
%   [outname '.priors.mat'] - initial priors and clusters
%   [outname '.mini.mat'] - file containing mini-dataset, with 'data', 'x' and 'stdev', can save some time when calculating the weight.

function priors = getInitialPriors(datafile, k, outname, dist)

if nargin<4, dist = 'correlation'; end

mini_size = 100;
load (datafile);

%remove values that will interfere with correlation kmeans
if strcmp(dist, 'correlation')
    X = data;
    [n, p] = size(X);
    X = X - repmat(mean(X,2),1,p);
    Xnorm = sqrt(sum(X.^2, 2));
    if min(Xnorm) <= eps * max(Xnorm)
        data = data(Xnorm~=min(Xnorm),:);
    end
end

d = nan(k*100,size(data,2));

IDX = kmeans(data, k, 'distance', dist);

priors = nan(k,7);
figure;
for i=1:k
    subplot(2,5,i);
    y = data(IDX==i,:);
    yn = min(mini_size, size(y,1));
    
    d((i-1)*mini_size+1:(i-1)*mini_size+yn,:) = y(1:yn,:);
    title(sprintf('n=%i',size(y,1)));
    plot(x,y,'b');
    xlim([0,max(x)]);
    hold on;
    y = mean(y);
    
    priors(i,:) = fit_impulse_params_priors(x, y, 100, 2);
    plot(x,y, '--r', 'LineWidth', 2);
end

suptitle(outname);

data = d(all(~isnan(d),2),:);
clusters = IDX;

save([outname '.priors.mat'], 'priors', 'clusters');
save([outname '.mini.mat'], 'data', 'x', 'stdev');


end
