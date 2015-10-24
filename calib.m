delete(imaqfind)
close all
clear
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
%%
i = 0;
imageFileNames = {}
while(i < 15)
    trigger(vidRGB);
    trigger(vidDepth);
    RGB = getdata(vidRGB);
    RGB = flip(RGB,2);
    imshow(RGB);
    filename = sprintf('cali/image_new%d.png', i);
    imwrite(RGB,filename);
    i = i + 1;
    imageFileNames{i} = filename;
    fprintf('Got image %d \n', i);
    pause(5)
end
%% FUCK SLET
%trigger(vidRGB);
%    trigger(vidDepth);
%    RGB = getdata(vidRGB);
%    RGB = flip(RGB,2);
%    imshow(RGB);
%    filename = sprintf('cali/image_new%d.png', i);
%    imwrite(RGB,filename);
%    i = i + 1;
%    imageFileNames{i} = filename;
%    fprintf('Got image %d \n', i);
%%
% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
imageFileNames = imageFileNames(imagesUsed);

% Generate world coordinates of the corners of the squares
squareSize = 30;  % in units of 'mm'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera
[cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'mm');

% View reprojection errors
h1=figure; showReprojectionErrors(cameraParams, 'BarGraph');

% Visualize pattern locations
h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

% Display parameter estimation errors
displayErrors(estimationErrors, cameraParams);

% For example, you can use the calibration data to remove effects of lens distortion.
originalImage = imread(imageFileNames{1});
undistortedImage = undistortImage(originalImage, cameraParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('SparseReconstructionExample')

