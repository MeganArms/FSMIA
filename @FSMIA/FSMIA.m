classdef FSMIA < handle
   properties
       filename
       Option
       Molecule
       Frame
       Result
       Intensity
   end
   
   methods
       function obj = FSMIA(filename)
           if nargin >0
               obj.filename = filename;
           end
           obj.Option = struct;
       end
       
       function obj = set.Option(obj,opt)
           obj.Option = opt;
       end
       
       function setoption(obj)
           opt = struct;
           prompt = {'Threshold','Spot radius (pixels)','Pixel size (nm)',...
               'Exclude region','Include only region',...
               'Connect distance threshold (nm)','Fitting (fast or slow)',...
               'Isolation Method (fast or slow)','Downsampling rate'...
               'Illumination correction (on or off)','Background'...
               'Wavelength (nm)','Numerical Aperture'};
           dlg_title = 'Set the options';
           def = {'','5','160','','','0','slow','fast','1','off','1000','647','1.49'};
           answer = inputdlg(prompt,dlg_title,1,def);
           opt.threshold = str2double(answer{1});
           opt.spotR = str2double(answer{2});
           opt.pixelSize = str2double(answer{3});
           exclude = str2double(answer{4});
           if isnan(exclude) || isempty(exclude)
               opt.exclude = false;
           else
               opt.exclude = exclude;
           end
           include = str2double(answer{5});
           if isnan(include) || isempty(include)
               opt.include = false;
           else
               opt.include = include;
           end
           opt.connectDistance = str2double(answer{6});
           opt.fitting = answer{7};
           opt.isolation = answer{8};
           opt.ds = str2double(answer{9});
           opt.illumination = answer{10};
           opt.bg = str2double(answer{11});
           opt.wavelength = str2double(answer{12});
           opt.na = str2double(answer{13});
           obj.Option = opt;
       end
   end
   
end
