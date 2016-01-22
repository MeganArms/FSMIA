function heatimage = mapintensity(obj)

% Make heat map of intensities for an entire video if the molecule stays at
% least 3 frames. Map is divided into chunks 1/8-size of the image.

img = imread(obj.filename);
intensities = zeros(length(obj.Molecule),3);
integralvalues = zeros(size(img)); indeximage = integralvalues;
for i = 1:length(obj.Molecule)
    %if ~isempty(obj.Molecule(i).To) || ~isempty(obj.Molecule(i).From)
        intensities(i,1:2) = obj.Molecule(i).coordinate;
        if isfield(Molecule,'fit')
        intensities(i,3) = fitVolume(i,obj.Molecule)./160^2;
        elseif isfield(Molecule,'centroid')
            intensities(i,3) = Molecule(i).volume;
        end
        integralvalues(intensities(i,1),intensities(i,2)) = intensities(i,3) ...
            + integralvalues(intensities(i,1),intensities(i,2));
        indeximage(intensities(i,1),intensities(i,2)) = indeximage(intensities(i,1),intensities(i,2)) + 1;
    %end
end

heatimage = zeros(size(img));
[~,N] = size(img);
for i = 1:N/8:N
    for j = 1:N/8:N
        val = N/8 - 1;
        nummolecs = sum(sum(indeximage(i:i+val,j:j+val)));
        val = sum(sum(integralvalues(i:i+val,j:j+val)));
        heatimage(i:i+val,j:j+val) = val*ones(N/8)/nummolecs;
    end
end
        
        
    function [volumeInt, maxInt] = fitVolume(M, Molecule)
        
        % Find the volume of the Gaussian fit for molecule M using the fit
        % f = A*exp(-((x-x_0)^2 + (y-y_0)^2)/2/sigma^2) + z_0
        % The units of the parameters are in distance (usually microns) and
        % intensity levels
        
        A = Molecule(M).fit.A;
        sigma = Molecule(M).fit.sigma;
        
        % UPDATE so as to not include the background, z_0 level
        % syms x y A x_0 y_0 sigma z_0
        % f = A*exp(-((x-x_0)^2 + (y-y_0)^2)/2/sigma^2);
        % int_fx = int(f, x, [x_0-3*sigma, x_0 + 3*sigma]);
        % int_f = int(int_fx, y, [y_0 - 3*sigma, y_0 + 3*sigma])
        %
        % int_f =
        %
        % 2*A*pi*sigma^2*erf((3*2^(1/2))/2)^2
        
        volumeInt = 2*A*pi*sigma^2*erf((3*2^(1/2))/2)^2;
        maxInt = A;
    end

end