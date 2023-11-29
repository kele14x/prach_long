%%
clc;
clearvars;
close all;

%%
nFFT = 1536;
rng(12345);
x = randn(1, nFFT) + 1j * randn(1, nFFT);

idx = [bitrevorder(1:nFFT/3); bitrevorder(nFFT/3+1:2*nFFT/3); bitrevorder(2*nFFT/3+1:nFFT)];
idx = idx(:);

y = ditfft3(x(idx), 3);
for n= [6, 12, 24, 48, 96, 192, 384, 768, 1536]
    y = ditfft2(y, n);
end

z = fft(x);
plot(abs([y(:), z(:)]));
