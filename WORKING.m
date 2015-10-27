%clear
delete(imaqfind)
detect_pen = 0;

%%

% Read the calibration parameters from the workspace
% This should be exported using the calibration app, og loaded from a file
f = cameraParams.FocalLength(1);
cx = cameraParams.PrincipalPoint(1);
cy = cameraParams.PrincipalPoint(2);
r = cameraParams.RotationMatrices(:,:,end);
t = cameraParams.TranslationVectors(end,:);
rot = [[0 1 0];[1 0 0];[0 0 -1]];
% The fancy offset for the error in the y-direction
framePos = [0 -160 0] + [0 0 0];
vidRGB = videoinput('kinectv2imaq', 1, 'RGB32_1920x1080');
vidDepth = videoinput('kinectv2imaq', 2, 'MONO12_512x423');
vidRGB.FramesPerTrigger = 1;
vidRGB.TriggerRepeat = Inf;
triggerconfig(vidRGB, 'manual');
vidDepth.FramesPerTrigger = 1;
vidDepth.TriggerRepeat = Inf;
triggerconfig(vidDepth, 'manual');

start(vidRGB);
start(vidDepth);

trigger(vidRGB);
trigger(vidDepth);
fprintf('Position of Camera: ');
disp((rot*r*(0-t)' + framePos')');
%%
% Get the data for the background subtraction
avg = getdata(vidRGB);
avg = undistortImage(avg,cameraParams);
% Cropping and resizing to fit to depth image frame
avg = imcrop(avg,[284 0 512*3 1080]);
avg = imresize(avg,1/3);
avg = imresize(avg, [361 512]);
avg = flip(avg,2);
avg = int32(rgb2gray(avg));
% Element for dilation and erotion
se = strel('disk',3);
while(1)
    trigger(vidRGB);
    trigger(vidDepth);
    RGB = getdata(vidRGB);

    RGB = undistortImage(RGB,cameraParams);
    depth = getdata(vidDepth);
    % Crop image so they fit in size to each other
    depth = imcrop(depth,[0 77/3 512 1080/3]);
    RGB = imcrop(RGB,[284 0 512*3 1080]);
    RGB = imresize(RGB,1/3);
    imgRaw = imresize(RGB, [361 512]);
    imgRaw = flip(imgRaw,2);
    depth = flip(depth,2);

    img = rgb2hsv(imgRaw);
    newBack = int32(rgb2gray(imgRaw));
    % Create image mask from the color image
    imgBin = img(:,:,1) > 220/360;

    % Do the background subtraction
    back = abs((avg)-(newBack)) > 10;

    %Combine the two masks
    res = imgBin & back;
    res = imerode(res,se);

    st = regionprops(res, 'ConvexHull','Area','Centroid','Solidity','Extrema', 'BoundingBox', 'Eccentricity');
    se = strel('disk',1);
    
    %figure(1)
    %imshow(res);
    %title('Final filter')
    figure(2)
    imshow(res);
    title('Color')
    %foo = figure(3);
    %depth = double(depth)/max(max(depth));
    %imagesc(depth,[0 max(max(depth))]); colormap(gray);
    %imshow(depth);
    %title('Background')
    hf = figure(4);
    key = get(hf,'CurrentCharacter');
    % Press s-key to get the image for motion planning
    if (strcmp(key, 's'))
        break;
    end
    imshow(imgRaw);
    title('Raw image')

    hands = 0;
    xm = 0;
    ym = 0;
    zm = 0;
    i = 0;
    clc;
    for k = 1 : length(st);
        if (st(k).Solidity < 0.8 && st(k).Area > 1000)
            i= i+1;
            XY = st(k).Centroid;
            zm = double(depth(round(XY(2)),round(XY(1))));
            [px, py] = getP(XY(1), XY(2), cx, cy);
            xm = (px/f)*zm;
            ym = (py/f)*zm;
            figure(hf)
            hold on
            rectangle('Position', st(k).BoundingBox );
            plot(XY(1),XY(2),'o');   
            hold off
            hands = hands +1;
            fakePos = [xm, ym, zm];
            realPos = r*(fakePos-t)';
            realPos = rot*realPos + framePos' ;
            fprintf('Position hand(%d): %f, %f, %f)\n', i, realPos(1),realPos(2),realPos(3));
        end
    end
end
close all
% Calculate the PRM for motion planning
path = PRM(back, back);
fprintf('Position hand(%d): %f, %f, %f)\n', i, realPos(1),realPos(2),realPos(3));
hold on
% Plot the position of the waypoints
for i = 1 : length(path)
    zm = double(depth(path(i,1), path(i,2)));
    [px, py] = getP(path(i,1), path(i,2), cx, cy);
    xm = (px/f)*zm;
    ym = (py/f)*zm;  
    fakePos = [xm, ym, zm];
    realPos = r*(fakePos-t)';
    realPos = rot*realPos + framePos' ;
    realPath(i,:) = realPos/1000;
    realPath(i,3) = 0;
    fprintf('Position waypoint(%d): %f, %f, %f)\n', i, realPath(i,1),realPath(i,2),realPath(i,3));
end
% The real path parameter is the position waypoints we use for importing
% into the robot.m file, for the robot to move to.
for i = 2:length(path)
    plot([path(i-1,1) path(i,1)], [path(i-1,2) path(i,2)], 'b');
end
