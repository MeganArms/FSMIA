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
               'Connect distance threshold (nm)',...
               'Isolation Method (fast or slow)','Downsampling rate'...
               'Illumination correction (on or off)'};
           dlg_title = 'Set the options';
           def = {'','5','160','','','0','fast','1','off'};
           answer = inputdlg(prompt,dlg_title,1,def);
           opt.threshold = str2double(answer{1});
           opt.spotR = str2double(answer{2});
           opt.pixelSize = str2double(answer{3});
           exclude = str2double(answer{4});
           if isnan(exclude) || isempty(exclude)
               opt.exclude = false;
           else
               opt.exlcude = exclude;
           end
           include = str2double(answer{5});
           if isnan(include) || isempty(include)
               opt.include = false;
           else
               opt.include = include;
           end
           opt.connectDistance = str2double(answer{6});
           opt.isolation = answer{7};
           opt.ds = str2double(answer{8});
           opt.illumination = answer{9};
           obj.Option = opt;
       end
   end
   
end
