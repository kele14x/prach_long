%%
clc;
clearvars;
close all;

%%
Fclk = 491.52e6;
Fs = 61.44e6 ./ [1, 2, 4, 8, 16, 48];

Bw_long = ceil(839/12) * 12 * 1.25e3;
Bw_short = ceil(139/12) * 12 * 15e3;

hb1 = firhalfband('minorder', Bw_short/Fs(1), db2mag(0.01)-1); % 61.44
hb2 = firhalfband('minorder', Bw_short/Fs(2), db2mag(0.01)-1); % 30.72
hb3 = firhalfband('minorder', Bw_short/Fs(3), db2mag(0.01)-1); % 15.36
hb4 = firhalfband('minorder', Bw_short/Fs(4), db2mag(0.01)-1); %  7.68
hb5 = firhalfband('minorder', Bw_long/Fs(5), db2mag(0.01)-1);  %  3.84

% [n, fo, ao, w] = firpmord([Bw_long / 2, (Fs(5) / 3 - Bw_long / 2)], [1, 0], [db2mag(0.01) - 1, db2mag(-60)], Fs(5));
% hb5 = firpm(n, fo, ao, w);

coe_hb1 = round(hb1*2^17);
coe_hb2 = round(hb2*2^17);
coe_hb3 = round(hb3*2^17);
coe_hb4 = round(hb4*2^17);
coe_hb5 = round(hb5*2^17);
