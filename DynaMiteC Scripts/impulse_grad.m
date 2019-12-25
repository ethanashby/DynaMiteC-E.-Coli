function res= impulse_grad(param, x)
%prepare variables
h_0=param(1); h_1=param(2); h_2=param(3); t_1=param(4); t_2=param(5);
beta1=param(6);
sig_1 = sigmoid(beta1, t_1, x);
if length(param)==6
    sig_2 = sigmoid(-beta1, t_2, x);
elseif length(param)==7
    beta2=param(7);
    sig_2 = sigmoid(beta2, t_2, x);
else
    error('ERROR: Wrong number of parameters');
end
s_1 = h_0 + (h_1 - h_0) * sig_1;
s_2 = h_2 + (h_1 - h_2) * sig_2;
st_1 = s_2 ./ h_1 .* (h_1 - h_0) .* sig_1 .* (1 - sig_1);
st_2 = s_1 ./ h_1 .* (h_1 - h_2) .* sig_2 .* (1 - sig_2);

%caclulate the gradient
d_h_0 = s_2 ./ h_1 .* (1 - sig_1);
d_h_1 = (-s_1 .* s_2 ./ h_1 + s_2 .* sig_1 + s_1 .* sig_2) ./ h_1;
d_h_2 = s_1 ./ h_1 .* (1 - sig_2);
d_t_1 = st_1 .* (-beta1);

if length(param)==6
    d_t_2 = s_1 .* (h_1 - h_2) .* beta1 ./ h_1 .* sig_2 .* (1 - sig_2);
    d_beta = st_1 .* (x - t_1) + st_2 .* (t_2 - x);
    res=[d_h_0;d_h_1;d_h_2;d_t_1;d_t_2;d_beta];
elseif length(param)==7
    d_t_2 = st_2 .* (-beta2);
    d_beta1 = st_1 .* (x - t_1);
    d_beta2 = st_2 .* (x - t_2);
    res=[d_h_0;d_h_1;d_h_2;d_t_1;d_t_2;d_beta1;d_beta2];
end
end