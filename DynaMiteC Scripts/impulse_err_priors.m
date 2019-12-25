% calculates the error function, with refernce to priors:
% err(param, x, y, prior, weight) = 0.5*(sum_i([f_prior(x_i) - y_i]^2) + sum_j(weight_j*([param_j - prior_j]^2))
% INPUT:
%	param  - impulse function parameters (theta), row vector
%	x 	   - time points, row vector
%	y      - measured values at above time points, row vector
%	prior  - prior parameters, row vector
%	weight - weight factor, row vector
% OUTPUT:
%	err    - error function value, scalar
function err = impulse_err_priors(param, x, y, prior, weight)

err = 0.5*( sum(((impulse(param,x)-y).^2)) + sum(weight.*((prior-param).^2)) );

end

