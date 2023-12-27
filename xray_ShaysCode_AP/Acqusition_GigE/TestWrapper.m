cd('C:\Users\shayo\Dropbox (MIT)\Code\Github\RadEyeMatlabWrapper');
h=RadEyeWrapper('Init')
if h ~= 1
    fprintf('Error initializing camera\n');
    return;
end

% Single image grabbing
exposureTimeMS = 990;
overheadMS = 300; % might be faster on fast computers...
RadEyeWrapper('GrabSingleFrame',exposureTimeMS); % non-blocking
tic, while toc < (exposureTimeMS+overheadMS)/1000, end
RadEyeWrapper('GetBufferSize') % should return 1
I=RadEyeWrapper('GetImageBuffer');

% Continuous acqusition
% Note that exposure time is actually fixed
fps = 1;
RadEyeWrapper('StartContinuous', fps);

while (1)
I=RadEyeWrapper('GetImageBuffer');
if ~isempty(I)
    fprintf('%s Last Image Timestamp: %d, Num Images In Buffer: %d\n',datestr(now),RadEyeWrapper('getNumTrigs'),RadEyeWrapper('GetBufferSize'));

    figure(11);
    clf;
    imagesc(I(:,:,end));
    drawnow
end
end

for k=1:10
    tic, while toc < 0.5, end
end
RadEyeWrapper('StopContinuous');

clear mex

figure(11);
clf;
imagesc(mean(I,3))
%%
IRaw = RadEyeWrapper('GetImageBuffer');
save('IRaw','IRaw')
for k=1:15
    imagesc(IRaw(:,:,k))
    drawnow
end


%% External triggertin - still doesn't work
RadEyeWrapper('SetExternalTrigger');

clear mex