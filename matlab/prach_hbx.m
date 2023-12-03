function [coe_hb1, coe_hb2, coe_hb3, coe_hb4, coe_hb5] = prach_hbx()

W = 17;
Fs = 61.44e6 ./ [1, 2, 4, 8, 16, 48];

Bw_long = ceil(839/12) * 12 * 1.25e3;
Bw_short = ceil(139/12) * 12 * 15e3;

hb1 = firhalfband('minorder', Bw_short/Fs(1), db2mag(0.01)-1); % 61.44
hb2 = firhalfband('minorder', Bw_short/Fs(2), db2mag(0.01)-1); % 30.72
hb3 = firhalfband('minorder', Bw_short/Fs(3), db2mag(0.01)-1); % 15.36
hb4 = firhalfband('minorder', Bw_short/Fs(4), db2mag(0.01)-1); %  7.68
hb5 = firhalfband('minorder', Bw_long/Fs(5), db2mag(0.01)-1); %  3.84

coe_hb1 = round(hb1*2^W);
coe_hb2 = round(hb2*2^W);
coe_hb3 = round(hb3*2^W);
coe_hb4 = round(hb4*2^W);
coe_hb5 = round(hb5*2^W);

end
