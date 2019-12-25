function getWeightError(tmp_dir, out_dir, name, weight, n)

total_err = nan(n,1);
total_percent = nan(n,1);

for i=1:n
    try
    load (sprintf('%s/weight%g.tmp%i.mat', tmp_dir, weight, i), 'err', 'percent');
    total_err(i) = err;
    total_percent(i) = percent;
    catch e
    end
end

mean_err = nanmean(total_err);
nan_percent = total_percent(~isnan(total_err));
mean_percent = mean(nan_percent);

save(sprintf('%s/%s.weight%g.mat', out_dir, name, weight), 'mean_err', 'mean_percent', 'total_err', 'total_percent');

end