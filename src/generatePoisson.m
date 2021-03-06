function [times] = generatePoisson(rate, refractoryAbsolute)
%
%[times] = generatePoisson(rate)
%
%ARGS:
%   rate    - vector of firing rate lambda in 1000Hz
%RETURNS:
%   times   - event (spike) times in ms
%


% Spikes are generated by an inhomogenous Poisson process with 
% refractory effects.
%
% Spikes are generated in three steps. 
% First, a spike train is generated by a _homogenous_ Poisson process
% with a rate equal to the peak instantaneous rate of the driving function.
% Spike times are derived from interspike intervals that follow an 
% exponential distribution.  The first spike is supposed to occur at 0.
% In a second step, spikes are weeded out probabilistically.  The probability 
% of "survival" of a spike is equal to the normalized driving function.
% In a third step, spikes are weeded out with a probabiltiy that depends
% on the interval that precedes them, to simulate refractory effects.

% First step:
maxRate = max(rate);		% peak instantaneous rate
rate = rate ./ maxRate;		% normalize
N = length(rate);
D = N;				% duration of driving function

% generate enough intervals to cover duration of driving function
% make random array with no zeros
while 1
	y = rand(1, ceil(D*maxRate));
	if all(find(y)) break; end;
end
z = -log(y) / maxRate;

% transform to times, remove any out of range of driving function
t = [0,cumsum(z)];
mask = t < N-1;
t = t .* mask;
t = nonzeros(t)';

% Second step:
% For each spike, draw a random number, and compare it to the
% instantaneous rate at the time of the spike.  Remove
% unlucky spikes.
ns = size(t, 2);
zz = rand(1, ns);
tt = fix(t) + 1;		% spike times expressed in samples
xx = rate(tt);				
mask = zz < xx;
t = mask .* t;

% % Third step:
% % Refractory effects: remove spikes preceded by interval shorter than 
% % the dead time.  This is a crude model of refractory effects.
if nargin>1 && ~isempty(t)
   t = spike_dead(t, refractoryAbsolute);
end

times = nonzeros(t)';
