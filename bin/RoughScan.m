function [molPixelIdx,BW2] = RoughScan(obj,RawImage)

Option = obj.Option;
threshold = Option.threshold;
R = Option.spotR;
img = convert2double(RawImage);
[M,N] = size(img);
if strcmp(Option.illumination,'on')
    % High pass filtering to remove uneven background
    [M,~] = size(img);
    mid = floor(M/2)+1;
    Img = fft2(img);
    Img1 = fftshift(Img);
    Img2 = Img1;
    Img2(mid-3:mid+3,mid-3:mid+3) = min(min(Img1));
    Img2(257,257) = Img1(257,257);
    img1 = ifft2(ifftshift(Img2));
    img12 = abs(img1);
    img13 = img12-min(min(img12));
    img14 = img13/max(max(img13));
    % Mulitply pixels by the sum of their 8-connected neighbors to increase
    % intensities of particles
    img_2 = imadjust(colfilt(img14,[3 3],'sliding',@colsp));
else
    img_2 = imadjust(img);
end
if Option.exclude
    x1 = Option.exclude(1,1);
    y1 = Option.exclude(1,2);
    x2 = Option.exclude(2,1);
    y2 = Option.exclude(2,2);
    img_2(x1:x2,y1:y2) = 0;
end
if Option.include
    minval = Option.include(1,1);
    maxval = Option.include(1,2)-1;
    I = img_2(minval:maxval, minval:maxval);
    topad = (M - (maxval-minval+1))/2;
    img_2 = padarray(I,[topad topad],1000,'both');
end

BW = img_2 > threshold;

BWpad = padarray(BW,[1 1],0,'both');                                                                                                                                                                                                                                                                                                      
testmat1 = zeros(M+2,N+2); testmat1(1:end-2,1:end-2) = BW;
testmat2 = zeros(M+2,N+2); testmat2(3:end,3:end) = BW;
testmat3 = zeros(M+2,N+2); testmat3(3:end,1:end-2) = BW;
testmat4 = zeros(M+2,N+2); testmat4(1:end-2,3:end) = BW;

testmat5 = zeros(M+2,N+2); testmat5(3:end,2:end-1) = BW;
testmat6 = zeros(M+2,N+2); testmat6(1:end-2,2:end-1) = BW;
testmat7 = zeros(M+2,N+2); testmat7(2:end-1,3:end) = BW;
testmat8 = zeros(M+2,N+2); testmat8(2:end-1,1:end-2) = BW;

tallymat = BWpad + testmat1 + testmat2 + testmat3 + testmat4 + testmat5 ...                                                                                          
    + testmat6 + testmat7 + testmat8;

BW2 = BW.*(tallymat(2:end-1,2:end-1) > 1);
CC = bwconncomp(BW2);

molPixelIdx = cell(1);
l = 1;
for k = 1:length(CC.PixelIdxList)
    if ge(numel(CC.PixelIdxList{k}),50)
        % there might be multiple molecules near each other
        pixIdxList = CC.PixelIdxList{k};
        for ind = 1:numel(pixIdxList)
            pix = pixIdxList(ind);
            neighbors = [pix-M pix-M-1 pix-M+1 pix-1 pix+1 pix+M pix+M-1 pix+M+1];
            if sum(~ismember(neighbors,pixIdxList))
                continue
            elseif ge(img(pix),max(img(neighbors)))
                [i,j] = ind2sub([M,N],pix);
                if ge(i,R+1) && ge(M-R,i) && ge(j,R+1) && ge(N-R,j)
                    molPixelIdx{l} = [i,j];
                    l = l+1;
                end
            else
                continue
            end
        end    
    else
        [i,j] = getcentroid(CC.PixelIdxList{k});
        if ge(i,R+1) && ge(M-R,i) && ge(j,R+1) && ge(N-R,j)
            molPixelIdx{l} = [i,j];
            l = l+1;
        end
    end
end

    function [c_row,c_col] = getcentroid(pixelIdxList)
        [rows,cols] = ind2sub([M,N],pixelIdxList);
        weight = img_2(pixelIdxList);
        c_row = dot(rows,weight)/sum(weight);
        c_col = dot(cols,weight)/sum(weight);
        c_row = round(c_row);
        c_col = round(c_col);
    end

end
