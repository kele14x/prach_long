%% Clear
clc;
clearvars;
close all;

%% PRACH waveform generation
RAT = 'LTE';
BW = '20';

Debug = true;

ue.DuplexMode = 'FDD';
if strcmpi(RAT, 'LTE')
    ue.NULRB = lte_nRB(BW);
elseif strcmpi(RAT, 'NR')
    ue.NULRB = nr_nRB(BW);
else
    error(fprintf('Invalid RAT: %s', RAT));
end

chs.Format = 0; % 0,1,2,3,4
chs.SeqIdx = 0; % 0 to 837
% chs.ConfigIdx = 0;  % 0 to 63
chs.PreambleIdx = 0;  % 0 to 63
chs.CyclicShiftIdx = 0;   % 0 to 15
chs.HighSpeed = 0; 
chs.TimingOffset = 0;
chs.FreqOffset = 0;

[waveform, info] = ltePRACH(ue, chs);

% Scale power
waveform = waveform * 1;

if Debug
    pwelch(waveform, [], [], [], info.SamplingRate, 'centered');
    fprintf('Peak Power: %.2f dBFS\n', 20*log10(max(abs(waveform))));
    fprintf('Average Power: %.2f dBFS\n', 20*log10(mean(abs(waveform))));
    figure();
    plot(-12288:12287, 20*log10(fftshift(abs(fft(waveform(3169:3169+24575))))));
end

%%
hex_i = dec2hex(round(real(waveform) * 2^16), 4);
hex_q = dec2hex(round(imag(waveform) * 2^16), 4);
hex = [hex_q, hex_i];
writematrix(hex, './tv_ant0_cc0.txt');
