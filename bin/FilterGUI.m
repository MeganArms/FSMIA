function varargout = FilterGUI(varargin)
% FILTERGUI MATLAB code for FilterGUI.fig
%      FILTERGUI, by itself, creates a new FILTERGUI or raises the existing
%      singleton*.
%
%      H = FILTERGUI returns the handle to a new FILTERGUI or the handle to
%      the existing singleton*.
%
%      FILTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTERGUI.M with the given input arguments.
%
%      FILTERGUI('Property','Value',...) creates a new FILTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FilterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilterGUI

% Last Modified by GUIDE v2.5 11-Jan-2016 15:00:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FilterGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FilterGUI is made visible.
function FilterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FilterGUI (see VARARGIN)

% Choose default command line output for FilterGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FilterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FilterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_input_Callback(hObject, eventdata, handles)
% hObject    handle to edit_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_input as text
%        str2double(get(hObject,'String')) returns contents of edit_input as a double


% --- Executes during object creation, after setting all properties.
function edit_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame as text
%        str2double(get(hObject,'String')) returns contents of edit_frame as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_output_Callback(hObject, eventdata, handles)
% hObject    handle to edit_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_output as text
%        str2double(get(hObject,'String')) returns contents of edit_output as a double


% --- Executes during object creation, after setting all properties.
function edit_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_Cancel.
function button_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to button_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)

% --- Executes on button press in pushbutton_inFile.
function pushbutton_inFile_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile({'*.nd2';'*.tif';'*.*'},'Select the image to filter');
% If no sif file selected, return
if ~FileName
    return
end
set(handles.edit_input,'String',fullfile(PathName,FileName));


% --- Executes on button press in pushbutton_outFile.
function pushbutton_outFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uiputfile('*.tif','Save image as');
% If no sif file selected, return
if ~FileName
    return
end
set(handles.edit_output,'String',fullfile(PathName,FileName));

% --- Executes on button press in toggle_illumination.
function toggle_illumination_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_illumination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.toggle_illumination = str2double(get(hObject,'Value'));
% Hint: get(hObject,'Value') returns toggle state of toggle_illumination

% --- Executes on button press in button_OK.
function button_OK_Callback(hObject, eventdata, handles)
% Load the nd2 or tif file
filename = get(handles.edit_input,'String');
if strcmp(filename(end-3:end),'.nd2')
    data = bfopen(get(handles.edit_input,'String'));
    ind = str2double(get(handles.edit_frame,'String'));
    img = data{1}{ind,1};
elseif strcmp(filename(end-3:end),'.tif')
    img = imread(get(handles.edit_input,'String'),'Index',...
    str2double(get(handles.edit_frame,'String')));
end

if get(handles.toggle_illumination,'Value') == 1
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
    outImage = imadjust(colfilt(img14,[3 3],'sliding',@colsp));
else
    outImage = imadjust(img);
end
% Get recommended threshold - 3 sigma from the mean
mu = mean(outImage(:));
sigma = std(double(outImage(:)));
fprintf('Recommended threshold: %f\n',mu+2*sigma)
imwrite(uint16(outImage),get(handles.edit_output,'String'));
close(handles.figure1);
