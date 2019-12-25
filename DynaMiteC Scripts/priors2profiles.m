function profiles = priors2profiles(priors,x)

m = size(priors,1);
profiles = nan(m,length(x));

for i=1:m
    profiles(i,:) = impulse(priors(i,:),x);
end

end


