% calculates the gradient of the error function, with refernce to priors:
% grad_j = sum_i[f_prior(x_i) - y_i] + weight_j*[param_j - prior_j]
% INPUT:
%	param  - impulse function parameters (theta), row vector
%	x 	   - time points, row vector
%	y      - measured values at above time points, row vector
%	prior  - prior parameters, row vector
%	weight - weight factor, row vector
% OUTPUT:
%	g_err - error function gradient, column vector
function g_err = impulse_grad_err_priors(param, x, y, prior, weight)

g = impulse_grad(param, x);
size_g = size(g,1);

g_err = sum(repmat((impulse(param,x) - y), size_g, 1).*g, 2) + (weight.*(param - prior))';

end
