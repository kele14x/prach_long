function y = ditfft2(x, K)
assert(K <= length(x));
assert(rem(length(x), K) == 0);

W = @(N, k)(exp(-2j*pi*k/N));
y = zeros(size(x));

for i = 1:length(x) / K
    idx = (i - 1) * K + 1:i * K;
    xs = x(idx);

    xs1 = xs(1:K/2);
    xs2 = xs(K/2+1:end);

    wx = W(K, 0:K/2-1);

    y1 = xs1 + xs2 .* wx;
    y2 = xs1 - xs2 .* wx;

    y(idx) = [y1, y2];
end

end
