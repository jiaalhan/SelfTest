function [cameraCBparameters] = calculateCBcalibrationParameters(CBimagesInfo,squareSize,varargin)
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
    optStruct.NumRadialDistortionCoefficients=3;
end
if ~isfield(optStruct, 'EstimateTangentialDistortion')
    optStruct.EstimateTangentialDistortion=true;
end
if ~isfield(optStruct, 'EstimateSkew')
    optStruct.EstimateSkew=true;
end
%%
% Detect the checkerboard points
% [imagePoints, boardSize, imagesUsedCB] = detectCheckerboardPoints(CBimagesInfo.I,PartialDetections=false);

% John - 2023/11/23  [sigma = 1.5]
% Use lower standard deviation to reduce smoothing in high distortion
% images to prevent loss of features at the edges of Field-Of-View.
[imagePoints, boardSize, imagesUsedCB] = detectCheckerboardPoints(CBimagesInfo.I, PartialDetections=false); 

%  detectCircleGridPoints(CBimagesInfo.I, PartialDetections=false)
%%
% generate the real checkerboard points from the known square size and board size 
worldPoints = generateCheckerboardPoints(boardSize,squareSize); 

% calculate camera parameters
[params,imagesUsedECP,estimationErrors] = estimateCameraParameters(imagePoints,worldPoints,...
    'NumRadialDistortionCoefficients',optStruct.NumRadialDistortionCoefficients,'EstimateTangentialDistortion',optStruct.EstimateTangentialDistortion,'EstimateSkew',optStruct.EstimateSkew);

% John - 2023/11/23
% [params,imagesUsedECP,estimationErrors] = estimateFisheyeParameters(imagePoints, worldPoints,CBimagesInfo.imageSize);

% 'NumRadialDistortionCoefficients',optStruct.NumRadialDistortionCoefficients,'EstimateTangentialDistortion',optStruct.EstimateTangentialDistortion,'EstimateSkew',optStruct.EstimateSkew
imagesUsedFinal=find(imagesUsedCB)';
imagesUsedFinal(find(~imagesUsedECP))=[];

%% stereo calibration

% create cameraCBparameters structure
cameraCBparameters=struct;
% feed results
cameraCBparameters.icam=CBimagesInfo.icam;
cameraCBparameters.cameraParameters=params;
cameraCBparameters.imagesUsed=imagesUsedFinal;
cameraCBparameters.estimationErrors=estimationErrors;
cameraCBparameters.boardSize=boardSize;
cameraCBparameters.squareSize=squareSize;
cameraCBparameters.imagePoints=imagePoints;


imagesInfo=rmfield(CBimagesInfo,'I');
cameraCBparameters.imagesInfo=imagesInfo;

% parameters after undistortion
imagePointsUndistorted=zeros(size(cameraCBparameters.imagePoints));
for ii=1:size(cameraCBparameters.imagePoints,3)
    imagePointNow=cameraCBparameters.imagePoints(:,:,ii);
    [imagePointsUndistorted(:,:,ii)] = undistortPoints(imagePointNow,cameraCBparameters.cameraParameters);
end

[paramsJ,~,estimationErrorsJ] = estimateCameraParameters(imagePointsUndistorted,worldPoints,...
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
