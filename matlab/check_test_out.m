%%
clc;
clearvars;
close all;

%%
% Input
x = readmatrix("./tv_ant0_cc0.txt", "OutputType", "char");
x = char(x);
x_real = x(:, 5:8);
x_real = hex2dec(x_real);
x_real(x_real >= 2^15) = x_real(x_real >= 2^15) - 2^16;
x_imag = x(:, 1:4);
x_imag = hex2dec(x_imag);
x_imag(x_imag >= 2^15) = x_imag(x_imag >= 2^15) - 2^16;
x = x_real + 1j * x_imag;
clear x_real x_imag
x = zeros(size(x));
x(1) = 16384;
fprintf("Input RMS Power: %.2f\n", 20*log10(rms(x)));
x_ref = x;

% Mixer
x = upsample(x, 2);
kv = (0:length(x) - 1).';
fcw = 6768;
phase = floor(fcw/64*kv);
nco = round(2^14*exp(2j*pi*phase/768));
x = x .* nco;
x = floor((x + 2^13 + 1j * 2^13)/2^14);
fprintf("Post NCO RMS Power: %.2f\n", 20*log10(rms(x)));
x_mixer = x;

% DDC
[hb1, hb2, hb3, hb4, hb5] = prach_hbx();
x = filter([0, hb1], 1, x);
x = floor((x + 2^16)/2^17);
x = downsample(x, 2);
fprintf("Post HB1 RMS Power: %.2f\n", 20*log10(rms(x)));
x_hb1 = x;

x = filter([0, hb2], 1, x);
x = floor((x + 2^16)/2^17);
x = downsample(x, 2);
fprintf("Post HB2 RMS Power: %.2f\n", 20*log10(rms(x)));
x_hb2 = x;

x = filter([0, hb3], 1, x);
x = floor((x + 2^16)/2^17);
x = downsample(x, 2);
fprintf("Post HB3 RMS Power: %.2f\n", 20*log10(rms(x)));
x_hb3 = x;

x = filter([0, hb4], 1, x);
x = floor((x + 2^16)/2^17);
x = downsample(x, 2);
fprintf("Post HB4 RMS Power: %.2f\n", 20*log10(rms(x)));
x_hb4 = x;

x = filter([0, hb5], 1, x);
x = floor((x + 2^16)/2^17);
x = downsample(x, 2);
fprintf("Post HB5 RMS Power: %.2f\n", 20*log10(rms(x)));
x_hb5 = x;

% Impulse delay
D = round(4*1.92/61.44+4*1.92/30.72+4*1.92/15.36+8*1.92/7.68+8*1.92/3.84);

% figure();
% plot(abs([downsample(x_ref, 16), 2 * circshift(x, -D)]));
% figure();
% pwelch(x, [],[],[],61.44e6, 'centered')

%%
raw = readmatrix('../prj/project_1.sim/sim_1/behav/xsim/hb1_out.txt');
y = raw(:, 1) + 1j * raw(:, 2);

% fprintf("Peak Power %.2f dBFS\n", 20*log10(max(abs(y)/2^15)));
fprintf("Mean Power %.2f dBFS\n", 20*log10(mean(abs(y)/2^15)));

figure();
plot(abs(x_hb3));
hold on;
plot(abs(y));

% figure();
% pwelch(y, [], [], [], 61.44e6/8, 'center');

% figure();
% plot([real(x), imag(x)]);
