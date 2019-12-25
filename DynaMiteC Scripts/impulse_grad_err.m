function g_err=impulse_grad_err(param,x,y,l)
if nargin < 4, l=2; end
if l<1 || l>2, error('ERROR: function order had to be 1 or 2'); end
if length(param)==3
    g=up_impulse_grad(param,x);
    fun=@up_impulse;
else
    g=impulse_grad(param,x);
    fun=@impulse;
end
if l==1
    g_err=sum(repmat(sign(fun(param,x)-y),size(g,1),1).*g,2);
else
    g_err=sum(repmat((fun(param,x)-y),size(g,1),1).*g,2);
end
end
