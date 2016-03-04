function analyzestack(obj,ImageFile)

[~,~,ext] = fileparts(ImageFile);
if strcmp(ext,'.tiff') || strcmp(ext,'.tif')
    analyzetiffstack(obj,ImageFile)
elseif strcmp(ext,'.nd2')
    analyzenikonstack(obj,ImageFile)
end

    function analyzenikonstack(obj,ImageFile)
        data = bfopen(ImageFile);
        [nFrame,~] = size(data{1});
        dsRate = obj.Option.ds;
        frames2analyze = 1:dsRate:nFrame;
        fprintf('Beginning analysis of %d frames, sampling every %d frames\n',nFrame,dsRate);
        tic;
        for k = 1:nFrame
            NumMolecule = length(obj.Molecule);
            rawImage = data{1}{k,1};
            FineScan(obj,rawImage);
            for i = (NumMolecule+1):length(obj.Molecule)
                obj.Molecule(i).frame = k;
            end
            obj.Frame(k).MoleculeIndex = (NumMolecule+1):length(obj.Molecule);
            if k == round(0.1*nFrame)
                t = toc;
                fprintf('10%% (%d frames) finished! Time cost: %f mins\n',k,t/60);
            elseif k == round(0.5*nFrame)
                t = toc;
                fprintf('50%% (%d frames) finished! Time cost: %f mins\n',k,t/60);
            elseif k == round(0.9*nFrame)
                t = toc;
                fprintf('90%% (%d frames) finished! Time cost: %f mins\n',k,t/60);
            else
            end
        end
        disp('Analysis of all frames finished!');
        % Connect to create molecule trajectory
        for k = 1:nFrame-1
            connectFrame(obj,k,k+1);
        end
	disp('Molecules connected!');
    end

    function analyzetiffstack(obj,ImageFile)
        info = imfinfo(ImageFile);
        nFrame = numel(info);
        dsRate = obj.Option.ds;
        frames2analyze = 1:dsRate:nFrame;
        fprintf('Beginning analysis of %d frames, sampling every %d frames\n',nFrame,dsRate);
        tic;
        for k = frames2analyze
            NumMolecule = length(obj.Molecule);
            rawImage = imread(ImageFile,k);
            FineScan(obj,rawImage);
            for i = (NumMolecule+1):length(obj.Molecule)
                obj.Molecule(i).frame = k;
            end
            obj.Frame(k).MoleculeIndex = (NumMolecule+1):length(obj.Molecule);
            if k == round(0.1*nFrame)
                t = toc;
                fprintf('10%% (%d frames) finished! Time cost: %f mins\n',k,t/60);
            elseif k == round(0.5*nFrame)
                t = toc;
                fprintf('50%% (%d frames) finished! Time cost: %f mins\n',k,t/60);
            elseif k == round(0.9*nFrame)
                t = toc;
                fprintf('90%% (%d frames) finished! Time cost: %f mins\n',k,t/60);
            else
            end
        end
        disp('Analysis of all frames finished!');
        % Connect to create molecule trajectory
        if dsRate == 1
            for k = 1:nFrame-1
                connectFrame(obj,k,k+1);
            end
        end
        disp('Molecules connected!');
    end

end
