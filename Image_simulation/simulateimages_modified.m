function simulateimages_modified(N_images)

% R = 100*poissrnd(2,1,N_images);
Img=zeros(25,25,N_images);
for i=1:N_images
    Image=simulateimage_modified(1,10,10,25);
    nomFichier= sprintf('NoNoise%dimages80.mat',i);
    i
    Img(:,:,i)=Image;
end

 % Save output
    save(nomFichier,'Img');

end
