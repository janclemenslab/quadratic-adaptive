function [err, param] = DN(x, param)
tau = x(1);    % time scale of adaptation
off = x(2);    % baseline gain control - determines steady state firing rate
r0 =     0;    % baseline firing rate
r1 =     x(3); % response scale
n  =     1;    % exponent

param.tt = (0:param.RRrawLen-1);
switch lower(param.adaKernelType)                                 % build the gain control filter
   case 'exp'
      param.flt = normalizeSum(fliplr(exp(-param.tt/tau)))';
   case 'pow'
      param.flt = normalizeSum(fliplr( normalizeSum(1./(param.tt + tau))))';
end
param.gc = conv(abs(param.input), flipud(param.flt), 'full');     % get the gain control signal
param.gc = param.gc(1:end-param.RRrawLen+1);                      % trim to right size
% param.pred = r0 + r1*off.^n*param.input.^n./(off.^n+param.gc.^n); % apply gain control
param.pred = r0 + r1.*param.input.^n./(off.^n+param.gc.^n); % apply gain control
err = mean( (param.pred(param.goodIdx)- param.resp(param.goodIdx)).^2 );                        % mean-squared error
