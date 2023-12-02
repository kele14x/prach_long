%%
clc;
clearvars;
close all;

raw = readmatrix('../prj/project_1.sim/sim_1/behav/xsim/test_out.txt');
x = raw(:, 1) + 1j * raw(:, 2);

%%
pwelch(x, [], [], [], 61.44e6, 'center');
fprintf("Peak Power %.2f dBFS\n", 20*log10(max(abs(x)/2^15)));
fprintf("Mean Power %.2f dBFS\n", 20*log10(mean(abs(x)/2^15)));
figure();
plot([abs(x), real(x), imag(x)]);
