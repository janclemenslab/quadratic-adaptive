addpath(genpath('src'))
cc()
%% NOISE
load('res/noise_20160311_8.mat')

i0 = 5500;
i1 = i0 + 1000;
T = (0:(i1-i0)) / fs * 1000;

figure(1)
clf()
subplot(211)
plot(T, param.stim(i0:i1), 'k')
set(gca, 'XColor', 'none', 'YTick', -0.4:0.2:0.4)
title('noise')
ylabel('Particle velocity [mm/s]')  % TODO: scale stim properly!

subplot(212)
plot(T, param.resp(i0:i1))
hold on
plot(T, paramDN.pred(i0:i1))
xlabel('Time [ms]')
ylabel('Voltage [uV]')
title(sprintf('r^2=%1.2f', rsq(param.resp, param.pred)))
legend({'CAP', 'QF-DN'}, 'box', 'off')

set(gca, 'XTick', 0:50:200, 'YTick', -5:5:10)
clp()

%% NOISE STEPS
load('res/step_20140625_1.mat')

i0 = 5750+1000;
i1 = i0 + 1000;
T = (0:(i1-i0)) / fs * 1000;

figure(2)
clf()
subplot(211)
plot(T, param.stim(i0:i1), 'k')
set(gca, 'XColor', 'none', 'YTick', -0.4:0.2:0.4)
title('Noise steps')
ylabel('particle velocity [mm/s]')  % TODO: scale stim properly!

subplot(212)
plot(T, param.resp(i0:i1))
hold on
plot(T, paramDN.pred(i0:i1))
xlabel('Time [ms]')
ylabel('Voltage [uV]')
title(sprintf('r^2=%1.2f', rsq(param.resp, paramDN.pred)))
legend({'CAP', 'QF-DN'}, 'box', 'off')

set(gca, 'XTick', 0:50:200, 'YTick', -5:5:10)
clp()
