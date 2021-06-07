function [y,p] = fitPoly(t,x,deg,t2)
if nargin==3
   t2 = t;
end
%[y,p] = fitPoly(t,x,deg,t2)
p=polyfit(t,x,deg);
y=polyval(p,t2);   