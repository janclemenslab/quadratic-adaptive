function [spec, freq, amp,phase,specMean, specStd] = getSpec(data,Fs, varargin)
% GET FOURIER SPECTRUM
%   [spec, freq, amp,phase] = getSpec(data,Fs)
%
%ARGS
%   data    trials/categories x time
%   Fs      data sampling freq in Hz
%   fftLen   - OPTIONAL
%   window  string containing window name (see WINDOW) - OPTIONAL
%
%RETURNS
%   spec    single-sided complex spectrum
%   freq    frequencies at which spec is evaluated
%   amp     amplitudes
%   phase   phases
%   specMean mean over all cats
%   specStd  std over all cats
%
%created 06/09/09 Jan
%last modified 07/06/23 Jan
%

cats = size(data,1);
sigLen = min(size(data,2));
%% set fftLen
if nargin>2
    fftLen = varargin{1};
else
    fftLen = size(data,2);
end

%% set window
if nargin>3
    win = window(str2func(varargin{2}), sigLen)';
else
    win = ones(1,sigLen);
end
%% prealloc var's
spec = zeros(cats,ceil(fftLen/2));
amp = spec;
phase = spec;

%% calc spec
for cat = 1:cats

    dataTmp = squeeze(data(cat,:)).* win;
    specTmp = fft(dataTmp, fftLen);
    specTmp = specTmp(1:ceil(fftLen/2))/sigLen;
    spec(cat,:) = specTmp;

    freq = (0:ceil(fftLen/2)) * Fs/fftLen;

    ampTmp = abs(specTmp)*2;
    ampTmp(1) = abs(specTmp(1));
    amp(cat,:) = ampTmp;

    phaseTmp = angle(specTmp);
    phase(cat,:) = phaseTmp;
end
%%  calc mean and std
specMean = mean(spec);
specStd = std(spec);
