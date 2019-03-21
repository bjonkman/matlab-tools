function [S] = KaimalSpectra(f,sigma,uHub)

S = zeros( length(f), length(sigma) );
L = [8.1 2.7 .66] .* 0.7 * 60; % assumes hub height is at least 60 meters

for k=1:length(sigma)
    S(:,k) = (4 * sigma(k)^2 * L(k) / uHub) ./ (1 + 6 * L(k) / uHub * f ).^ (5/3);
end