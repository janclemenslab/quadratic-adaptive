function [kRidge, ovsc ,nsevar] = runRidgeOnly(x, y, spatialdims, nkt)

%--------------------------------------------------------------------------
% runRidgeOnly.m: find RF estimates using ridge regression
%--------------------------------------------------------------------------
%
% DESCRIPTION:
%    Find RF estimates using empirical Bayes with
%    Three localized priors:
%      1. Spacetime localized prior (ALDs),
%      2. Frequency localized prior (ALDf), and
%      3. Spacetime and frequency localized prior (ALDsf)
%
% INPUT ARGUMENTS:
% x        (nt x nx) matrix of design variables (vertical dimension indicates time)
% y        (nt x 1) output variable (column vector)
% ndims   Dimensions of stimuli
%             For example:
%               1d) ndims =[nx];  where nx is either spatial or temporal dimension
%               2d) ndims =[nt; nx],  or [ny; nx]; time by space, or space by space
%               3d) ndims = [nt; ny; nx];  time by space by space
% nkt       number of time samples of x to use to predict y.
%
% OUTPUT ARGUMENTS:
% kRidge               RF estimate by ridge regression
%
% Examples are in testScript.m
%
% (Updated: 25/12/2011 Mijung Park & Jonathan Pillow)

% Data structure of sufficient statistics from raw data
datastruct = formDataStruct(x, y, nkt, spatialdims);

% Ridge regression for initialization
opts0.maxiter = 10000;  % max number of iterations
opts0.tol = 1e-6;  % stopping tolerance
lam0 = 10;  % Initial ratio of nsevar to prior var (ie, nsevar*alpha)
% ovsc: overall scale, nasevar: noise variance
[kRidge, ovsc ,nsevar]  =  runRidge(lam0, datastruct, opts0);
