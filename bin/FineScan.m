function FineScan(obj,RawImage)
% FINESCAN(MOLPIXELIDX,RAWIMAGE) gets the detailed information for molecules
% identified in RAWIMAGE

Option = obj.Option;
R = Option.spotR;   % radius (pixel) of diffraction limited spot
img = double(RawImage);
[molPixelIdx,BW] = RoughScan(obj,img);
NumMolecule = length(obj.Molecule);

for k = 1:length(molPixelIdx)
    if isempty(molPixelIdx{k})
        break
    end
    i = molPixelIdx{k}(1);
    j = molPixelIdx{k}(2);
    subImage = img(i-R:i+R,j-R:j+R);
    BW_sub = BW(i-R:i+R,j-R:j+R);
    CC_sub = bwconncomp(BW_sub);
    
    % Deal with the above threshold pixels in the peripheral of subimage
    N = numel(CC_sub.PixelIdxList);
    if N > 1
        center_idx = 2*R^2+2*R+1;
        for l = 1:N
            pixIdxList = CC_sub.PixelIdxList{l};
            if ~ismember(center_idx,pixIdxList)
                subImage(pixIdxList) = min(min(subImage));
            end
        end
    end
    if strcmp(Option.fitting,'fast')
        % Perform centroid fitting. Subtract the location of the center
        % pixel to convert it to the distance from the center of the pixel.
        % Eliminate potential moelecules in ROI
        edgeThreshold = Option.threshold;
        edgeImage = subImage; edgeImage(3:end-2, 3:end-2) = 0;
        subImage(edgeImage > edgeThreshold) = min(min(subImage));
        centroid = regionprops(true(size(subImage)),subImage,'WeightedCentroid');
        s = centroid.WeightedCentroid(2)-R-1+0.5;
        t = centroid.WeightedCentroid(1)-R-1+0.5;
        obj.Molecule(NumMolecule+k).centroid = [s,t]*obj.Option.pixelSize;
        if N > 1
            lengths = zeros(1,N);
            for l = 1:N
                lengths(l) = length(CC_sub.PixelIdxList);
            end
            [~,maxidx] = max(lengths);
            pxlist = CC_sub.PixelIdxList{maxidx};
        else
            pxlist = CC_sub.PixelIdxList{1};
        end
        obj.Molecule(NumMolecule+k).volume = sum(sum(subImage(pxlist) - Option.bg));    
        obj.Molecule(NumMolecule+k).area = length(pxlist)*Option.pixelSize^2;
        obj.Molecule(NumMolecule+k).maxInt = max(max(subImage));
    elseif strcmp(Option.fitting,'slow') && strcmp(Option.isolation,'fast')
        % Eliminate potential moelecules in ROI
        edgeThreshold = Option.threshold;
        edgeImage = subImage; edgeImage(3:end-2, 3:end-2) = 0;
        subImage(edgeImage > edgeThreshold) = min(min(subImage));
        try
            [obj.Molecule(NumMolecule+k).fit,obj.Molecule(NumMolecule+k).gof] = fit2D(obj,subImage);
        catch
            disp('Unable to fit 2D Gaussian for the following molecule with adjusted ROI:');
            fprintf('%d, %d\n',i,j);
            disp(subImage);
            continue
        end
        % For error analysis
%         if obj.Molecule(NumMolecule+k).gof.rsquare < .85
%             fprintf('%d, %d, rsquare = %d, SSE = %d\n',i,j,obj.Molecule(NumMolecule+k).gof.rsquare,obj.Molecule(NumMolecule+k).gof.sse);
%             figure,subplot(1,2,1),surf(subImage),subplot(1,2,2),plot(obj.Molecule(NumMolecule+k).fit)
%             choice = menu('Continue or Stop?','Continue','Stop');
%             if choice == 1
%                 close(gcf);
%                 continue
%             else
%                 break
%             end
%         end
%             
    elseif strcmp(Option.fitting,'slow') && strcmp(Option.isolation,'slow')
        % Determine if neighbor molecule is in ROI and find edgeTH
        try
            [F1,G1] = fit2D(obj,subImage);
        catch
            disp('Unable to fit 2D Gaussian for the following molecule:');
            fprintf('%d, %d\n',i,j);
            disp(subImage);
            continue
        end
        subsubImage = subImage(3:end-2, 3:end-2);
        try
            [F2,G2] = fit2D(obj,subsubImage);
        catch
            disp('Unable to fit small 2D Gaussian for the following molecule:');
            fprintf('%d, %d\n',i,j);
            disp(subsubImage);
            continue
        end
        if G2.rsquare > G1.rsquare
            % Neighbor molecule is in the ROI
            edgeThreshold = F2.A*exp((-(160-F2.x0)^2-(160-F2.y0)^2)/(2*F2.sigma^2))+F2.z0;
            edgeImage = subImage; edgeImage(3:end-2, 3:end-2) = 0;
            subImage(edgeImage > edgeThreshold) = min(min(subImage));
            try
                [obj.Molecule(NumMolecule+k).fit,obj.Molecule(NumMolecule+k).gof] = fit2D(obj,subImage);
            catch
                disp('Unable to fit 2D Gaussian for the following molecule with adjusted ROI:');
                fprintf('%d, %d\n',i,j);
                disp(subImage);
                continue
            end
        else
            % Neighbor molecule is not in the ROI
            obj.Molecule(NumMolecule+k).fit = F1;
            obj.Molecule(NumMolecule+k).gof = G1;
        end
    end
    obj.Molecule(NumMolecule+k).coordinate = [i j];
end

end