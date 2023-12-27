function varargout = rect_controller(command, varargin)
varargout = {};

if strcmpi(command,'redraw')
  rectControllers=getappdata(gcf,'rectControllers');
  
  for k=1:length(rectControllers)
      rectControllers(k).handles = drawRectController(rectControllers(k));        
  end
    setappdata(gcf,'rectControllers',rectControllers);  
end

if strcmpi(command,'hide')
    rectControllers=getappdata(gcf,'rectControllers');
  
    for k=1:length(rectControllers)
           set(rectControllers(k).handles.lines,'visible','off');
           set(rectControllers(k).handles.insideSpots,'visible','off');
           set(rectControllers(k).handles.corners,'visible','off');
           set(rectControllers(k).handles.text,'visible','off');
    end
end
if strcmpi(command,'show')
    rectControllers=getappdata(gcf,'rectControllers');
  
    for k=1:length(rectControllers)
           set(rectControllers(k).handles.lines,'visible','on');
           set(rectControllers(k).handles.insideSpots,'visible','on');
           set(rectControllers(k).handles.corners,'visible','on');
           set(rectControllers(k).handles.text,'visible','on');
    end
end
if strcmpi(command,'deleteControllers')
   rectControllers=getappdata(gcf,'rectControllers');
   for k=1:length(rectControllers)
       clearControllerHandles(rectControllers(k));
   end
     setappdata(gcf,'rectControllers',[]);  
end

if strcmpi(command,'getcontrollers')
      rectControllers=getappdata(gcf,'rectControllers');
        varargout{1}=rectControllers;
end

if strcmpi(command,'getcontrollersCorners')
      rectControllers=getappdata(gcf,'rectControllers');
      for k=1:length(rectControllers)
          rects{k} = rectControllers(k).corners;
      end
        varargout{1}=rects;
end

if strcmpi(command,'updateControllerCorners')
      rectControllers=getappdata(gcf,'rectControllers');
      controller_index = varargin{1};
      rect = varargin{2};
      rectControllers(controller_index).corners =rect;
      setappdata(gcf,'rectControllers',rectControllers);
end

if strcmpi(command,'override_mouse')
      set (gcf, 'WindowButtonMotionFcn', {@mouseMove, gcf});
      set (gcf, 'WindowButtonDownFcn', {@mouseDown, gcf});
      set (gcf, 'WindowButtonUpFcn', {@mouseUp, gcf});
end

if strcmpi(command,'addController')
    rectControllers=getappdata(gcf,'rectControllers');
  if isempty(rectControllers)
      
      set (gcf, 'WindowButtonMotionFcn', {@mouseMove, gcf});
      set (gcf, 'WindowButtonDownFcn', {@mouseDown, gcf});
      set (gcf, 'WindowButtonUpFcn', {@mouseUp, gcf});
  end
    
    whichAxes = varargin{1};
    rectPos = varargin{2};
    fig = get(whichAxes,'parent');
    
    if isempty(rectControllers)
        rectControllers = createRectController(whichAxes,4,rectPos,1);
    else
        lastID = rectControllers(end).ID;
        rectControllers(end+1) = createRectController(whichAxes,4,rectPos,lastID+1);
    end
    setappdata(fig,'rectControllers',rectControllers);
end


function strctController = createRectController(hAxes,N,corners,ID)
strctController.corners = corners;
strctController.N = N;
strctController.ID = ID;
strctController.hAxes = hAxes;
strctController.handles = [];
strctController.handles = drawRectController(strctController)    ;                 


function clearControllerHandles(strctController)
try
    delete(strctController.handles.lines);
    delete(strctController.handles.insideSpots);
    delete(strctController.handles.corners);
    delete(strctController.handles.text);
catch
end

function handles = drawRectController(strctController)    
clearControllerHandles(strctController);

handles.lines = [];
pairs = [1,2;2,3;3,4;4,1];
hAxes = strctController.hAxes;
corners = strctController.corners;
for k=1:4
    handles.lines(k) = plot(hAxes, [corners(pairs(k,1),1) corners(pairs(k,2),1)], [corners(pairs(k,1),2) corners(pairs(k,2),2)],'g');
    set(handles.lines(k),'HitTest','off');    
end

[P,H]=getAllCoordinatesFromCorners(corners, strctController.N);
if strctController.ID == 1 || strctController.ID == 2 
    subset = setdiff(1:16,4);
    offset = 0;
elseif strctController.ID == 3 || strctController.ID == 4 
    subset = setdiff(1:16,[4,13,16]);
    offset = 15;
elseif strctController.ID == 5 || strctController.ID == 6 
    subset = 1:16;
    offset = 28;
end

for k=1:length(subset)
    handles.text(k) =text(P(subset(k),1) - 15,P(subset(k),2)-15, ...
        sprintf('%d',offset+k), 'parent',hAxes,'HitTest','off','color','m');
end

handles.insideSpots = plot(hAxes, P(:,1),P(:,2),'co','HitTest','off');
for k=1:4
    handles.corners(k) = plot(hAxes,corners(k,1),corners(k,2),'ro','LineWidth',2);
    set(handles.corners(k),'ButtonDownFcn', {@mouseclick,strctController.ID,k})
    
end

function mouseclick(a,bl,id,cornerindex)
fig = get(get(a,'Parent'),'Parent');
setappdata(fig,'selectedCorner',[id,cornerindex]);

function mouseMove(fig,b,c)
selectedCorner=getappdata(fig,'selectedCorner');
mouseDown = getappdata(fig,'mouseDown');
if ~isempty(mouseDown) && mouseDown && ~isempty(selectedCorner)
    id = selectedCorner(1);
    vertex = selectedCorner(2);
   % fprintf('Dragging %d,%d\n',selectedCorner(1),selectedCorner(2));
    
    
    C = get (gca, 'CurrentPoint');
    newpos = [C(1,1), C(1,2)];
    
    rectControllers=getappdata(fig,'rectControllers');
    
    rectControllers(id).corners(vertex,:) = newpos;
    rectControllers(id).handles = drawRectController(rectControllers(id));    
    setappdata(fig,'rectControllers',rectControllers);

end

function mouseDown(fig,b,c)
setappdata(fig,'mouseDown',true);


function mouseUp(fig,b,c)
setappdata(fig,'mouseDown',false);
setappdata(fig,'selectedCorner',[]);
