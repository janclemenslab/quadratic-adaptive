classdef FeaturesML < Features
   
   properties
      h, h0, h1, h2, hHist
      regH, regFitInfo
      RRraw, RRrawDelay, RRrawDeltaT
      pred, perf
      perfTest, perfTrain
      basis1D, basis2D, basisPrj
      khat
   end
   
   methods (Abstract)
      getSTEML(self)
      coef2kernel(self, varargin)
      kernel2coef(self, varargin)
   end
   
   methods (Access='public')
      
      function self = FeaturesML(sr, n)
         if isa(sr,'SpikeResp')
            self.sr = sr;
            self.n = n;
            self.getSTE();
         else
            disp('ERROR: arg #1 is not of class SpikeResponse');
         end
      end
      
      function getFeat(self, varargin)
         % getFeat([mode=0, trainIdx=all idx])
         % trainIdx==1 - use for training
         % trainIdx==0 - use for testing
         % otherwise   - ignore
         regMode = 0;
         if nargin>1
            regMode = varargin{1};
         end
         trainIdx = ones(size(self.Resp));
         if nargin>2
            trainIdx = varargin{2};
         end
         %% regression
         switch regMode
            case {1, 2} % empirical Bayes ridge or lasso
               self.khat = runRidgeOnly(self.SSraw(trainIdx==1,:), self.Resp(trainIdx==1), size(self.SSraw,2), 1);
               self.h = self.khat;
            case 3 % ALDsf
               self.khat = runALD(self.SSraw(trainIdx==1,:), self.Resp(trainIdx==1), size(self.SSraw,2), 1);
               self.h = self.khat.khatSF;
            case 4 % sparse GLM
               
            case 5 % standard ridge/lasso
               opts = statset('UseParallel','always');
               % parameter ALPHA interpolates between ridge (0) and lasso (1)
               alpha = 0.001;
               [self.regH, self.regFitInfo] = lasso(self.SSraw(trainIdx==1,:), self.Resp(trainIdx==1), 'Options', opts, 'alpha', alpha, 'NumLambda', 64, 'CV', 4);
               lamOpt = self.regFitInfo.Index1SE;
               self.h = self.regH(:,lamOpt);

            otherwise % standard least squares
               self.h = pinv(self.SSraw(trainIdx==1,:))*self.Resp(trainIdx==1);
         end
         
         % rearrange kernels to get terms corr. to diff. orders
         self.coef2kernel();
         % prediction
         self.pred = self.SSraw*self.h;
         self.perf = rsq(self.pred, self.Resp);
         self.perfTrain = rsq(self.pred(trainIdx==1), self.Resp(trainIdx==1));
         self.perfTest = rsq(self.pred(trainIdx==0), self.Resp(trainIdx==0));
         self.feat = self.h;
      end
      
      function getBasis1D(self, varargin)
         if nargin==2
            xs = varargin{1};
         else
            xs = size(self.SSraw,2);
         end
         sigma = 2;
         X = 1:xs;
         nBasis = self.n/2;
         
         self.basis1D = zeros(nBasis, xs);
         cnt = 0;
         xpts = linspace(0,xs,nBasis);
         for xidx = 1:length(xpts)
            x = xpts(xidx);
            mpsF = x;
            cpsF = sigma;
            nps = normpdf(X,mpsF,cpsF);
            cnt = cnt+1;
            self.basis1D(cnt,:) = nps;
         end
      end

      function getDeltaBasis1D(self, varargin)
         if nargin==2
            xs = varargin{1};
         else
            xs = size(self.SSraw,2);
         end
         self.basis1D = eye(xs);
      end

      function getNLBasis1D(self, varargin)
         if nargin==2
            xs = varargin{1};
         else
            xs = self.n;
         end
         kbaspr.neye = 0;
         kbaspr.ncos = round(xs/6);
         kbaspr.kpeaks = round([2 xs]);
         kbaspr.b = 128/50/2;
         self.basis1D = makeBasis_StimKernel(kbaspr,xs)';
      end
      
      function getBasis2D(self)
         n = size(self.SSraw,2);
         xs = n;
         ys = n;
         sigma = 3;
         [X1, X2] = meshgrid(1:xs,1:ys);
         nBasis = self.n/2;
         
         self.basis2D = zeros((nBasis^2 + nBasis)/2, n, n);
         cnt = 0;
         xpts = linspace(0,xs,nBasis);
         ypts = linspace(0,ys,nBasis);
         for xidx = 1:length(xpts)
            for yidx = xidx:length(ypts)
               x = xpts(xidx);
               y = ypts(yidx);
               mpsF = [x,y];
               cpsF = diag([sigma sigma]);
               nps = mvnpdf([X1(:) X2(:)],mpsF,cpsF);
               nps = reshape(nps,xs,ys)';
               %nps = nps + nps';
               cnt = cnt+1;
               self.basis2D(cnt,:,:) = nps;
            end
         end
      end

      function getNLBasis2D(self)
         n = size(self.SSraw,2);
         xs = n;
         ys = n;
%          sigma = 3;
         [X1, X2] = meshgrid(1:xs,1:ys);
         nBasis = self.n;
         
         self.basis2D = zeros((nBasis^2 + nBasis)/2, n, n);
         cnt = 0;
         xpts = linspace(0,xs,nBasis);
         ypts = linspace(0,ys,nBasis);
         for xidx = 1:length(xpts)
            for yidx = xidx:length(ypts)
               x = xpts(xidx);
               y = ypts(yidx);
               mpsF = [x,y];
               sigma = limit(abs(x-y), 1, inf)/2;
               cpsF = diag([sigma sigma]);
               nps = mvnpdf([X1(:) X2(:)],mpsF,cpsF);
               nps = reshape(nps,xs,ys)';
               %nps = nps + nps';
               cnt = cnt+1;
               self.basis2D(cnt,:,:) = nps;
            end
         end
      end

      function prj2Basis(self)
         basis = self.basis2D;
         n = size(self.SSraw,2);
         SSraw = self.SSraw;
         self.basisPrj = zeros(size(basis,1),size(SSraw,1));
         %%
         for b = 1:size(basis,1)
            bas = reshape(basis(b,:,:), n, n);
            if isempty(strfind(lower(class(self)),'basis'))
               self.basisPrj(b,:) = sum(SSraw'.*(bas*SSraw'));
            else
               % do this only for indices where the basis is nonzero
               % FIX: turned off for delta basis
               xidx = sum(abs(bas.^2))>eps;
               yidx = sum(abs(bas.^2),2)>eps;
               self.basisPrj(b,:) = sum(SSraw(:,yidx)'.*(bas(yidx,xidx)*SSraw(:,xidx)'));
            end
         end
         %%
%          self.basisPrj = basisPrj;
      end
      
      function getDeltaBasis2D(self)
         n = self.n;
         nBasis = (n.^2+n)/2;
         self.basis2D = zeros(nBasis, self.n, self.n);
         cnt = 0;
         template = zeros(n);
         for xidx = 1:n
            for yidx = xidx:n
               nps = template;
               nps(xidx,yidx) = 1;
               %nps = nps + nps':
               cnt = cnt+1;
               self.basis2D(cnt,:,:) = nps;
            end
         end
         
      end
      
   end
   
end
