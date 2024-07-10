%% Step 0 - Camera Calibration 
% -------------------------------------------------------------------------------
% Chia-Han Hu | National Taiwan University | 20240423
% -------------------------------------------------------------------------------
clc; clear; close all
initialPath=uigetdir; 
folder_paths = uipickfiles('FilterSpec',initialPath,'Prompt','Select cameraCBparameters files');
[saveCameraParametersLogic,savePath]=QsaveCameraParameters(folder_paths);
[saveUndistortedImagesLogic,overWriteUDimagesLogic]=QsaveUndistortedImages;

figuresPath=fullfile(savePath, 'figures');
mkdir(figuresPath);
Nrows=9; % Number of black rows (should be uneven) 15
Ncols=12; % Number of black columns (should be even) 20
circleSpacing= 9; %[mm]
% dialog box
answer = inputdlg({'Enter number of rows (odd):','Enter number of columns (even):','Enter square size [mm]:'},'Input',[1,50],{num2str(Nrows),num2str(Ncols),num2str(circleSpacing)});
% extract answers
Nrows=str2double(answer{1});
Ncols=str2double(answer{2});
circleSpacing=str2double(answer{3});
answer = inputdlg({'Enter number of radial distortion coefficients (2 or 3):',...
    'Estimate tangential distortion? (1 or 0 for yes/no):',...
    'Estimate skew? (1 or 0 for yes/no)'},...
    'Input',[1,70],{'2','0','1'});
optStruct=struct;
optStruct.NumRadialDistortionCoefficients=str2double(answer{1});
optStruct.EstimateTangentialDistortion=logical(str2double(answer{2}));
optStruct.EstimateSkew=logical(str2double(answer{3}));

Ncam=numel(folder_paths); % number of cameras in this analysis
cameraCBparametersAllCams=cell(Ncam,1); % assign cell array for all camera parmaters
for ic=1:Ncam
    % if New, extract only image info
    CBimagesInfo=extractImagesInfo(folder_paths{ic});
    % plot all images in one figure
    plotAllCameraImages(CBimagesInfo);
    % Extract images, Detect the checkerboard points, calculate camera parameters, and save a structure containing all necessary parameters
    set(0, 'DefaultUIControlFontSize', 11);
    % Detect circlegrid board circle points
    % close all
    [cameraCBparameters,worldPoints]=Phd_getCGParameters(CBimagesInfo,circleSpacing, [Nrows, Ncols], CBimagesInfo.imageSize, optStruct);  %% close all
    % check if detected boardsize matches entered values
    if (cameraCBparameters.patternDims(1)~=Nrows) || (cameraCBparameters.patternDims(2)~=Ncols)
        error('Detected number of columns or rows does not match entered values');
    end
    % plot camera parameters and reorojection errors before and after distortion correction
    plot_camera_parameters_2tabs(cameraCBparameters);
    if saveCameraParametersLogic
        savefig(fullfile(figuresPath,[ 'params_cam' num2str(CBimagesInfo.icam)]));
    end
    plot_reprojectCGreal_points(CBimagesInfo,cameraCBparameters);
    undistortCGImagesSavePlot(CBimagesInfo,cameraCBparameters,saveUndistortedImagesLogic,overWriteUDimagesLogic,savePath)
    % save camera parameters into the cell array of all cameras
    cameraCBparametersAllCams{ic}=cameraCBparameters;
    % save parameters into savePath
    if saveCameraParametersLogic
        save(fullfile(savePath, ['cameraCBparameters_cam_', num2str(cameraCBparameters.icam)]),'cameraCBparameters');
    end
end
 % save cell array containing the camera parameters for all cameras in this analysis
 if saveCameraParametersLogic
     save(fullfile(savePath, 'cameraCBparametersAllCams'),'cameraCBparametersAllCams');
 end
 imagesize = CBimagesInfo.imageSize;
 %% Dual Camera (right now...)
 [stereoParams, ~, ~] = Phd_getcalibrateTwoCameras(cameraCBparametersAllCams,CBimagesInfo.imageSize);
% CBimagesInfo.imageSize = [1200 1920]
 %  save stereoParams in this analysis
 if saveCameraParametersLogic
     save(fullfile(savePath, 'stereoParams'),'stereoParams');
 end
%%
% View reprojection errors
h1 = figure; showReprojectionErrors(stereoParams);

% Visualize pattern locations
h2 = figure; showExtrinsics(stereoParams, 'CameraCentric');

% Display parameter estimation errors
% displayErrors(estimationErrors, stereoParams);

% You can use the calibration data to rectify stereo images.
% imageFileNames1=extractImagesInfo(folder_paths{1,1}).imageFileNames;
% imageFileNames2=extractImagesInfo(folder_paths{1,2}).imageFileNames;
% I1 = imread(imageFileNames1{1});
% I2 = imread(imageFileNames2{1});
% % I1 = imread(CBimagesInfo.imageFileNames(:,:,:,cameraCBparametersAllCams{1,1}.imagesUsedAll));
% % I2 = imread(CBimagesInfo.imageFileNames(:,:,:,cameraCBparametersAllCams{2,1}.imagesUsedAll));
% [J1, J2, reprojectionMatrix] = rectifyStereoImages(I1, I2, stereoParams,'OutputView','Full');  %% check POint
% 
% % figure;imshow(CBimagesInfo.I(:,:,:,1));
% J1 = undistortImage(CBimagesInfo.I(:,:,:,1),cameraCBparametersAllCams{1, 1}.cameraParametersAUD  ,'OutputView','valid');