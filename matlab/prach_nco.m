%%
clc;
close all;
clearvars;

%%
prach_SCS = 1.25e3;
SCS = 15e3;

nFp = 61.44e6 / prach_SCS;
nLut = nFp / 2^6;

waveform = sin(2*pi*(0:nLut - 1).'/nLut);
hex = dec2hex(round(waveform * 2^14));

writematrix(hex, 'prach_nco_sin_lut.hex', 'FileType','text');
