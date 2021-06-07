function stim = rms(stim,width)
%
%stim = rms(stim,width)
%
%ARGS
%   stim - catxtime
%   width - pts
%
%RETURNS
%   rms'ed stim
%
%created 06/11/30 Jan

%win = window(@flattopwin,width);

x =-3*width:1:3*width;
win = exp(-(x./width).^2);%gauss;
win = win./sum(win);

% win = window(@gausswin,width);
% win = win./sum(win);
stim = abs(stim);%.^2;
stim =  padarray(stim,[0 2*length(win)],'replicate','both');
for cat = 1:size(stim,1)
   stim(cat,:) = conv(stim(cat,:), win,'same');
end
stim = stim(:, 2*length(win)+1:end-2*length(win));
%stim = sqrt(stim);
