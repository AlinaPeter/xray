function varargout = axes_controller(command, varargin)
varargout = {};

if strcmpi(command,'redraw')
  axesControllers=getappdata(gcf,'axesControllers');
  
  for k=1:length(axesControllers)
      axesControllers(k).handles = drawAxesController(axesControllers(k));        
  end
    setappdata(gcf,'axesControllers',axesControllers);  
end

if strcmpi(command,'hide')
    axesControllers=getappdata(gcf,'axesControllers');
  
    for k=1:length(axesControllers)
           set(axesControllers(k).handles.lines,'visible','off');
           set(axesControllers(k).handles.corners,'visible','off');
           set(axesControllers(k).handles.text,'visible','off');
    end
end
if strcmpi(command,'show')
    axesControllers=getappdata(gcf,'axesControllers');
  
    for k=1:length(axesControllers)
           set(axesControllers(k).handles.lines,'visible','on');
           set(axesControllers(k).handles.corners,'visible','on');
           set(axesControllers(k).handles.text,'visible','on');
    end
end
if strcmpi(command,'deleteControllers')
   axesControllers=getappdata(gcf,'axesControllers');
   for k=1:length(axesControllers)
       clearControllerHandles(axesControllers(k));
   end
     setappdata(gcf,'axesControllers',[]);  
end

if strcmpi(command,'getcontrollers')
      axesControllers=getappdata(gcf,'axesControllers');
        varargout{1}=axesControllers;
end

if strcmpi(command,'getcontrollersCorners')
      axesControllers=getappdata(gcf,'axesControllers');
      corners = cell(1,length(axesControllers));
      
      for k=1:length(axesControllers)
          corners{k} = axesControllers(k).corners;
      end
        varargout{1}=corners;
end

if strcmpi(command,'updateControllerCorners')
      axesControllers=getappdata(gcf,'axesControllers');
      controller_index = varargin{1};
      rect = varargin{2};
      axesControllers(controller_index).corners =rect;
      setappdata(gcf,'axesControllers',axesControllers);
end

if strcmpi(command,'override_mouse')
    parentMouseController = varargin{1};
      set (gcf, 'WindowButtonMotionFcn', {@mouseMove, gcf,parentMouseController});
      set (gcf, 'WindowButtonDownFcn', {@mouseDown, gcf});
      set (gcf, 'WindowButtonUpFcn', {@mouseUp, gcf});
end

if strcmpi(command,'addController')
    axesControllers=getappdata(gcf,'axesControllers');
  
    
    whichAxes = varargin{1};
    corners = varargin{2};
    fig = get(whichAxes,'parent');
    
    if isempty(axesControllers)
        axesControllers = createAxesController(whichAxes,4,corners,1);
    else
        lastID = axesControllers(end).ID;
        axesControllers(end+1) = createAxesController(whichAxes,4,corners,lastID+1);
    end
    setappdata(fig,'axesControllers',axesControllers);
end


function strctController = createAxesController(hAxes,N,corners,ID)
strctController.corners = corners;
strctController.N = N;
strctController.ID = ID;
strctController.hAxes = hAxes;
strctController.handles = [];
strctController.handles = drawAxesController(strctController)    ;                 


function clearControllerHandles(strctController)
try
    delete(strctController.handles.lines);
    delete(strctController.handles.corners);
    delete(strctController.handles.text);
catch
end

function handles = drawAxesController(strctController)    
clearControllerHandles(strctController);

handles.lines = [];
hAxes = strctController.hAxes;
corners = strctController.corners;
if size(corners,1) == 3
    pairs = [1,2;1,3];
    cols = lines(2);
else
    pairs = [1,2];
    cols = [1,0,1];
end

for k=1:size(pairs,1)
    handles.lines(k) = plot(hAxes, [corners(pairs(k,1),1) corners(pairs(k,2),1)], ...
        [corners(pairs(k,1),2) corners(pairs(k,2),2)],'color',cols(k,:));
    set(handles.lines(k),'HitTest','off');    
end
handles.text = [];
% for k=1:3
%     handles.text(k) =text(corners(k,1),corners(k,2),num2str(k), 'parent',hAxes,'HitTest','off','color','m');
% end



% for k=1:size(corners,1)
%     handles.corners(k) = plot(hAxes,corners(k,1),corners(k,2),'go','LineWidth',2);
%     set(handles.corners(k),'ButtonDownFcn', {@mouseclick,strctController.ID,k})
% 
% end

if size(corners,1)==3
    for k=1:size(corners,1)
        handles.corners(k) = plot(hAxes,corners(k,1),corners(k,2),'go','LineWidth',2);
        set(handles.corners(k),'ButtonDownFcn', {@mouseclick,strctController.ID,k})

    end


else  %added by AP
    handles.corners(1) = plot(hAxes,corners(1,1),corners(1,2),'bo','LineWidth',2);
    set(handles.corners(1),'ButtonDownFcn', {@mouseclick,strctController.ID,1})

    for k=2:size(corners,1)
        handles.corners(k) = plot(hAxes,corners(k,1),corners(k,2),'go','LineWidth',2);
        set(handles.corners(k),'ButtonDownFcn', {@mouseclick,strctController.ID,k})

    end
   

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
    
    axesControllers=getappdata(fig,'axesControllers');
    
    axesControllers(id).corners(vertex,:) = newpos;
    axesControllers(id).handles = drawAxesController(axesControllers(id));    
    setappdata(fig,'axesControllers',axesControllers);

end

function mouseDown(fig,b,c)
setappdata(fig,'mouseDown',true);


function mouseUp(fig,b,c)
setappdata(fig,'mouseDown',false);
setappdata(fig,'selectedCorner',[]);
