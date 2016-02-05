function plotTrajectory(obj,trajNum,saveset)


Molecule = obj.Molecule;
Result = obj.Result;

traj = Result(trajNum).trajectory;
path = Molecule(traj(1)).Result;

coords = [];
figure(1)
for i = 1:size(path,1)
    % Get frame
    mIndex = path(i);
    fIndex = Molecule(mIndex).frame;
    img = imread(obj.filename,fIndex);
    
    % Pre-process image
    [M,~] = size(img);
    if strcmp(obj.Option.illumination,'on')
        % High pass filtering to remove uneven background
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
        img_1 = colfilt(img14,[3 3],'sliding',@colsp);
    else
        img_1 = img;
    end
    if i == 1
        coords = Molecule(mIndex).coordinate;
    else
        delete(gca)
        coords = [coords; Molecule(mIndex).coordinate];
    end
    imshow((img_1))
    hold on, plot(coords(:,2),coords(:,1),'bo-','MarkerFaceColor','b'), hold off
    B(i) = getframe;
    
end
% movie(figure(2),B,3,2); % Play movie in figure 2 at 2 FPS 3 times.

if strcmp(saveset,'on')
    vidObj = VideoWriter(['Trajectory ',num2str(trajNum),' Movie.avi']);
    vidObj.FrameRate = 2; vidObj.Quality = 100;
    open(vidObj);
    writeVideo(vidObj,B);
    close(vidObj);
end

end
    
    

