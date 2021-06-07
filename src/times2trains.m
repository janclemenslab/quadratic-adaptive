function [trainMean, trainStd, trains] = times2trains(spikeTimes, binSize)
%
%[trainMean, trainStd, trains] = times2trains(spikeTimes, binSize)
%
%ARGS
%   spikeTimes - cats x trials x times
%   binSize    - in ms
%
%RETURNS
%   trainMean
%   trainStd
%   train
%
%created 06/11/27 Jan


spikeTimes = ceil(spikeTimes./binSize);

cats = size(spikeTimes,1);
trials = size(spikeTimes,2);
maxTime = ceil(max(spikeTimes(:))/10)*10;

trains = zeros(cats,trials,maxTime);

for cat = 1:cats
    for trial = 1:trials    
       trains(cat,trial,spikeTimes(cat,trial,spikeTimes(cat,trial,:)>0)) = 1;
    end
end

trainMean = reshape(mean(trains,2),cats,size(trains,3));%squeeze(mean(trains,2));
trainStd = reshape(std(trains,[],2),cats,size(trains,3));%squeeze(std(trains,[],2));