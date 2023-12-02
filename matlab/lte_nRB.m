function nRB = lte_nRB(BW)
% 	6, 9, 11, 15, 25, 27, 45, 50, 64, 75, 91, 100

if strcmpi(BW, '5')
    nRB = 25;
elseif strcmpi(BW, '10')
    nRB = 50;
elseif strcmpi(BW, '15')
    nRB = 75;
elseif strcmpi(BW, '20')
    nRB = 100;
else
    error(fprintf('Invalid BW: %s', BW));
end

end
