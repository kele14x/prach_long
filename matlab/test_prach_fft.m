%
clc;
clearvars;
close all;

nFFT = 1536;

x = prach_source();
x = prach_ddc(x);
x = x(1:nFFT);

%% TC-0
r = fft(x);
y = prach_fft(prach_fft_revorder(x));
e = y - r;

figure();
plot(abs(r));
hold on;
plot(abs(y));
plot(abs(e));

evm = rms(e) / rms(y);
assert(evm < 0.01);

%% TC-1
r = prach_fft(prach_fft_revorder(x));
y = readmatrix('../prj/project_1.sim/sim_1/behav/xsim/test_out.txt');
y = y(:, 1) + 1j * y(:, 2);
e = y - r;

figure();
plot(abs(r));
hold on;
plot(abs(y));

plot(abs(e));

evm = rms(e) / rms(y);
assert(evm < 0.01);