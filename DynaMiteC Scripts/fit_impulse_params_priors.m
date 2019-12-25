% Given time-points and expression results caclulate the seven impulse function parmaters as
% described in Gal Chechick paper. The function chooses the best parmaters
% from n_restarts tries. In each try the function run Conjection Gradient to
% find the best parametrs using matlab function fminunc.
% Notice the constraints in fit_params_con
% INPUT:
%   x - time points; row vector
%   y - expression results; row vector
%   n_times - how many times to restart the CGD; scalar
%   prior   - a matrix; each row contains the parameters of a different prior
%   weight  - when minimizing according to a prior, this is the weight of the prior; row vector 	
%   option  - 1. not constrained, no priors (chechik model)
%             2. constrained, no priors (improved chechik) default
%             3. constrained, priors (our model)
% OUTPUT:
%	best_p     - the parameters that minimized the error function; row vector
% 	best_score - the value of the error function with the best_p parameters; scalar

function [best_p best_score]=fit_impulse_params_priors(x, y, n_times, option, prior, weight)

if nargin<4
    option = 2;
elseif option==3
    weight = weight.*[1 1 0.1 1 0.1 0.1 0.1];
end

%set minimum difference between base, peak and steady state heights
global MIN_H_DIFF
MIN_H_DIFF = 0.5;
if max(y)-min(y)<2*MIN_H_DIFF
    MIN_H_DIFF = 0;
end

%set minimum difference between onset and offset times
global MIN_T_DIFF
MIN_T_DIFF = min(pdist(x'));

if option==1
    [best_p best_score]=fit_params_unc(@fun,x,y,n_times);
else
    [best_p best_score]=fit_params_con(@fun,x,y,n_times);
end

%return the loglikelihood of the impulse function and its gradient
%This function build to fit the fminunc
    function [err, g_err] = fun(param)
        if option==3
            err = impulse_err_priors(param, x, y, prior, weight);
            g_err = impulse_grad_err_priors(param, x, y, prior, weight);
        else
            err=impulse_err(param,x,y,2);
            g_err=impulse_grad_err(param,x,y,2);
        end
    end

end

% run the equation exactlly like Gal Chechik descritption without any new
% conditions to fit our data
function [best_p best_score]=fit_params_unc(fun,x,y,n_restarts)

%set the option for the fminunc function
options = optimset('GradObj','on','Display','off');

%variables to hold the maximum
best_score = inf;
best_p = NaN(1,6);

for i=1:n_restarts
    
    %choose the random parameters
    p_0=choose_rand_params(x,y);    
    
    %remove second slope, as in original chechik function
    p_0 = p_0(1:6);
    
    %find the minimum using fminunc function
    [p,fval,fl,ou]=fminunc(fun,p_0,options); %#ok<NASGU>
    
    %if this gradient gave us the best score, take its parameters
    if fval<best_score
        best_score=fval;
        best_p=p;
    end
    
end

b2 = best_p(6);
best_p = [best_p, -1*b2];

end

%add some condition to the equations to make them to fit more to our data
function [best_p best_score]=fit_params_con(fun,x,y,n_restarts)

% constraints:
% height values h_0, h_1, h_2 are all between min(y) and max(y)
% time values t_1, t_2 are larger than 0
% slope values beta_1>=0, beta_2<=0
% t_1 >= t_2
lb=[min(y) min(y) min(y)   0   0   0 -inf ];
ub=[max(y) max(y) max(y) inf inf inf    0 ];

A=[0,0,0,1,-1,0,0];
b=0;

%set the option for the fmincon function
options = optimset('GradObj','on','TolFun',10^-6,'Algorithm','active-set','Display','off');

best_score = inf;
best_p = nan(7,1);

%run the conjanction gradient n_restart times, and choose the best params
for i=1:n_restarts
    
    %choose the random parameters
    p_0=choose_rand_params(x,y);

	[p, fval] = fmincon(fun,p_0,A,b,[],[],lb,ub,@myconstr,options);

    if fval < best_score
        best_score = fval;
        best_p = p;
    end
    
end

end

%nonlinear constraints
function [c, ceq] = myconstr(x)

global MIN_H_DIFF
global MIN_T_DIFF

%(h1-h0) and (h1-h2) should have the same sign
c(1) = (x(2)-x(1))*(x(3)-x(2));

%abs(h1-h0)>=MIN_DIFF
c(2) = MIN_H_DIFF - abs(x(2)-x(1));

%abs(h1-h2)>=MIN_DIFF
c(3) = MIN_H_DIFF - abs(x(2)-x(3));

%abs(t2-t1)>=MIN_DIFF
c(4) = MIN_T_DIFF - abs(x(5)-x(4));

ceq = [];
end


%choose smart start points according to the given data
function p_0=choose_rand_params(x,y)

h_0 = 0;
[~, max_ind]=max(abs(y));
h(1)=y(max_ind);
h(2)=mean(y(end-1:end));
t(1)=rand*x(max_ind);
t(2)=x(max_ind)+t(1);
beta1 = rand;
beta2 = -1*rand;
p_0 = [h_0, h(1), h(2), t(1),t(2), beta1, beta2];
end
