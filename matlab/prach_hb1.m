%%
clc;
clearvars;
close all;

%%
% Sampling frequency
Fs = 61.44e6;
% Signal Bandwidth
Bw = 12*12*15e3;

h = firhalfband('minorder', Bw/Fs, db2mag(0.001)-1).';
fvtool(h, 'Fs', Fs);

coef = hex(fi(h, 1, 18, 17));
