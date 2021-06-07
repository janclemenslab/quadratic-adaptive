addpath(genpath('src'))
cc()
load('res/noise_20160311_8.mat')
%%
% reconstruct the quadratic filter matrix
H2 = triu(paramQN.h2) + triu(paramQN.h2)';
T = (-size(H2, 1):1:-1) / fs * 1000;

[eigVec, eigVal] = eig(H2);
eigVal = diag(eigVal);
%%
colormap(flipud(cbrewer2('Div', 'RdBu')))
subplot(221)
imagesc(T, T, H2)
axis('square', 'xy')
colorbar()
set(gca, 'CLim', [-1 1] .* max(abs(H2(:))))
xlabel('\tau_1 [ms]')
ylabel('\tau_2 [ms]')
title('Quadratic filter H_2(\tau_1, \tau_2)')

eigValRed = diag(eigVal);
eigValRed(3:end-2, 3:end-2) = 0;
H2_red = (eigVec * eigValRed') * eigVec';

subplot(223)
imagesc(T, T, H2_red)
axis('square', 'xy')
colorbar()
set(gca, 'CLim', [-1 1] .* max(abs(H2(:))))
xlabel('\tau_1 [ms]')
ylabel('\tau_2 [ms]')
title('Rank 4 approximation of H_2(\tau_1, \tau_2)')


subplot(243)
plot(eigVal, 'o-k')
xlabel('rank')
ylabel('eigenvalue')

subplot(244)
plot(cumsum(sort(abs(eigVal), 'descend')) / sum(abs(eigVal)), 'o-k')
xlabel('rank')
ylabel('cumulative sum of abs eigenvalues')
set(gca, 'YLim', [0, 1])

subplot(247)
plot(T, eigVec(:, [1 2]))
xlabel('\tau [ms]')
title('Suppressive quadrature pair')

subplot(248)
plot(T, eigVec(:, [end-1 end]))
xlabel('\tau [ms]')
title('Excitatory quadrature pair')

clp()
