function [cameraCBparameters,worldPoints] = Phd_getCGParameters(CBimagesInfo,circleSpacing,patternDims, imageSize, varargin)
%% function for calculating the distortion parameters in STEP0.
% This function is called only in case the user selected a repeated
% analysis.
%
% INPUTS:
% * CBimagesInfo: structure previously created in STEP0
% * squareSize: scalar, in meters.
% * optStruct (optional input): a structure containing the distortion model. If not given, the default (full) model is used
%
% OUTPUTS:
% * cameraCBparameters: a structure containing all the calibration parameters, with the following fields:
% - icam
% - cameraParameters
% - imagesUsed
% - estimationErrors
% - boardSize
% - squareSize
% - imagePoints
% - imagesInfo
% - cameraParametersAUD
% - estimationErrorsAUD
% - imagePointsAUD
% -------------------------------------------------------------------------------
% Chia-Han Hu | National Taiwan University | 20240423
% -------------------------------------------------------------------------------
%%
Narg=numel(varargin);
switch Narg
    case 0
        optStruct=struct;
    case 1
        optStruct=varargin{1};
    otherwise
        error('wrong number of input arguments');
end

% fill in missing fields
if ~isfield(optStruct, 'NumRadialDistortionCoefficients')
    optStruct.NumRadialDistortionCoefficients=2;
end
if ~isfield(optStruct, 'EstimateTangentialDistortion')
    optStruct.EstimateTangentialDistortion=true;
end
if ~isfield(optStruct, 'EstimateSkew')
    optStruct.EstimateSkew=true;
end
%%
worldPoints = generateCircleGridPoints(patternDims,circleSpacing,'PatternType','symmetric');
[imagePoints, imagesUsedCB, imgNoUsed] = Phd_getCGPoints_version3(CBimagesInfo);   %%
% imagesUsedCB包含0
% calculate camera parameters
% Expected size(imagePoints, 3) >= 2.
% imagePoints = imagePoints(:,:,imagesUsedCB);
% imagePoints(:,:,2) = []
[params,imagesUsedECP,estimationErrors] = estimateCameraParameters(imagePoints,worldPoints,'imageSize',imageSize,...
    'NumRadialDistortionCoefficients',optStruct.NumRadialDistortionCoefficients,'EstimateTangentialDistortion',optStruct.EstimateTangentialDistortion,'EstimateSkew',optStruct.EstimateSkew);
imagesUsedFinal=find(imagesUsedCB)';
imagesUsedFinal = imagesUsedFinal';
imagesUsedFinal(find(~imagesUsedECP))=[];

%     for j = 1:size(imagePoints, 1)
%         text(imagePoints(:,j,1), imagePoints(j,2), sprintf('%d', j), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
%             'FontSize', 15, 'Color', 'k');
%     end
%% stereo calibration

% create cameraCBparameters structure
cameraCBparameters=struct;
% feed results
cameraCBparameters.icam=CBimagesInfo.icam;
cameraCBparameters.cameraParameters=params;
cameraCBparameters.imagesUsed=imagesUsedFinal;
cameraCBparameters.imagesUsedAll = imagesUsedCB;
cameraCBparameters.estimationErrors=estimationErrors;
cameraCBparameters.patternDims=patternDims;   % 2024/2/20 John 
cameraCBparameters.circleSpacing=circleSpacing;
cameraCBparameters.imagePoints=imagePoints;


imagesInfo=rmfield(CBimagesInfo,'I');
cameraCBparameters.imagesInfo=imagesInfo;

% parameters after undistortion
imagePointsUndistorted=zeros(size(cameraCBparameters.imagePoints));
for ii=1:size(cameraCBparameters.imagePoints,3)
    imagePointNow=cameraCBparameters.imagePoints(:,:,ii);
    [imagePointsUndistorted(:,:,ii)] = undistortPoints(imagePointNow,cameraCBparameters.cameraParameters);
end

[paramsJ,~,estimationErrorsJ] = estimateCameraParameters(imagePointsUndistorted,worldPoints,'imageSize',imageSize,...
    'NumRadialDistortionCoefficients',optStruct.NumRadialDistortionCoefficients,'EstimateTangentialDistortion',optStruct.EstimateTangentialDistortion,'EstimateSkew',optStruct.EstimateSkew);
% John - 2023/11/24 
% imagePointsUndistorted=zeros(size(cameraCBparameters.imagePoints));
% camIntrinsics = cell(size(cameraCBparameters.imagePoints,3),1);
% for ii=1:size(cameraCBparameters.imagePoints,3)
%     imagePointNow=cameraCBparameters.imagePoints(:,:,ii);
%     [imagePointsUndistorted(:,:,ii),camIntrinsics{ii}] = undistortFisheyePoints(imagePointNow, cameraCBparameters.cameraParameters.Intrinsics); 
% end
% [paramsJ,~,estimationErrorsJ]= estimateFisheyeParameters(imagePointsUndistorted, worldPoints,CBimagesInfo.imageSize); 

% feed results after undistortion
cameraCBparameters.cameraParametersAUD=paramsJ;
cameraCBparameters.estimationErrorsAUD=estimationErrorsJ;
cameraCBparameters.imagePointsAUD=imagePointsUndistorted;



end
