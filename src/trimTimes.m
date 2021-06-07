function [spikeTimes, stm] = trimTimes(spikeTimes, stimStart, stimEnd, period)
%
%[spikeTimes, stm] = trimTimes(spikeTimes, stimStart,
%stimEnd, period)
%
%ARGS
%   spikeTimes - cat x trial x times
%   stimStart  - ms
%   stimEnd    - ms
%   period     - ms
%
%RETURNS
%   spikeTimes- all periods as single trials
%   stm -       all spikeTimes of a cat appended to on trial
%
%created 06/12/05 Jan

%%
cats = size(spikeTimes,1);
trials = size(spikeTimes,2);

%% trim start and end
if isempty(stimEnd)
   stimEnd = max(spikeTimes(:));
end
if isempty(stimStart)
   stimStart = 0;
end

spikeTimes(spikeTimes(:)>stimEnd)=0;
spikeTimes = spikeTimes - stimStart;
spikeTimes(spikeTimes(:)<0)=0;


%% divide into periods
if not(isempty(period))

   PERIODS = ceil((stimEnd - stimStart)./period);
   nst = zeros(cats,trials*PERIODS, size(spikeTimes,3));
   for cat = 1:cats
      for trial = 1:trials

         periodNumber = ceil(spikeTimes(cat,trial,:)./period);
         periodTime = mod(spikeTimes(cat,trial,:), period);
         ps = unique(periodNumber);

         for p=2:length(ps)

            pIdx =find(periodNumber==ps(p));
            nst(cat,(trial-1)*PERIODS + (p-1) ,1:length(pIdx))= periodTime(pIdx);
         end

      end
   end

   spikeTimes = nst;

end

%% merge trials
if nargout>1
   if isempty(period)
      period = ceil(max(spikeTimes(:))/100)*100;
   end

   trials = size(spikeTimes,2);% updat trials

   %stm = zeros(cats,trials*size(spikeTimes,3));
   for cat = 1:cats
      tmp = [];
      for trial = 1:trials
         tmp = [tmp; (trial-1)*period + squeeze(spikeTimes(cat,trial,spikeTimes(cat,trial,:)>0))];
      end

      stm(cat,1,1:length(tmp)) = tmp;
   end
end





