%
clc;
clearvars;
close all;

debug = false;
nFFT = 1536;

rng(12345);
x = randn(nFFT, 1) + 1j * randn(nFFT, 1);
x = x / rms(x) * 10^(-40 / 20);
x = round(x*2^15);

%% TC-0
r = fft(x);
y = prach_fft(prach_fft_revorder(x));
e = y - r;

if debug
    figure();
    plot(abs(r));
    hold on;
    plot(abs(y));
    plot(abs(e));

    fprintf("Input power: %.2f\n", 20*log10(rms(x)/2^15));
    fprintf("Output power: %.2f\n", 20*log10(rms(y)/2^15));
end

evm = rms(e) / rms(y);
assert(evm < 0.01);

writematrix([real(x), imag(x)], './test/prach_fft_in.txt');
writematrix([real(y), imag(y)], './test/prach_fft_out.txt');
