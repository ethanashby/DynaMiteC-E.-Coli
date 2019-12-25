%%*************************************************************************
% function res=sigmoid(beta, t, x)
% culculate the sigmoid for the impulse function as described in Gal
% Chechic paper
%%*************************************************************************
function res=sigmoid(beta, t, x)
res=1.0 ./ (1 + exp(-beta * (x - t)));
end