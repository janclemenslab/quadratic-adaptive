function [err, param, paramDN] = Q(x, param, paramDN)

paramDN.input = param.mf.SSraw*x; % filter stimulus
[err, paramDN] = DN(paramDN.x, paramDN); % run through DN stage

