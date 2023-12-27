function varargout = line_controller(command, varargin)
varargout = {};

if strcmpi(command,'redraw')
  lineControllers=getappdata(gcf,'lineControllers');
  
  for k=1:length(lineControllers)
      lineControllers(k).handles = drawLineController(lineControllers(k));        
  end
    setappdata(gcf,'lineControllers',lineControllers);  
end

if strcmpi(command,'hide')
    lineControllers=getappdata(gcf,'lineControllers');
  
    for k=1:length(lineControllers)
           set(lineControllers(k).handles.lines,'visible','off');
           set(lineControllers(k).handles.corners,'visible','off');
           set(lineControllers(k).handles.text,'visible','off');
    end
end
if strcmpi(command,'show')
    lineControllers=getappdata(gcf,'lineControllers');
  
    for k=1:length(lineControllers)
           set(lineControllers(k).handles.lines,'visible','on');
           set(lineControllers(k).handles.corners,'visible','on');
           set(lineControllers(k).handles.text,'visible','on');
    end
end
if strcmpi(command,'deleteControllers')
   lineControllers=getappdata(gcf,'lineControllers');
   for k=1:length(lineControllers)
       clearControllerHandles(lineControllers(k));
   end
     setappdata(gcf,'lineControllers',[]);  
end

if strcmpi(command,'getcontrollers')
      lineControllers=getappdata(gcf,'lineControllers');
        varargout{1}=lineControllers;
end

if strcmpi(command,'getcontrollersCorners')
      lineControllers=getappdata(gcf,'lineControllers');
      for k=1:length(lineControllers)
          corners{k} = lineControllers(k).corners;
      end
        varargout{1}=corners;
end

if strcmpi(command,'updateControllerCorners')
      lineControllers=getappdata(gcf,'lineControllers');
      controller_index = varargin{1};
      rect = varargin{2};
      lineControllers(controller_index).corners =rect;
      setappdata(gcf,'lineControllers',lineControllers);
end

if strcmpi(command,'override_mouse')
    parentMouseController = varargin{1};
      set (gcf, 'WindowButtonMotionFcn', {@mouseMove, gcf,parentMouseController});
      set (gcf, 'WindowButtonDownFcn', {@mouseDown, gcf});
      set (gcf, 'WindowButtonUpFcn', {@mouseUp, gcf});
end

if strcmpi(command,'addController')
    lineControllers=getappdata(gcf,'lineControllers');
  
    
    whichAxes = varargin{1};
    corners = varargin{2};
    fig = get(whichAxes,'parent');
    
    if isempty(lineControllers)
        lineControllers = createLineController(whichAxes,4,corners,1);
    else
        lastID = lineControllers(end).ID;
        lineControllers(end+1) = createLineController(whichAxes,4,corners,lastID+1);
    end
    setappdata(fig,'lineControllers',lineControllers);
end


function strctController = createLineController(hAxes,N,corners,ID)
strctController.corners = corners;
strctController.N = N;
strctController.ID = ID;
strctController.hAxes = hAxes;
strctController.handles = [];
strctController.handles = drawLineController(strctController)    ;                 


function clearControllerHandles(strctController)
try
    delete(strctController.handles.lines);
    delete(strctController.handles.corners);
    delete(strctController.handles.text);
catch
end

function handles = drawLineController(strctController)    
clearControllerHandles(strctController);

handles.lines = [];
pairs = [1,2];
hAxes = strctController.hAxes;
corners = strctController.corners;
for k=1:1
    handles.lines(k) = plot(hAxes, [corners(pairs(k,1),1) corners(pairs(k,2),1)], ...
        [corners(pairs(k,1),2) corners(pairs(k,2),2)],'color','m');
    set(handles.lines(k),'HitTest','off');    
end
handles.text = [];
% for k=1:3
%     handles.text(k) =text(corners(k,1),corners(k,2),num2str(k), 'parent',hAxes,'HitTest','off','color','m');
% end

for k=1:2
    handles.corners(k) = plot(hAxes,corners(k,1),corners(k,2),'go','LineWidth',2);
    set(handles.corners(k),'ButtonDownFcn', {@mouseclick,strctController.ID,k})
    
end

function mouseclick(a,bl,id,cornerindex)
fig = get(get(a,'Parent'),'Parent');
setappdata(fig,'selectedCorner',[id,cornerindex]);

function mouseMove(fig,b,c,parentMouseController)
feval(parentMouseController{1},parentMouseController{2});
selectedCorner=getappdata(fig,'selectedCorner');
mouseDown = getappdata(fig,'mouseDown');
if ~isempty(mouseDown) && mouseDown && ~isempty(selectedCorner)
    id = selectedCorner(1);
    vertex = selectedCorner(2);
   % fprintf('Dragging %d,%d\n',selectedCorner(1),selectedCorner(2));
    
    
    C = get (gca, 'CurrentPoint');
    newpos = [C(1,1), C(1,2)];
    
    lineControllers=getappdata(fig,'lineControllers');
    
    lineControllers(id).corners(vertex,:) = newpos;
    lineControllers(id).handles = drawLineController(lineControllers(id));    
    setappdata(fig,'lineControllers',lineControllers);

end

function mouseDown(fig,b,c)
setappdata(fig,'mouseDown',true);


function mouseUp(fig,b,c)
setappdata(fig,'mouseDown',false);
setappdata(fig,'selectedCorner',[]);
