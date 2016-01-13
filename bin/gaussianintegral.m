function z = gaussianintegral(x,y,A,sigma,x0,y0,z0)
% Integral of 2D Gaussian on the area of one pixel
fun = @(x,y) A*exp((-(x-x0).^2-(y-y0).^2)/(2*sigma^2));
N = length(x);
z = zeros(size(x));
for i = 1:N
    z(i) = integral2(fun,x(i)-80,x(i)+80,y(i)-80,y(i)+80)+z0;
end
end