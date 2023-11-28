%%
clc;
clearvars;
close all;

%%
% Sampling frequency
Fs = 30.72e6;
% Signal Bandwidth
Bw = 12*12*15e3;

h = firhalfband('minorder', Bw/Fs, db2mag(0.001)-1).';
fvtool(h, 'Fs', Fs);

coe = round(h * 2^17); % fi(1, 18, 17)
uniq_coe = coe(1:2:(length(coe)-1)/2);
