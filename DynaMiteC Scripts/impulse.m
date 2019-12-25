%%*************************************************************************
% function res=impulse(param,x)
% Given 6 paramters and vector of time points calculate the value of the
% function in these time-points.
% This function work as described in Gal Chechik paper
% If there is 7 parameters use 2 slope paramters instead of one
%**************************************************************************
function res=impulse(param,x)
h_0=param(1); h_1=param(2); h_2=param(3); t_1=param(4); t_2=param(5);
beta=param(6);
s_1 = h_0 + (h_1 - h_0) * sigmoid(beta, t_1, x);
if length(param)==6
    s_2 = h_2 + (h_1 - h_2) * sigmoid(-beta, t_2, x);
elseif length(param)==7
    beta2=param(7);
    s_2 = h_2 + (h_1 - h_2) * sigmoid(beta2, t_2, x);
else
    error('ERROR: Wrong number of parameters');
end    
res=(s_1 .* s_2) ./ h_1;
end

