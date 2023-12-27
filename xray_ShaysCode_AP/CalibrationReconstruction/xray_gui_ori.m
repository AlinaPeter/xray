function varargout = xray_gui(varargin)
% XRAY_GUI MATLAB code for xray_gui.fig
%      XRAY_GUI, by itself, creates a new XRAY_GUI or raises the existing
%      singleton*.
%
%      H = XRAY_GUI returns the handle to a new XRAY_GUI or the handle to
%      the existing singleton*.
%
%      XRAY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XRAY_GUI.M with the given input arguments.
%
%      XRAY_GUI('Property','Value',...) creates a new XRAY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before xray_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to xray_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xray_gui

% Last Modified by GUIDE v2.5 13-Sep-2015 12:08:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xray_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @xray_gui_OutputFcn, ...
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

function initGUI(hObject,handles)

if strcmp(computer, 'PCWIN64')
    startupFolder = 'C:\Users\shayo\Dropbox (MIT)\Data\Xray/';
else
    startupFolder = '/Users/shayo/Dropbox (MIT)/data/Xray/FiberInsertionIntoAgar/';
end
startupFolder = pwd;

% if exist('xray_gui_cache.mat','file')
%     load('xray_gui_cache.mat');
% else
%     startupFolder = [pwd,filesep];
%     save('xray_gui_cache.mat','startupFolder');
% end

addpath(pwd); 

handles.cacheFolder = [fileparts(which('xray_gui.m')),filesep];
handles.currentActiveFolder = [];

Z = zeros(1024,1024);
handles.image1 = [];
handles.image2 = [];
handles.strctCalibration = [];
handles.activeCalibration = [];

handles.hImage1 = image(Z,'parent',handles.hDetector1Axes);
handles.hImage2 = image(Z,'parent',handles.hDetector2Axes);
handles.hImage1Features = [];
handles.hImage2Features = [];
handles.Features{1} = [];
handles.Features{2} = [];

colormap gray
axis(handles.hDetector1Axes,'off');
axis(handles.hDetector2Axes,'off');
hold(handles.hDetector1Axes,'on');
hold(handles.hDetector2Axes,'on');

handles.hEpiPolar1 = plot(handles.hDetector1Axes,[0 1,0 1],'y','LineWidth',2);
handles.hEpiPolar2 = plot(handles.hDetector2Axes,[0 1,0 1],'y','LineWidth',2);

handles.hMousePoint1 = plot(handles.hDetector1Axes,[0 0],'r.');
handles.hMousePoint2 = plot(handles.hDetector2Axes,[0 0],'r.');

set(handles.hEpiPolar1 ,'visible','off');
set(handles.hEpiPolar2 ,'visible','off');
set(handles.hMousePoint1 ,'visible','off');
set(handles.hMousePoint2 ,'visible','off');
set(handles.hReconstructionPanel,'visible','off');
ctx = uicontextmenu;
uimenu(ctx, 'Label', 'Goto','Callback', {@fnCallback,'Goto'});
uimenu(ctx, 'Label', 'Delete','Callback', {@fnCallback,'Delete'});

set(handles.hCalibrationListbox,'uiContextMenu',ctx);

ctx = uicontextmenu;
uimenu(ctx, 'Label', 'Clear Cache','Callback', {@fnCallback,'ClearCache'});
uimenu(ctx, 'Label', 'Copy Reconstruction','Callback', {@fnCallback,'Copy'});
uimenu(ctx, 'Label', 'Paste Reconstruction','Callback', {@fnCallback,'Paste'});
set(handles.hFolderListbox,'uiContextMenu',ctx);


load('cal1_CT_orderedCenters.mat');

handles.model3D = cal1_CT_orderedCenters;
guidata(hObject, handles);

cd(startupFolder);

changeCurrentFolder(handles,startupFolder);

loadCache(hObject,handles);


function fnCallback(hObject,b, str)
handles = guidata(hObject);
if strcmpi(str,'Goto')
elseif strcmpi(str,'Copy')
 
    selectedItem = get(handles.hFolderListbox,'value');
    allItems = get(handles.hFolderListbox,'String');
    newFolder = [pwd,filesep,allItems{selectedItem}];
    handles.sourceRecon = [newFolder,filesep,'reconstruction.mat'];
    guidata(hObject,handles);

elseif strcmpi(str,'Paste')    

    selectedItem = get(handles.hFolderListbox,'value');
    allItems = get(handles.hFolderListbox,'String');
    newFolder = [pwd,filesep,allItems{selectedItem}];
    targetRecon = [newFolder,filesep,'reconstruction.mat'];
    copyfile(handles.sourceRecon,targetRecon);
    setNewFolderAux (hObject,handles);
elseif strcmpi(str,'Delete')
    ButtonName = questdlg('Delete Calibration?', ...
        'Warning', ...
        'Yes', 'No','No');
    if strcmpi(ButtonName,'Yes')
        dbg = 1;
        selectedCalib = get(handles.hCalibrationListbox,'value');
        deleteCalibration(handles,selectedCalib);
    end
elseif strcmpi(str,'ClearCache')
    selectedItem = get(handles.hFolderListbox,'value');
    allItems = get(handles.hFolderListbox,'String');
    newFolder = [pwd,filesep,allItems{selectedItem}];
   
    try
        fprintf('Deleteing Cache\n');
        reconstructionFile = [newFolder,filesep,'reconstruction.mat'];
        delete(reconstructionFile);
        calibrationFile = [newFolder,filesep,'calibration.mat'];
        delete(calibrationFile);
        
    catch
    end
        setNewFolderAux (hObject,handles);
        
        
    
end



function  deleteCalibration(handles,selectedCalib)
cacheFile = [handles.cacheFolder,'xray_gui_cache.mat'];
load(cacheFile);
cache.calibrations(selectedCalib) = [];
save(cacheFile,'cache');
updateCalibrationList(handles,cache.calibrations);

function changeCurrentFolder(handles,folderName)
folderContents = dir(folderName);
subfolders = cat(1,folderContents.isdir);
set(handles.hFolderListbox,'String',{folderContents(subfolders).name},'value',1);



% --- Executes just before xray_gui is made visible.
function xray_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to xray_gui (see VARARGIN)

% Choose default command line output for xray_gui
handles.output = hObject;
initGUI(hObject,handles);
% Update handles structure

% UIWAIT makes xray_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = xray_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function dataFound = scanFolderForImages(newFolder,handles)
filesInFolder = dir(newFolder);
fileNames = {filesInFolder.name};
dataFound =  ismember('D1.tif',fileNames) && ismember('D2.tif',fileNames);
return;


function setNewDataFolder(hObject,handles,newFolder)
I1 = double(imread([newFolder,filesep,'D1.tif']));
I2 = double(imread([newFolder,filesep,'D2.tif']));
handles.dataFolder = newFolder;
handles.image1 = I1;
handles.image2 = I2;
set(handles.hImage1,'cdata',I1);
set(handles.hImage2,'cdata',I2);
set(handles.hImage1,'CDataMapping','scaled');
set(handles.hImage2,'CDataMapping','scaled');
         handles.currentActiveFolder = newFolder;
  

try
    delete(handles.hImage1Annotation);
catch
end
try 
    delete(handles.hImage2Annotation);
catch
end
handles.hImage1Annotation=[];
handles.hImage2Annotation=[];

initialWidth = 3;
set(handles.hDetector1Axes,'clim',[mean(I1(:))-initialWidth*std(I1(:)), mean(I1(:))+initialWidth*std(I1(:))]);
set(handles.hDetector2Axes,'clim',[mean(I2(:))-initialWidth*std(I2(:)), mean(I2(:))+initialWidth*std(I2(:))]);
set(handles.hDetector1Axes,'xlim',[1 1024],'ylim',[1 1024]);
set(handles.hDetector2Axes,'xlim',[1 1024],'ylim',[1 1024]);

rect_controller('deleteControllers');
corners = [100,100;
           100,400;
           400,400;
           400,100];

rect_controller('addController',handles.hDetector1Axes,corners);
rect_controller('addController',handles.hDetector2Axes,corners);

corners = [100,500;
           100,900;
           400,900;
           400,500];

rect_controller('addController',handles.hDetector1Axes,corners);
rect_controller('addController',handles.hDetector2Axes,corners);

corners = [500,500;
           500,900;
           900,900;
           900,500];

rect_controller('addController',handles.hDetector1Axes,corners);
rect_controller('addController',handles.hDetector2Axes,corners);

if get(handles.hAutomationLevel,'SelectedObject') == handles.hFullyAutomated
    rect_controller('hide');
end

% check if this folder has a calibration file...
% if so, load variables from there.
calibrationFile = [newFolder,filesep,'calibration.mat'];
if exist(calibrationFile,'file')
  
   load(calibrationFile);
   if isfield(strctCalibration,'corners')
   for k=1:6
    rect_controller('updateControllerCorners',k,strctCalibration.corners{k});
   end
   end
   
   handles.Features = strctCalibration.Features;
   guidata(hObject, handles);
  handles = plotFeatures(handles);
    guidata(hObject, handles);
 
end



%%

axes_controller('deleteControllers');
corners = [100,100;
           100,400;
           400,400];

line_corners = [500,100;
           500,800];
       
axes_controller('addController',handles.hDetector1Axes,corners);
axes_controller('addController',handles.hDetector2Axes,corners);

axes_controller('addController',handles.hDetector1Axes,line_corners);
axes_controller('addController',handles.hDetector2Axes,line_corners);


   
reconstructionFile = [newFolder,filesep,'reconstruction.mat'];
if exist(reconstructionFile,'file')
   load(reconstructionFile);
   for k=1:4
    axes_controller('updateControllerCorners',k,strctReconstruction.corners{k});
   end
   axes_controller('redraw');
end


if strcmpi(get(handles.hMode,'String'),'Calibration Mode')
    axes_controller('hide');
else
    rect_controller('hide');
    axes_controller('override_mouse', {@mouseMove,handles});

end

guidata(hObject, handles);
return

function saveChanges(handles)
if ~isempty(handles.currentActiveFolder) 
    strctReconstruction.corners = axes_controller('getcontrollersCorners');
    if ~isempty(strctReconstruction.corners)
        reconstructionFile = [handles.currentActiveFolder,filesep,'reconstruction.mat'];
       save(reconstructionFile, 'strctReconstruction');
    end
end


function setNewFolderAux (hObject,handles)

selectedItem = get(handles.hFolderListbox,'value');
allItems = get(handles.hFolderListbox,'String');
newFolder = [pwd,filesep,allItems{selectedItem}];

if ~strcmp(get(gcf,'SelectionType'),'open')
     if scanFolderForImages(newFolder,handles)
         setNewDataFolder(hObject,handles,newFolder);
     end
     return;
 end
% double click. Change to a new folder...

 cd(newFolder);
 changeCurrentFolder(handles,pwd);
 
% --- Executes on selection change in hFolderListbox.
function hFolderListbox_Callback(hObject, eventdata, handles)
%% save changes to the existing?
saveChanges(handles);
setNewFolderAux (hObject,handles);
 
 

% --- Executes during object creation, after setting all properties.
function hFolderListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFolderListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [Features, rects] = autoSegment(im)
% Heuristic segmentation. Matlab's circular hough doesn't work for small
% blobs :(
Thres =  median(im(:));
L=bwlabel(im <Thres);
R=regionprops(L,'Area','Centroid');
C = cat(1,R.Centroid);
A = cat(1,R.Area);

PossibleFeatures = find(A >= 70 & A <= 1000);
% Try to erode other components and separate them (?)
medianArea = median(A(PossibleFeatures));
stdArea = mad(A(PossibleFeatures),1);

SeparatedFeatures = PossibleFeatures(  A(PossibleFeatures) >= medianArea-5*stdArea & ...
    A(PossibleFeatures) <= medianArea+5*stdArea);

Lwell_sep = zeros(size(L));
for k=1:length(SeparatedFeatures)
    Lwell_sep = Lwell_sep | L == SeparatedFeatures(k);
end

GluedFeatures = setdiff(PossibleFeatures,SeparatedFeatures);
L2 = zeros(size(L));
for k=1:length(GluedFeatures)
    L2 = L2 | L == GluedFeatures(k);
end
D=-bwdist(~L2);
D(~L2) = -Inf;
W=watershed(D);
D2 = bwdist( ~ (W > 1));
L3 = bwlabel(Lwell_sep>0 | (D2 > 1));

R=regionprops(L3,'Centroid');
Features = cat(1,R.Centroid);

[group_assignment, coordinates_in_group] = heuristic_feature_to_model(Features);


%figure(12);clf;imagesc(im);hold on;colormap gray;
for group=1:3
    group1indx = find(group_assignment==group);
    
    
    H=RANSAC_homography(coordinates_in_group(group1indx,:)',...
        [Features(group1indx,1),Features(group1indx,2)]',1000);
    
    corners = [1 1 4 4
        1 4 4 1
        1 1 1 1];
    tmp=H*corners;
    P=[tmp(1,:)./tmp(3,:);tmp(2,:)./tmp(3,:)]';
    rects{group} = P;
    if 0
        plot(Features(group1indx,1),Features(group1indx,2),'go');
        plot(P(:,1),P(:,2),'mo','LineWidth',2);
        for j=1:length(group1indx)
            text(Features(group1indx(j),1),Features(group1indx(j),2)-10,sprintf('%d %d',...
                coordinates_in_group(group1indx(j),1),coordinates_in_group(group1indx(j),2)));
        end
    end
    
end

% Group 1 is the top most one. (hopefully 15)
% Group 2 is bottom one with more components. (hopefully 16)
% Group 3 is the bottom one with less components...(hopefully 13)


function newhandles = plotFeatures(handles)
try
    delete(handles.hImage1Annotation);
catch
end
try 
    delete(handles.hImage2Annotation);
catch
end
rect_controller('redraw');

if ~isempty(handles.Features{1})
    handles.hImage1Annotation = plot(handles.hDetector1Axes, handles.Features{1}(:,1),handles.Features{1}(:,2),'g.','hittest','off');
    set(handles.hDetector1Axes,'xlim', [min(handles.Features{1}(:,1)), max(handles.Features{1}(:,1))]+[-40 40]);
    set(handles.hDetector1Axes,'ylim', [min(handles.Features{1}(:,2)), max(handles.Features{1}(:,2))]+ [-40 40]);
   
end
if ~isempty(handles.Features{2})

    handles.hImage2Annotation = plot(handles.hDetector2Axes, handles.Features{2}(:,1),handles.Features{2}(:,2),'g.','hittest','off');
    set(handles.hDetector2Axes,'xlim', [min(handles.Features{2}(:,1)), max(handles.Features{2}(:,1))]+[-40 40]);
    set(handles.hDetector2Axes,'ylim', [min(handles.Features{2}(:,2)), max(handles.Features{2}(:,2))]+ [-40 40]);
 
    
end

if ~isempty(handles.strctCalibration)
    % draw projection of model back on images
    x3Dh = [handles.model3D, ones(size(handles.model3D,1),1)]';
    x2Dh = handles.strctCalibration.P1 * x3Dh;
    xx = x2Dh(1,:)./x2Dh(3,:);
    yy = x2Dh(2,:)./x2Dh(3,:);
    handles.hImage1Annotation = [handles.hImage1Annotation,...
        plot(handles.hDetector1Axes, xx,yy,'r.')];
   
    x2Dh = handles.strctCalibration.P2 * x3Dh;
    xx = x2Dh(1,:)./x2Dh(3,:);
    yy = x2Dh(2,:)./x2Dh(3,:);
    handles.hImage2Annotation = [handles.hImage2Annotation,...
        plot(handles.hDetector2Axes, xx,yy,'r.')];
    
end

newhandles = handles;

% --- Executes on selection change in hDetector1Features.
function hDetector1Features_Callback(hObject, eventdata, handles)
handles = plotFeatures(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function hDetector1Features_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDetector1Features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hCalibrationListbox.
function hCalibrationListbox_Callback(hObject, eventdata, handles)
% make this the active calibration...
cacheFile = [handles.cacheFolder,'xray_gui_cache.mat'];
if exist(cacheFile,'file')
    selectedCalib = get(handles.hCalibrationListbox,'value');
    calibNames = get(handles.hCalibrationListbox,'String');
    
    
    load(cacheFile);
    fprintf('Setting active calibration to %s\n',calibNames{selectedCalib});
    handles.activeCalibration = cache.calibrations{selectedCalib};
    guidata(hObject,handles);
end
% --- Executes during object creation, after setting all properties.
function hCalibrationListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCalibrationListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hDetector2Features.
function hDetector2Features_Callback(hObject, eventdata, handles)
handles = plotFeatures(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function hDetector2Features_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDetector2Features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in hSelectFolder.
function hSelectFolder_Callback(hObject, eventdata, handles)
newFolder=uigetdir();
if newFolder(1) == 0
    return
end
cd(newFolder);
changeCurrentFolder(handles,pwd);


function mouseMove(handles)
C = get (handles.hDetector1Axes, 'CurrentPoint');
D1Xlim = get (handles.hDetector1Axes, 'xlim');
D1Ylim = get (handles.hDetector1Axes, 'ylim');

D2Xlim = get (handles.hDetector2Axes, 'xlim');
D2Ylim = get (handles.hDetector2Axes, 'ylim');

x1=C(1,1);
y1=C(1,2);
C = get (handles.hDetector2Axes, 'CurrentPoint');
x2=C(1,1);
y2=C(1,2);

set(handles.hMousePoint1 ,'visible','off');
set(handles.hEpiPolar2 ,'visible','off');

set(handles.hMousePoint2 ,'visible','off');
set(handles.hEpiPolar1 ,'visible','off');

if ~isempty(handles.activeCalibration)
    
    if (x1 > D1Xlim(1) && y1 > D1Ylim(1) && x1 < D1Xlim(2) && y1 < D1Ylim(2))
        if ~isempty(handles.activeCalibration)
            % Plot epipolar line for feature1 on the second image...
            ln1 = handles.activeCalibration.F*[x1;y1;1];
            xx = linspace(0,1024);
            yy = (-ln1(3)-xx*ln1(1))./ln1(2);
            
            set(handles.hMousePoint1 ,'xdata',x1,'ydata',y1,'visible','on');
            set(handles.hEpiPolar2 ,'xdata',xx,'ydata',yy,'visible','on');
            
            set(handles.hMousePoint2 ,'visible','off');
            set(handles.hEpiPolar1 ,'visible','off');
            
            
            
        end
    end
    
    if (x2 > D2Xlim(1) && y2 > D2Ylim(1) && x2 < D2Xlim(2) && y2 < D2Ylim(2))
        ln1 = handles.activeCalibration.F'*[x2;y2;1];
        xx = linspace(0,1024);
        yy = (-ln1(3)-xx*ln1(1))./ln1(2);
        
        set(handles.hMousePoint2 ,'xdata',x2,'ydata',y2,'visible','on');
        set(handles.hEpiPolar1 ,'xdata',xx,'ydata',yy,'visible','on');
        
        set(handles.hMousePoint1 ,'visible','off');
        set(handles.hEpiPolar2 ,'visible','off');
        
    end
    
    compute_3D_coordinates(handles);
    
end

function compute_3D_coordinates(handles)
   
ctr=axes_controller('getcontrollersCorners');
%% compute the 3D coordinates of the axes...

Axes3DCoor = Triangulation(ctr{1}',ctr{2}',handles.activeCalibration.P1,handles.activeCalibration.P2);
frameOrigin = Axes3DCoor(1:3,1);
% build an orthnormal basis 
% Treat the first point as the origin.
v1 = Axes3DCoor(1:3,2)-Axes3DCoor(1:3,1);
v2 = Axes3DCoor(1:3,3)-Axes3DCoor(1:3,1);
v3 = cross(v1,v2);

[Basis3D,R]=qr([v1,v2,v3]);

%%
p1 = ctr{3}(1,:);
p2 = ctr{3}(2,:);
if p2(2) < p1(2)
    tmp=p1;
    p1 = p2;
    p2 = tmp;
end
linedir = (p2-p1);
linedir=linedir./norm(linedir);
% generate samples along the line
linelength1 = norm(p2-p1);
t1=linspace(0, linelength1,100);
intensity1=interp2(handles.image1,p1(1) + t1 * linedir(1),p1(2) + t1 * linedir(2));

p3 = ctr{4}(1,:);
p4 = ctr{4}(2,:);

if p4(2) < p3(2)
    tmp=p3;
    p3 = p4;
    p4 = tmp;
end

linedir = (p4-p3);
linedir=linedir./norm(linedir);
% generate samples along the line
linelength2 = norm(p4-p3);
t2=linspace(0, linelength2,100);
intensity2=interp2(handles.image2,p3(1) + t2 * linedir(1),p3(2) + t2 * linedir(2));


% compute 3D coordinates...
LineTip = Triangulation(p2',p4',handles.activeCalibration.P1,handles.activeCalibration.P2);

LineTop = Triangulation(p1',p3',handles.activeCalibration.P1,handles.activeCalibration.P2);

if get(handles.hReference,'SelectedObject') == handles.hReferenceWorld
    set(handles.hTipX,'String', sprintf('X %.1f',LineTip(1)));
    set(handles.hTipY,'String', sprintf('Y %.1f',LineTip(2)));
    set(handles.hTipZ,'String', sprintf('Z %.1f',LineTip(3)));
    
    plot(handles.hLineAxes, t1,intensity1,t2,intensity2);

elseif get(handles.hReference,'SelectedObject') == handles.hReferenceFrame
    set(handles.hTipX,'String', sprintf('X %.1f',LineTip(1)-frameOrigin(1)));
    set(handles.hTipY,'String', sprintf('Y %.1f',LineTip(2)-frameOrigin(2)));
    set(handles.hTipZ,'String', sprintf('Z %.1f',LineTip(3)-frameOrigin(3)));
    
    plot(handles.hLineAxes, t1,intensity1,t2,intensity2);

elseif get(handles.hReference,'SelectedObject') == handles.hReferenceLine
    
    plot(handles.hLineAxes, t1,intensity1,t2,intensity2);

    set(handles.hTipX,'String', sprintf('X'));
    set(handles.hTipY,'String', sprintf('Y'));
    set(handles.hTipZ,'String', sprintf('Z %.1f', norm(LineTop-LineTip )));
    
end


 %             
% mouseDown=getappdata(handles.figure1,'mouseDown');
% %mouseDownPosition=getappdata(handles.figure1,'mouseDownPosition');

function mouseDown(obj,A,fig)
handles = guidata(fig);
C = get (handles.hDetector1Axes, 'CurrentPoint');
x=C(1,1);
y=C(1,2);
setappdata(handles.figure1,'mouseDown',true);


function mouseUp(obj,A,fig)
handles = guidata(fig);
C = get (handles.hDetector2Axes, 'CurrentPoint');
x=C(1,1);
y=C(1,2);
setappdata(handles.figure1,'mouseDown',false);

function loadCache(hObject,handles)
cacheFile = [handles.cacheFolder,'xray_gui_cache.mat'];
if exist(cacheFile,'file')
    load(cacheFile);
    updateCalibrationList(handles,cache.calibrations);
    if ~isempty(cache.calibrations)
        handles.activeCalibration = cache.calibrations{end};
        guidata(hObject,handles);
    end
else
    set(handles.hCalibrationListbox,'String',[]);
    
end




function updateCalibrationList(handles,calibrations)
% search if this calibration already exist....
folders = {};
for k=1:length(calibrations)
    idx=find(calibrations{k}.dataFolder == '/' | ...
        calibrations{k}.dataFolder == '\' ,1,'last') ;
    folders{k} = calibrations{k}.dataFolder(idx+1:end);
end
set(handles.hCalibrationListbox,'String',folders,'value',1);
    
    
function addCalibToCache(handles, strctCalibration)
cacheFile = [handles.cacheFolder,'xray_gui_cache.mat'];
if exist(cacheFile,'file')
    load(cacheFile);
    % search if this calibration already exist....
    if isempty(cache.calibrations)
        indx = [];
    else
      for k=1:length(cache.calibrations)
          folders{k} = cache.calibrations{k}.dataFolder;
      end
         indx = find(ismember(folders, strctCalibration.dataFolder));

    end
     if ~isempty(indx)
        % replace
        fprintf('Replacing cached calibration\n');
        cache.calibrations{indx}=strctCalibration;
    else
        % add
        fprintf('Adding to calibrations cache\n');
        cache.calibrations{end+1}=strctCalibration;
    end
    save(cacheFile,'cache');
else
    % create a new cache file
    cache.calibrations{1} = strctCalibration;
    save(cacheFile,'cache');
end
updateCalibrationList(handles,cache.calibrations);



% --- Executes on button press in hGenerateCalibration.
function hGenerateCalibration_Callback(hObject, eventdata, handles)
fullAutomation = get(handles.hAutomationLevel,'SelectedObject') == handles.hFullyAutomated;
useUserDefinedRectsAndFeatures = get(handles.hAutomationLevel,'SelectedObject') == handles.hSemiAutomated1;
useUserDefinedRectsWithoutFeatures = get(handles.hAutomationLevel,'SelectedObject') == handles.hSemiAutomated2;

try
if fullAutomation || useUserDefinedRectsAndFeatures
    [Features{1}, rects1] = autoSegment(handles.image1);
    [Features{2}, rects2] = autoSegment(handles.image2);
end
catch
   fprintf('Auto segmentation failed. Try to move the rectangles, or switch to semi-automation without features\n'); 
    return;
end

if fullAutomation
 % update controllers
 rect_controller('updateControllerCorners',1,rects1{1});
 rect_controller('updateControllerCorners',3,rects1{3});
 rect_controller('updateControllerCorners',5,rects1{2});
 
 rect_controller('updateControllerCorners',2,rects2{1});
 rect_controller('updateControllerCorners',4,rects2{3});
 rect_controller('updateControllerCorners',6,rects2{2});
 
 rect_controller('redraw');

end

controllers = rect_controller('getcontrollers');

corners = rect_controller('getcontrollersCorners');



if 0
    hfig=figure(12);clf;
    for k=1:2
        subplot(1,2,k);
        plot3(handles.model3D(:,1),handles.model3D(:,2),handles.model3D(:,3),'.');
        hold on;
        for k=1:44
            text(handles.model3D(k,1),handles.model3D(k,2),handles.model3D(k,3), num2str(k))
        end
    end
    cameratoolbar(hfig,'show');
end
%% Match rect 
[P1,H]=getAllCoordinatesFromCorners(controllers(1).corners, 4);
[P1t,H]=getAllCoordinatesFromCorners(controllers(2).corners, 4);

[P2,H]=getAllCoordinatesFromCorners(controllers(3).corners, 4);
[P2t,H]=getAllCoordinatesFromCorners(controllers(4).corners, 4);
% assume P2 controller has 13 points...

[P3,H]=getAllCoordinatesFromCorners(controllers(5).corners, 4);
[P3t,H]=getAllCoordinatesFromCorners(controllers(6).corners, 4);
x3D = handles.model3D;


if fullAutomation || useUserDefinedRectsAndFeatures
    % Generate possible feature permutations...
    
    
    FeaturePerm = generateFeaturePermutation(P1,P1t,P2,P2t,P3,P3t);
    dist_thres = 15;
    x3Dh = [x3D';ones(1, size(x3D,1))];
    best_err = Inf;
    seletedPerm = 0;
    numRansacIter = 50;
    for k=1:length(FeaturePerm)
        [~, f1_matched]=nearestPoint(FeaturePerm{k}{1}, Features{1}, dist_thres);
        [~, f1t_matched]=nearestPoint(FeaturePerm{k}{2}, Features{2}, dist_thres);
        match_both = find( sum(f1_matched,2) ~= 0 &        sum(f1t_matched,2) ~= 0);
        
        Features2{1} = f1_matched(match_both,:);
        Features2{2} = f1t_matched(match_both,:);
        
        [Proj1,Proj2,rec_Err]=ComputeCameraMatricesFromFeaturesAndModel3(Features2,x3D(match_both,:),numRansacIter,false);
        if  rec_Err < best_err
            fprintf('Best error to model: %.2f\n',rec_Err);
            seletedPerm = k;
            best_err = mean(rec_Err) ;
        end
    end
    
    [~, f1_matched]=nearestPoint(FeaturePerm{seletedPerm}{1}, Features{1}, dist_thres);
    [~, f1t_matched]=nearestPoint(FeaturePerm{seletedPerm}{2}, Features{2}, dist_thres);
    match_both = find( sum(f1_matched,2) ~= 0 &        sum(f1t_matched,2) ~= 0);
    
    Features2{1} = f1_matched(match_both,:);
    Features2{2} = f1t_matched(match_both,:);
    
    [Proj1,Proj2,rec_Err]=ComputeCameraMatricesFromFeaturesAndModel3(Features2,x3D(match_both,:),150,true);
    fprintf('Best error to model: %.2f um\n',rec_Err);
else
    Features{1} = [P1(setdiff(1:16,4),:);
        P2([1,2,3,5,6,7,8,9,10,11,12,14,15],:);
        P3];
    Features{2} = [P1t(setdiff(1:16,4),:);
        P2t([1,2,3,5,6,7,8,9,10,11,12,14,15],:);
        P3t];
    
    [Proj1,Proj2,rec_Err]=ComputeCameraMatricesFromFeaturesAndModel3(Features,x3D,150,true);
    fprintf('Best error to model: %.2f um\n',rec_Err);
    
end


% save all relevant information in a single structure.
strctCalibration.dataFolder = handles.dataFolder;
strctCalibration.P1 = Proj1;
strctCalibration.P2 = Proj2;
strctCalibration.corners = corners;
strctCalibration.goodnessOfFit = rec_Err; % smaller the better, represents mean distance to marked features.
strctCalibration.Features = Features2;
strctCalibration.ModelIndices = match_both;
strctCalibration.x3D = x3D;
strctCalibration.F=ProjectionMatrixToFundamental(Proj1,Proj2);

handles.strctCalibration = strctCalibration;
guidata(hObject,handles);
% display calibration result


% dump to disk
save([handles.dataFolder,filesep,'calibration.mat'],'strctCalibration');
handles = plotFeatures(handles);
guidata(hObject, handles);

% add calibration to cache...
addCalibToCache(handles,strctCalibration);




% --- Executes on button press in hAddFeatures.
function hAddFeatures_Callback(hObject, eventdata, handles)


% --- Executes on button press in hFullyAutomated.
function hFullyAutomated_Callback(hObject, eventdata, handles)
% hObject    handle to hFullyAutomated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hFullyAutomated


% --- Executes on button press in hSemiAutomated1.
function hSemiAutomated1_Callback(hObject, eventdata, handles)
% hObject    handle to hSemiAutomated1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hSemiAutomated1


% --- Executes on button press in hSemiAutomated2.
function hSemiAutomated2_Callback(hObject, eventdata, handles)
% hObject    handle to hSemiAutomated2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hSemiAutomated2


% --- Executes on button press in hManualMode.
function hManualMode_Callback(hObject, eventdata, handles)


% --- Executes on button press in hMode.
function hMode_Callback(hObject, eventdata, handles)
%s    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.hMode,'String'),'Calibration Mode')
    set(handles.hMode,'String','Reconstruction Mode')
    set(handles.hAutomationLevel,'Visible','off')
    
    %            set (gcf, 'WindowButtonMotionFcn', {@mouseMove, gcf});
    axes_controller('show');
    rect_controller('hide');
    
    axes_controller('override_mouse', {@mouseMove,handles});
    
    set(handles.hReconstructionPanel,'visible','on');
%     
%      set(handles.hLineAxes,'visible','on');
%      set(handles.hReference,'visible','on');
%     set(handles.hTipX,'visible','off');
%     set(handles.hTipY,'visible','off');
%     set(handles.hTipZ,'visible','off');
    
else
    set(handles.hMode,'String','Calibration Mode')
    set(handles.hAutomationLevel,'Visible','on')
    rect_controller('override_mouse');
    axes_controller('hide');
    rect_controller('show');
    set(handles.hEpiPolar1 ,'visible','off');
    set(handles.hEpiPolar2 ,'visible','off');
    set(handles.hMousePoint1 ,'visible','off');
    set(handles.hMousePoint2 ,'visible','off');
    
    set(handles.hReconstructionPanel,'visible','off');
%     cla(handles.hLineAxes);
%     set(handles.hLineAxes,'visible','off');
%     set(handles.hReference,'visible','off');
%     set(handles.hTipX,'visible','off');
%     set(handles.hTipY,'visible','off');
%     set(handles.hTipZ,'visible','off');
%    
    fullAutomation = get(handles.hAutomationLevel,'SelectedObject') == handles.hFullyAutomated;
    if fullAutomation
        rect_controller('hide');
    else
           rect_controller('show');
    end
    
  
end


% --- Executes when selected object is changed in hAutomationLevel.
function hAutomationLevel_SelectionChangedFcn(hObject, eventdata, handles)

if get(handles.hAutomationLevel,'SelectedObject') == handles.hFullyAutomated
    rect_controller('hide');
else
    rect_controller('show');
end


% --- Executes on button press in hReadoutCoordinate.
function hReadoutCoordinate_Callback(hObject, eventdata, handles)
% hObject    handle to hReadoutCoordinate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hReadoutCoordinate


% --- Executes on button press in hReferenceFrame.
function hReferenceFrame_Callback(hObject, eventdata, handles)
% hObject    handle to hReferenceFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hReferenceFrame
