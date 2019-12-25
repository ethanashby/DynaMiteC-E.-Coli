% draws different figures. see each section for details
%INPUT:
%   datafile - .mat file with the following variables:
%              'data' - matrix with measurements (or log ratio of measurements) at time points 
%              'x'    - vector with time points
%   base     - dir with output files
%   iter     - iteration number
%   type1    - if the data contains two experiments, this is the label of the first experiment (first half of 'data'), e.g. "ko" or "lps"
%   type2    - this is the label of the second half, e.g., "wt" or "pic"
%   relabel   - relabeling for clusters, optional. e.g., [3 1 2] makes cluster3 first, cluster1 second, and cluster2 third.

function priors = analyseClusters(datafile, base, iter, type1, type2, relabel)
%% init
BINS = 50;

load(datafile,'data', 'x');
load(sprintf('%s/iter%u.mat', base, iter), 'clusters', 'params');
load(sprintf('%s/priors%u.mat', base, iter), 'priors');

tp = length(x);
n = size(clusters,1);
k = size(priors,1); 

if ismember('relabel', who)
    [~, new_loc] = ismember((1:k)', relabel);
    clusters = new_loc(clusters);
    priors = priors(relabel, :);
end

maxy = max(max(data));
miny = min(min(data));

halfn = n/2;
data1 = data(1:halfn,:); 
data2 = data(halfn+1:end,:);

c1 = clusters(1:halfn);
c2 = clusters(halfn+1:end);

p1 = params(1:halfn,:);
p2 = params(halfn+1:end,:);

clim = max(abs(miny),abs(maxy));
clims = [-clim,clim];

scrsz = get(0,'ScreenSize');

%% draw clusters

drawClusters(data, priors, x, clusters, sprintf('%s, iter=%i', base, iter), 1, 1);

%% draw wt/ko hist

figure('Position',[scrsz(3)/3 1 scrsz(3)/3 scrsz(4)/3], 'Name', sprintf('iter %u - wt/ko histograms', iter) ,'NumberTitle','off');
hist([wt, ko],m);
legend('wt','ko');
ylabel('#genes');
xlabel('cluster');


%% draw moves

mat = zeros(k,k);

for i=1:halfn
    if ~any(isnan([c1(i) c2(i)]))
    mat(c1(i), c2(i)) = mat(c1(i), c2(i))+1; 
    end
end
mat = mat./repmat(sum(mat, 1),k,1);

figure;
imagesc(mat');
xlabel([type1 ' clusters'],'Fontsize',14); 
ylabel([type2 ' clusters'],'Fontsize',14); 

figure;
bar3(mat');
xlabel([type1 ' clusters'],'Fontsize',14); 
ylabel([type2 ' clusters'],'Fontsize',14); 

figure;
bar(mat', 'hist');
grid on
set(gca,'Layer','top')
colormap(getColors)
set(gca,'Fontsize',14); 
xlabel([type2 ' clusters'],'Fontsize',14); 
ylabel('frequency','Fontsize',14); 
leg = [repmat([type1 ' cluster '], k, 1), num2str((1:k)')];
legend(cellstr(leg),'fontsize',10);

%% draw diff hist

figure;
pnames = {'h1','h2','t1','t2'};
colormap getColors
for i=2:5
    subplot(2,2,i-1);
    minp = min(min(params(:,i)));
    maxp = max(max(params(:,i)));
    absp = max(max(abs(params(:,i))));
    lims = [-absp,absp];
    scatter(p1(:,i),p2(:,i),10, c2,'filled');
    xlabel(type1, 'fontsize', 14);    
    ylabel(type2, 'fontsize', 14);    
    axis tight;
    hold on;
    plot(lims,lims,'k',lims,lims+1,'k',lims+1,lims,'k');
    set(gca, 'fontsize', 14);    
    
    title(pnames{i-1});
end

%% draw h and t differences scatter plot

figure;
colormap getColors
scatter(p2(:,4)-p1(:,4),p2(:,2)-p1(:,2),10,c2,'filled');
xlabel(sprintf('t1(%s) - t1(%s)', type2, type1), 'fontsize', 14);
ylabel(sprintf('h1(%s) - h1(%s)', type2, type1), 'fontsize', 14);
axis tight;
set(gca, 'fontsize', 14);

%% draw param hists

name = sprintf('iter %u - parameters histograms', iter);
figure('Position', [1 1 2/3*scrsz(3) scrsz(4)/2], 'Name', name ,'NumberTitle','off');
drawHist(params);
suptitle(name);

    function drawHist(M)
        c = clusters;
        set(gcf,'DefaultAxesColorOrder',getColors);
        pNames = {'h_0 (base)', 'h_1 (peak)', 'h_2 (steady state)', 't_1 (onset time)', 't_2 (offset time)', '\beta_1 (onset slope)', '\beta_2 (offset slope)'};
        pXtitle = {'log ratio expression', 'log ratio expression', 'log ratio expression', 'time', 'time', [], []};
        pYtitle = {'percent of genes in cluster', [], [], 'percent of genes in cluster', [], [], []};
        for i=1:7
            subplot(2,4,i);
            if i>3, subplot(2,4,i+1); end
            nbins = nan(BINS, k);
            p = M(:,i);
            lin = linspace(min(p), max(p), BINS);
            for j=1:k
                nbins(:,j) = hist(p(c==j), lin)/sum(c==j);
            end
            plot(lin, nbins, 'LineWidth', 2);
            title(pNames{i},'Fontsize',14);
            xlabel(pXtitle{i},'Fontsize',14);
            ylabel(pYtitle{i},'Fontsize',13);
            set(gca,'Fontsize',14); 
        end        
    end


%% draw histogram scatter plots


name = sprintf('iter %i - parameters space',iter);
figure('Position', [1 1 scrsz(3) scrsz(4)], 'Name', name ,'NumberTitle','off');
colors = getColors;
colors = colors(1:k,:);
colormap(colors);
paramNames = {'h0','h1','h2', 't1','t2','b1','b2'};
for i=1:7
    for j=i+1:7
        subplot(6,6,(i-1)*6+j-1);
        scatter(params(:,i),params(:,j),3,clusters,'filled');
        hold on;
        scatter(priors(:,i),priors(:,j),40,1:k,'filled', 'markeredgecolor','k');
        xlabel(paramNames{i},'Fontsize',14); 
        ylabel(paramNames{j},'Fontsize',14); 
        set(gca,'Fontsize',14); 
    end
end

suptitle(name);

%% draw imagesc per cluster
name = sprintf('iter %i - parameters space',iter);
figure;

nans  = nan(5,length(x));
d1 = nan(0,length(x));
d2 = nan(0,length(x));

for i=1:k

    d1 = [d1; nans; data1(c1==i,:)];
    d2 = [d2; nans; data2(c2==i,:)];
    
%     subplot(2,k,i);
%     imagesc(data1(c1==i,:), clims);
%     title(sprintf('n=%i',sum(c1==i)));
   
%     subplot(2,k,k+i);
%     imagesc(data2(c2==i,:), clims);   
%     title(sprintf('n=%i',sum(c2==i)));
    
end
subplot(1,2,1);
imagesc(d1,clims);
title(type1);
subplot(1,2,2);
imagesc(d2,clims);
title(type2);
colorbar('southoutside');
colormap redgreencmap;

%% draw sorted imagesc
figure;
dd = [data1, data2];
res = nan(0,2*length(x));
nans = nan(5,2*length(x));

for i=1:k
    cur_data = dd(c1==i,:);
    cur_c2 = c2(c1==i);
    for j=1:k
        res = [res; cur_data(cur_c2==j,:)];
    end
    res = [res; nans];
end

imagesc(res,clims);
title([type1 ' & ' type2]);
colorbar('eastoutside');
colormap redgreencmap;


% dlmwrite('figures/15priors.txt', ans, 'delimiter','\t', 'precision', '%6.3f');
end