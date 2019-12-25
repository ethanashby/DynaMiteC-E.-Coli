%function err=impulse_err(param,x,y,l)
%l is the order  of the function (1 or 2)
function err=impulse_err(param,x,y,l)
if nargin < 4, l=2; end
if l<1 || l>2, error('ERROR: function order had to be 1 or 2'); end
fun=@impulse;
if length(param)==3
    fun=@up_impulse;
end    
err=0.5*sum(abs((fun(param,x)-y).^l));
end

