function drawClusters(data, priors, x, clusters, name, drawProfiles, sameScale)

if nargin<6, drawProfiles=1; end
if nargin<7, sameScale=1; end

scrsz = get(0,'ScreenSize');

k = max(clusters);
means = nan(k, length(x));
miny = min(min(data));
maxy = max(max(data));

t1  = priors(:,4);
yt1 = nan(size(t1));
t2  = priors(:,5);
yt2 = nan(size(t2));

ls = linspace(0,max(x));

%[dist from left, dist from bottom, width, height]
figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2], 'Name', sprintf(name) ,'NumberTitle','off');
set(gcf,'DefaultAxesColorOrder',getColors);
        
for i=1:k
    yt1(i) = impulse(priors(i,:),t1(i));
    yt2(i) = impulse(priors(i,:),t2(i));
    subplot(2, ceil(k/2), i);
    y = data(clusters==i,:);
    ny = size(y,1);
    meany = mean(y);
    dist = sum(abs(y - repmat(meany, ny, 1)), 2);
    
    c = colormap('summer');
    nc = size(c,1);
    dist = ceil(dist./max(dist)*nc);
    hold on;
    for j=1:ny
        
        plot(x, y(j,:), 'color', c(dist(j),:), 'linewidth', 1);
    end
    
%     plot(x, meany,'c','linewidth',2);
    plot(ls, priors2profiles(priors(i,:), ls), 'b','linewidth', 4);
    set(gca, 'fontsize', 16);
%     means(i,:) = meany;
    title(sprintf('n=%i', ny));
    xlim([0, max(x)]);
    if sameScale, ylim([miny,maxy]); end
   
end

suptitle(name);


if drawProfiles
    %[dist from left, dist from bottom, width, height]
    figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/4 scrsz(4)/2], 'Name', sprintf(name) ,'NumberTitle','off');
    set(gcf,'DefaultAxesColorOrder',getColors);
    plot(ls, priors2profiles(priors, ls), 'linewidth', 3);
    hold on;
    for i=1:k
        plot(t1(i),yt1(i), '^', t2(i),yt2(i), 'v','markeredgecolor','k','markerfacecolor', getColors(i), 'MarkerSize',8,'linewidth', 1);
        
    end
    leg = [repmat('cluster ', k, 1), num2str((1:k)')];
    legend(cellstr(leg),'fontsize',14);
    xlim([0, max(x)]);
    title(name);
end

end

