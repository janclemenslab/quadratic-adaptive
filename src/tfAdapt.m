function [xMean,yMean, xSE, ySE, G] = tfAdapt(x,y,nBins)
% choses bin width such that each bin is populated by the same amount of
% data
%[xMean,yMean, xSE, ySE] = tfAdapt(x,y,nBins)

[~, sortIdx] = sort(x);
rawIdx = 1:length(sortIdx);
G = ceil(rawIdx/max(rawIdx)*nBins);
[xMean, xSE] = grpstats(x(sortIdx), G, {'nanmean' 'sem'});
[yMean, ySE] = grpstats(y(sortIdx), G, {'nanmean' 'sem'});
