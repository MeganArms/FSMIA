function [img,pos] = simulateimage_modified(N_molecule,varargin)
% Simulate single molecule images
% Input:
%   N_molecule - number of molecules in image
%   opt.d - distance between two molecules (nm)
%   opt.snr - peak signal-to-noise ratio
%   opt.dim - size of simulated image
% 08/11/2015
% Siheng He

if ~isempty(varargin)
    opt = varargin{1};
end
NA = 1.49;  % numerical aperture
lambda = 647;
n_o = 1.515;    % refractive index of immersion oil
a = 2*pi*NA/(lambda*n_o);
f_PSF = @(r) (2*besselj(1,r*a)./(r*a)).^2;
if isfield(opt,'dim')
    img_dim = opt.dim;
else
    img_dim = 25;
end
pixel_hr_size = 1;  % nm
n_HR = 80/pixel_hr_size; % dimensions of 1 pixel in high resolution matrix
img_HR = zeros(img_dim*n_HR);
i = randi(n_HR);
j = randi(n_HR);
pos = [i j];
img_HR(n_HR*(img_dim-1)/2+i,n_HR*(img_dim-1)/2+j) = 10000;
if N_molecule == 2
    img_HR(n_HR*(img_dim-1)/2+n_HR/2,n_HR*(img_dim-1)/2+n_HR/2-opt.d/4) = 10000;
elseif N_molecule > 2
    warning('Does not support more than 2 particles yet.')
else
end
PSF_mat = zeros(size(img_HR));
center = n_HR*floor(img_dim/2)+n_HR/2+0.5;
for ii = 1:size(PSF_mat,1)
    for jj = 1:size(PSF_mat,2)
        r = pixel_hr_size*sqrt((ii-center)^2+(jj-center)^2);
        PSF_mat(ii,jj) = f_PSF(r);
    end
end
img_HR = ifftshift(ifft2(fft2(img_HR).*fft2(PSF_mat)));
img = zeros(img_dim);
for i = 1:img_dim
    for j = 1:img_dim
        pixel = img_HR(((i-1)*n_HR+1):i*n_HR,((j-1)*n_HR+1):j*n_HR);
        img(i,j) = sum(pixel(:))/1e4;
    end
end

if isfield(opt,'snr')
    snr = opt.snr;
else
    snr = sqrt(200);
end

img = img/(max(img(:))/snr^2);  % scale to get a more realistic image

% for i = 1:img_dim
%     for j = 1:img_dim
%         img(i,j) = random('Poisson',img(i,j));
%     end
% end

% add dark noise and readout noise
%img = img + random('Normal',0,10,[size(img,1) size(img,2)]) +1000;
%img = round(img);

end