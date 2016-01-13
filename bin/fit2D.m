function [f,gof] = fit2D(obj,img)
% Fit PSF to ROI
Option = obj.Option;
R = Option.spotR;
[y,x] = meshgrid(-R:R);
y = y(~isnan(img))*Option.pixelSize;
x = x(~isnan(img))*Option.pixelSize;
z = img(~isnan(img));

% PSF model
ft = fittype('A*exp((-(x-x0)^2-(y-y0)^2)/(2*sigma^2))+z0',...
    'independent',{'x','y'},'dependent','z');

% fit options
opts = fitoptions(ft);
opts.Display = 'off';
z_0 = min(min(z));
A_0 = img(R+1,R+1) - z_0;
x_0 = 0;
y_0 = 0;
sigma_0 = 250;
opts.StartPoint = [A_0 sigma_0 x_0 y_0 z_0];
opts.Lower = [0 100 -400 -400 z_0-200];
opts.Upper = [A_0+200 500 400 400 z_0+200];

[f,gof] = fit([x,y],z,ft,opts);
