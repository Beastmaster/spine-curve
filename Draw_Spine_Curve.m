function varargout = Draw_Spine_Curve(varargin)
% DRAW_SPINE_CURVE MATLAB code for Draw_Spine_Curve.fig
%      DRAW_SPINE_CURVE, by itself, creates a new DRAW_SPINE_CURVE or raises the existing
%      singleton*.
%
%      H = DRAW_SPINE_CURVE returns the handle to a new DRAW_SPINE_CURVE or the handle to
%      the existing singleton*.
%
%      DRAW_SPINE_CURVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAW_SPINE_CURVE.M with the given input arguments.
%
%      DRAW_SPINE_CURVE('Property','Value',...) creates a new DRAW_SPINE_CURVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Draw_Spine_Curve_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Draw_Spine_Curve_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Draw_Spine_Curve

% Last Modified by GUIDE v2.5 06-Nov-2017 18:58:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Draw_Spine_Curve_OpeningFcn, ...
                   'gui_OutputFcn',  @Draw_Spine_Curve_OutputFcn, ...
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


% --- Executes just before Draw_Spine_Curve is made visible.
function Draw_Spine_Curve_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Draw_Spine_Curve (see VARARGIN)

% Choose default command line output for Draw_Spine_Curve
handles.output = hObject;

%%%%% configs
handles.scatter_size = 5;
handles.scatter_type = 'b--o';
handles.plot_type='LineWidth';
handles.plot_size = 2.5;
handles.color1 = [1,0,0];
handles.color2 = [1,1,0];
handles.color3 = [0,0,1];
handles.showPID = 1;

if ~isfield(handles,'root_dir')
    handles.root_dir = 'D:\Project\spine_seg_spline\temp\test_dcm_531\*.dcm';
%'C:\Users\qinsh\OneDrive\Project\Graduation2017\journal\test_images/*.dcm');
end

%%%% open dicom image
open_icon = imread('resources/load.PNG');
open_icon(open_icon>250) = 245;
sz = get(handles.open_Btn,'Extent');
aa = sz(4)*2.8;%+35;
bb = sz(3)*2.8;%+80;
open_icon = imresize(open_icon,[aa,bb] );
%set(handles.open_Btn,'String',' ');
%set(handles.open_Btn,'CData',open_icon);

dd = pwd;
name = fullfile(dd,'resources/load.PNG');
name = strrep(name,'\','/');
%labelTop=['<HTML><center><h2>Load EOS </h2> <img src ="file:' name '" align="bottom"></HTML>'];
%labelBot=['<div style="font-family:impact;color:green"><i>What a</i>'...
%          ' <Font color="blue" face="Comic Sans MS">nice day!'];
labelTop=['<HTML><center><h3>Load EOS</h3> </HTML>'];
set(handles.open_Btn, 'string',labelTop );


%%%% adjust new curve
name = fullfile(dd,'resources/adj.PNG');
name = strrep(name,'\','/');
labelTop=['<HTML> <table frame="border"><tr><center><h3> ADJUST </h3> <tr></table></HTML>'];
set(handles.adjust_Btn, 'string',labelTop );


%%%% fill display
imshow(ones(2000,1000),[],'Parent',handles.axes1);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Draw_Spine_Curve wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Draw_Spine_Curve_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in open_Btn.
function open_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to open_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;

[filename, pathname] = uigetfile(handles.root_dir,'File Selector');
file = fullfile(pathname,filename);
if filename == 0
    return;
end

handles.FileName = file;
handles.Ori_Image = dicomread(file);
%handles.Resize_Image = imresize(handles.Ori_Image,0.5);
handles.Resize_Image = handles.Ori_Image;
imshow(handles.Resize_Image,[],'Parent',handles.axes1); hold(handles.axes1,'on');
handles.Adj = 1;

info = dicominfo(file);
handles.pid = info.PatientID;
if handles.showPID == 0
    handles.pid(3:end)='*';
end
set(handles.id_txt,'string',handles.pid);


%------ fit
if handles.Adj == 1
    [handles.Curve,handles.Bin_Image] = GrayScaleBased('process',handles.Ori_Image);
    handles.Adj = 2;
else
    pos = ginput(1);
    [handles.Curve,handles.Bin_Image] = GrayScaleBased('update',handles.Bin_Image,pos); 
end

%---------
if ~isfield(handles,'Curve')
    msgbox('No spine line generated !');
    return;
end

vv = handles.Curve';
[handles.Couple,handles.Angle,line1,line2] = find_cobbs(vv);

% display
imshow(handles.Resize_Image,[],'Parent',handles.axes1); hold(handles.axes1,'on');
scatter(handles.Curve(2,:),handles.Curve(1,:),'Parent',handles.axes1,3,handles.color3,'filled-o'); hold(handles.axes1,'on');
line1 = cell2mat(line1); line2 = cell2mat(line2);
plot(line1(2,:),line1(1,:),'LineWidth',handles.plot_size,'Color',handles.color1,'Parent',handles.axes1);hold(handles.axes1,'on');
plot(line1(4,:),line1(3,:),'LineWidth',handles.plot_size,'Color',handles.color1,'Parent',handles.axes1);hold(handles.axes1,'on');
plot(line2(2,:),line2(1,:),'LineWidth',handles.plot_size,'Color',handles.color2,'Parent',handles.axes1);hold(handles.axes1,'on');
plot(line2(4,:),line2(3,:),'LineWidth',handles.plot_size,'Color',handles.color2,'Parent',handles.axes1);hold(handles.axes1,'on');

ang1 = handles.Angle(1);
set(handles.cobb_Edit,'String',num2str(ang1));
ang2 = handles.Angle(2);
set(handles.cobb_Edit2,'String',num2str(ang2));

if(0)
ang1_upper = str2num(get(handles.ang1_upper,'String'));
ang1_lower = str2num(get(handles.ang1_lower,'String'));
ang2_upper = str2num(get(handles.ang2_upper,'String'));
ang2_lower = str2num(get(handles.ang2_lower,'String'));
end

[~,nn,~] = fileparts(handles.FileName);
ss = {nn;handles.Ori_Image;handles.Curve'};
fn = strcat(nn,'.mat');
fn = fullfile('D:\Project\spine-curve\statistics\manual_method',fn);
disp(fn);
%save(fn,'ang1','ang1_upper','ang1_lower','ang2','ang2_upper','ang2_lower');

guidata(hObject, handles);


% --- Executes on button press in adjust_Btn.
function adjust_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to adjust_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;

if 0 %~isfield(handles,'Ori_Image')
    msgbox('Please load an image in the first !');
    return;
end

if handles.Adj == 1
    [handles.Curve,handles.Bin_Image] = GrayScaleBased('process',handles.Ori_Image);
    handles.Adj = 2;
else
    [posx,posy,but] = fginput(1,handles.axes1);
    if(but==27 || but==13)
        ;
    else
        pos=[posx,posy]/2;
        if length(pos)>1
            [handles.Curve,handles.Bin_Image] = GrayScaleBased('update',handles.Bin_Image,pos); 
        end
    end
end

%cla handles.axes1 reset;
imshow(handles.Resize_Image,[],'Parent',handles.axes1); hold(handles.axes1,'on');
scatter(handles.Curve(2,:),handles.Curve(1,:),'Parent',handles.axes1,3,handles.color3,'filled-o'); hold(handles.axes1,'on');

vv = handles.Curve';
[handles.Couple,handles.Angle,line1,line2] = find_cobbs(vv);
line1 = cell2mat(line1); line2 = cell2mat(line2);
plot(line1(2,:),line1(1,:),'LineWidth',handles.plot_size,'Color',handles.color1,'Parent',handles.axes1);hold(handles.axes1,'on');
plot(line1(4,:),line1(3,:),'LineWidth',handles.plot_size,'Color',handles.color1,'Parent',handles.axes1);hold(handles.axes1,'on');
plot(line2(2,:),line2(1,:),'LineWidth',handles.plot_size,'Color',handles.color2,'Parent',handles.axes1);hold(handles.axes1,'on');
plot(line2(4,:),line2(3,:),'LineWidth',handles.plot_size,'Color',handles.color2,'Parent',handles.axes1);hold(handles.axes1,'on');

ang = num2str(handles.Angle(1));
set(handles.cobb_Edit,'String',ang);
ang = num2str(handles.Angle(2));
set(handles.cobb_Edit2,'String',ang);

guidata(hObject, handles);



function cobb_Edit_Callback(~, ~, ~)
% hObject    handle to cobb_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cobb_Edit as text
%        str2double(get(hObject,'String')) returns contents of cobb_Edit as a double


% --- Executes during object creation, after setting all properties.
function cobb_Edit_CreateFcn(hObject, ~, ~)
% hObject    handle to cobb_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function save_Opt_Callback(hObject, ~, handles)
% hObject    handle to save_Opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
dirr = uigetdir();
if dirr == 0
    return;
end
filename = fullfile(dirr,'spine_curve.jpg');
F = getframe(handles.axes1);
Image = frame2im(F);
imwrite(Image, filename);

guidata(hObject, handles);



function cobb_Edit2_Callback(~, ~, ~)
% hObject    handle to cobb_Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cobb_Edit2 as text
%        str2double(get(hObject,'String')) returns contents of cobb_Edit2 as a double


% --- Executes during object creation, after setting all properties.
function cobb_Edit2_CreateFcn(hObject, ~, ~)
% hObject    handle to cobb_Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ang1_upper_Callback(hObject, eventdata, handles)
% hObject    handle to ang1_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ang1_upper as text
%        str2double(get(hObject,'String')) returns contents of ang1_upper as a double


% --- Executes during object creation, after setting all properties.
function ang1_upper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ang1_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ang1_lower_Callback(hObject, eventdata, handles)
% hObject    handle to ang1_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ang1_lower as text
%        str2double(get(hObject,'String')) returns contents of ang1_lower as a double


% --- Executes during object creation, after setting all properties.
function ang1_lower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ang1_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ang2_upper_Callback(hObject, eventdata, handles)
% hObject    handle to ang2_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ang2_upper as text
%        str2double(get(hObject,'String')) returns contents of ang2_upper as a double


% --- Executes during object creation, after setting all properties.
function ang2_upper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ang2_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ang2_lower_Callback(hObject, eventdata, handles)
% hObject    handle to ang2_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ang2_lower as text
%        str2double(get(hObject,'String')) returns contents of ang2_lower as a double


% --- Executes during object creation, after setting all properties.
function ang2_lower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ang2_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Copyright_Callback(hObject, eventdata, handles)
% hObject    handle to Copyright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'Copyright:';'CUHK: Dept.Ort'});




% --------------------------------------------------------------------
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function base_dir_Callback(hObject, eventdata, handles)
% hObject    handle to base_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
tmp_dir = uigetdir();
if(isdir(tmp_dir))
    handles.root_dir = fullfile(tmp_dir,'*.dcm');
end
guidata(hObject, handles);



% --------------------------------------------------------------------
function hid_id_Callback(hObject, eventdata, handles)
% hObject    handle to hid_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
if handles.showPID==1
    handles.showPID=0;
    set(handles.hid_id,'Label','Show ID');
else
    handles.showPID=1;
    set(handles.hid_id,'Label','Hide ID');
end

guidata(hObject, handles);


