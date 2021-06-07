function [N,bins] = histcw(x,wt,nbin)
% HISTW Bin's weighted data into equally spaced bins
%
%       Usage:  [count,bins] = histw(x,wt,nbin)
%               x: Vector containing data values
%               wt: Vector size(x) caontaining weights for the data
%               nbin: number of bins


if length(nbin)==1
   bins=linspace(min(x),max(x),nbin);
else
   bins = nbin;
end
N = zeros(1,length(bins)+1);
for edg = 1:length(bins)-1
   N(edg) = sum(wt(x>bins(edg) & x<bins(edg+1)));   
end

N(edg+1) = sum(wt(x>bins(end)));
