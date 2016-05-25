function bp = colsp(subimg)

% COLSP (COLumn Sum-Produc) is the function designed to work with COLFILT
% and a 'sliding' type 3x3 neighborhood. The purpose is to multiply the
% center of the kernel by the sum of the intensities of the eight
% neighbors. This emphasizes high densities of high intensity pixels, i.e.
% what a particle is expected to be.

% Generalizable with padding of the lut's to the size of nhood and changing
% the "9"s to be m*n product of size of nhood.

% subimg(subimg > 0) = 1;
[~,n] = size(subimg);
% dispm = floor(m/3):floor(2*m/3);
% dispn = 1:floor(n/3);
% padm = heaviside(m - 9)*(m - 9);
% padn = heaviside(n - 1)*(n - 1);

lut = [1 1 1; 1 0 1; 1 1 1];
bp = zeros(1,n);

lutcurrent = reshape(lut,[9,1]);
lutmatrix = repmat(lutcurrent,1,n);
outs = sum(subimg.*lutmatrix,1);
bp(1,:) = subimg(5,:).*outs; % Five is the middle pixel in column

end
