function totalWeightErr

dir = 'priors';

k = 7;
nk = length(k);
w = [0 0.01 0.1 1 10];
nw = length(w);

err = nan(nk,nw);
pct = nan(nk,nw);

for i=1:nk
    [err(i,:), pct(i,:)] = totalWeightErrHelper(dir,sprintf('e%i',k(i)), w);
end

w
err
pct

figure;

plot(w, err, 'LineWidth',2);
hold on
plot(w, pct, '--','LineWidth',2);
set(gca, 'XScale', 'log');
legend('6','7','8','9','10');
xlabel('weight');
ylim([0,1]);

end


function [err, percent] = totalWeightErrHelper(base, name, w)
%w is a vector of weights, e.g -6:2

n = length(w);

err = nan(size(w));
percent = nan(size(w));

for i = 1:n
    
    load(sprintf('%s/%s.output/%s.weight%g.mat', base , name, name,w(i)), 'mean_err', 'mean_percent');
    err(i) = mean_err;
    percent(i) = mean_percent;
end

end