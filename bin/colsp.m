function bp = colsp(subimg)

% Works only for the sliding type of colfilt with a neighborhood of 3x3.
% Generalizable with padding of the lut's to the size of nhood and changing
% the "9"s to be m*n product of size of nhood.
% subimg(subimg > 0) = 1;
[~,n] = size(subimg);
% dispm = floor(m/3):floor(2*m/3);
% dispn = 1:floor(n/3);
% padm = heaviside(m - 9)*(m - 9);
% padn = heaviside(n - 1)*(n - 1);

lut{1} = [1 1 1; 1 0 1; 1 1 1];
% centerpix = [0 0 0; 0 1 0; 0 0 0];
%centerpixloc = reshape(centerpix,[9,1]);
%centerpixlocmat = repmat(centerpixloc,1,n);

bp = zeros(1,n);
% Each loop compares the entire block to a single LUT and stores the
% result of the comparison in rows of corrs

lutcurrent = reshape(lut{1},[9,1]);
lutmatrix = repmat(lutcurrent,1,n);
% lutcurrent = padarray(lutcurrent,[padm padn],0,'post');
outs = sum(subimg.*lutmatrix,1);
bp(1,:) = subimg(5,:).*outs;
%    corrs(i,outs == 1) = 1;
%     for j = 1:n
%         if subimg(:,j) == lutmatrix(:,j)
%             corrs(i,j) = 1;
%         end
%     end
%     corrs(i,:) = sum(subimg == lutmatrix,1);

% if sum(outs) == 1
%     ep = 1;
% else
%     ep = 0;
% end
% bp = zeros(1,n);

% bp(sum(corrs,1)==1) = 1; % Only one of them should match
% ep = [zeros(4,n);ep;zeros(4,n)];
% 
% ep = zeros(m,n);
% if sum(outs,1) == 1
%     ep(ceil(m/2),ceil(n/2)) = 1;
% end

% ep = zeros(m,n);
% for i = 1:8
%     ep = ep + bwlookup(img,lut{i});
%     figure,imshow(ep(dispm,dispn));
% end
end
