addpath(genpath('src'))
cc()
PLOT = true;
filename = 'dat/noise_20160311_8.mat';  % any file in `dat/` will work
filename = 'dat/step_20140625_1.mat';  % any file in `dat/` will work
load(filename)

% downsample stim and resp to speed up the demo 
dwnSmp = 2;
stim = resample(stim, 10, 10*dwnSmp);
resp = resample(resp, 10, 10*dwnSmp);
fs = fs / dwnSmp;
filtLen = 100;  % ms

param.adaKernelType = 'exp';
param.mlType = 'qn';
param.stimType = stimType;

param.stim = stim;
param.resp = resp;
if size(param.stim,1)==1
   param.stim = param.stim';
   param.resp = param.resp';
end


switch lower(param.adaKernelType)
   case 'exp'
      RRrawLen= 400/dwnSmp;
      LBtau = 1;
      X0tau = 14;
      X0off = 0.001;
   case 'pow'
      RRrawLen= 2000/dwnSmp;
      LBtau = eps;
      X0tau = 1;
      X0off = 1;
   otherwise
      error('unknow adaptation kernel type')
end
%% initialize object for fitting the MODEL; param.mlType: ln/qn
src = SpikeRespCont(reshape(param.resp,1,1,[]),1);
src.setStim(param.stim',1);

switch lower(param.mlType)
   case 'ln'
      param.mf = FeaturesMLlinBasis(src,filtLen/dwnSmp);
   case 'qn'
      param.mf = FeaturesMLquadBasis(src,filtLen/dwnSmp);
   otherwise
      error('unknow feature model type')
end
param.mf.getFeat(1);
param.feat0 = param.mf.feat;
param.h = param.mf.feat;
param.h0 = param.mf.h0;
param.h1 = param.mf.h1;
param.h2 = param.mf.h2;
param.pred = param.mf.pred;
param.perf = rsq(param.mf.pred, param.mf.Resp);
if strcmp(stimType, 'song')
   param.goodIdx = runningExtreme(rms(param.stim',64), 1001, 'max')>0.3;
else
   param.goodIdx = true(size(param.stim));
end
%% init FILTER problem
paramQN = param;
paramQN.SSraw = param.mf.SSraw;%
% paramQN.pred = param.mf.SSraw*paramQN.x0;
% set up bounds and initial conditions
paramQN.x0 = param.feat0;
paramQN.x = paramQN.x0;
paramQN.lb = repmat(min(paramQN.x0)-200, size(paramQN.x0,1),1);
paramQN.ub = repmat(max(paramQN.x0)+200, size(paramQN.x0,1),1);
% some flags
paramQN.withPlot = true;
paramQN.withNL = false;
paramQN.withMsg = true;
%% init ADAPTATION problem
paramDN = param;
paramDN.input = paramQN.pred;
paramDN.train = (1:length(paramDN.resp))';
% set up bounds and initial conditions
paramDN.RRrawLen= RRrawLen;
paramDN.lb = [LBtau eps 0];
paramDN.ub = [paramDN.RRrawLen/3 10 1000];
paramDN.x0 = [X0tau X0off 1];
paramDN.x = paramDN.x0;
% some flags
paramDN.withPlot = true;
paramDN.withNL = false;
paramDN.withMsg = true;
%%
optOptions = optimset('Algorithm','sqp', 'Display', 'iter', 'MaxFunEvals', 10000, 'MaxIter', 1000,...
   'TolX', 1e-9, 'TolFun', 1e-9, 'FinDiffType', 'central', 'FinDiffRelStep', 1e-6, 'AlwaysHonorConstraints','none');

paramQN.problem = struct('solver','fmincon','objective',@(x) Q(x, paramQN, paramDN),...
   'x0', paramQN.x0,'lb', paramQN.lb, 'ub', paramQN.ub, ...
   'options', optOptions);

paramDN.problem = struct('solver','fmincon','objective',@(x) DN(x, paramDN),...
   'x0', paramDN.x0,'lb', paramDN.lb, 'ub', paramDN.ub, ...
   'options', optOptions);

[err, paramDN] = DN(paramDN.x0, paramDN);
fprintf('initial error: %1.2f\n', err)
if PLOT
   subplot(1,5,1:4)
   plot([paramDN.resp(1e3:1e4/2) paramDN.pred(1e3:1e4/2)])
   drawnow
end
%%
tic
for run = 1:2
   paramDN.problem.objective = @(x) DN(x, paramDN);
   paramDN.problem.x0 = paramDN.x;
   paramDN.x = fmincon(paramDN.problem);
   [err, paramDN] = DN(paramDN.x, paramDN);
   fprintf(' DN run %d, mse: %1.2f, r^2: %1.2f\n', run, err, rsq(paramDN.resp, paramDN.pred))
   if PLOT
      subplot(1,5,1:4)
      plot([paramDN.resp(1e3:1e4/2) paramDN.pred(1e3:1e4/2)])
      title(sprintf('r^2=%1.2f', rsq(paramDN.resp, paramDN.pred)))
      axis('tight')
      drawnow
   end
   
   paramQN.problem.objective = @(x) Q(x, paramQN, paramDN);
   paramQN.problem.x0 = paramQN.x;
   paramQN.x = fmincon(paramQN.problem);
   [err, paramQN, paramDN] = Q(paramQN.x, paramQN, paramDN);
   fprintf('qDN run %d, mse: %1.2f, r^2: %1.2f\n', run, err, rsq(paramDN.resp, paramDN.pred))
   if PLOT
      subplot(1,5,1:4)
      plot([paramDN.resp(1e3:1e4/2) paramDN.pred(1e3:1e4/2)])
      title(sprintf('r^2=%1.2f', rsq(paramDN.resp, paramDN.pred)))
      axis('tight')
      drawnow
   end
   
   if PLOT
      param.mf.Resp = DNinverse(paramDN.pred, paramDN.gc, paramDN.x0(end-2:end));
      param.mf.getFeat(1)
      subplot(1,5,5)
      imagesc(triu(param.mf.h2) + triu(param.mf.h2)')
      axis('square')
      drawnow
   end
   
   if toc>48*60*60-10000
      warning('nearing end times - breaking out and saving everything we got so far...')
      break
   end
end
%%
[err, paramQN, paramDN] = Q(paramQN.x, paramQN, paramDN);
fprintf('final qDN result mse: %1.2f, r^2: %1.2f\n', err, rsq(paramDN.resp, paramDN.pred))

%%
% final step
% the resulting filter will not be regularized so will likely look crappy
% maybe find optimal filter given the expected output?
% 1. invert DN output of the final model to get input to the DN stage
param.mf.Resp = DNinverse(paramDN.pred, paramDN.gc, paramDN.x0(end-2:end));
% 2. fit regularized filter that reproduces the input to the DN stage
param.mf.getFeat(1)
if PLOT
   subplot(1,5,5)
   imagesc(triu(param.mf.h2) + triu(param.mf.h2)')
   axis('square')
   drawnow
end
paramQN.x = param.mf.h/norm(param.mf.h)*norm(paramQN.x);
paramDN.problem.objective = @(x) DN(x, paramDN);
paramDN.problem.x0 = paramDN.x;
paramDN.x = fmincon(paramDN.problem);
[err, paramDN] = DN(paramDN.x, paramDN);
if PLOT
   subplot(1,5,1:4)
   plot([paramDN.resp(1e3:1e4/2) paramDN.pred(1e3:1e4/2)])
   title(sprintf('r^2=%1.2f', rsq(paramDN.resp, paramDN.pred)))
   axis('tight')
   drawnow
end
[err, paramQN, paramDN] = Q(paramQN.x, paramQN, paramDN);
fprintf('final qDN w/ regularized filter mse: %1.2f, r^2: %1.2f\n', err, rsq(paramDN.resp, paramDN.pred))
%%
paramDN.h  = param.mf.h;
paramDN.h0 = param.mf.h0;
paramDN.h1 = param.mf.h1;
paramDN.h2 = param.mf.h2;
paramDN.perf = rsq(paramDN.pred, paramDN.resp);
%% get rid of redundant stuff to save space
param.mf = [];

paramDN.resp = [];
paramDN.stim = [];
paramDN.SSraw = [];
paramDN.mf = [];

paramQN.resp = [];
paramQN.stim = [];
paramQN.SSraw = [];
paramQN.mf = [];

% get rid of fun handles - saving them prevents the huge internally referenced matrices...
paramDN.objFunStr = func2str( paramDN.problem.objective );
paramDN.problem.objective = [];
paramQN.objFunStr = func2str( paramQN.problem.objective );
paramQN.problem.objective = [];

save(['res/' filename(5:end)], 'param','paramDN','paramQN', 'dwnSmp', 'fs')
