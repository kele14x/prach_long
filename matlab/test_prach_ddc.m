%
clc;
clearvars;
close all;

%% TC-0
nFFT = 1536;
x = prach_source();
x = prach_ddc(x);
x = x(1:nFFT);

y = readmatrix('../prj/project_1.sim/sim_1/behav/xsim/test_out.txt');
y = y(:, 1) + 1j * y(:, 2);
e = y - x;

figure();
plot(abs(x));
hold on;
plot(abs(y));

evm = rms(e) / rms(x);
assert(evm < 0.01);
