function [stereoParams, pairsUsed1, pairsUsed2] = Phd_getcalibrateTwoCameras(AllCams, imagesize)
%---------------------------------------------------------------------------------------------------
% Compute the initial estimate of translation and rotation of camera 2
% [cameraParams, imagesUsed, estimationErrors] = calibrateTwoCameras(imagePoints,...
%         worldPoints, imageSize, cameraModel, worldUnits, calibrationParams);
% Show Camera Relative position
% Chia-Han Hu | NTU | 2024.04.24
%---------------------------------------------------------------------------------------------------
% imagesize = [1200 1920];
Cam1 = AllCams{1,1}; Cam2 = AllCams{2,1};
imagePoints1 = Cam1.imagePoints;
imagePoints2 = Cam2.imagePoints;
%%
index = 1:size(imagePoints1,3);
common_elements = intersect(Cam1.imagesUsed, Cam2.imagesUsed);
match_result1 = false(size(Cam1.imagesUsed));
match_result2 = false(size(Cam2.imagesUsed));
for i = 1:length(Cam1.imagesUsed)
    if any(Cam1.imagesUsed(i) == common_elements)
        match_result1(i) = true;  % pairUsed1
    end
end
for i = 1:length(Cam2.imagesUsed)
    if any(Cam2.imagesUsed(i) == common_elements)
        match_result2(i) = true;    % pairUsed2
    end
end
r1= []; r2 =[];
for i = 1:length(Cam1.imagesUsed)
    if any(index(i) == common_elements) ==false
        r1 = [r1 i];
    end
end
for i = 1:length(Cam2.imagesUsed)
    if any(index(i) == common_elements) ==false
        r2 = [r2 i];
    end
end
pairsUsed1 = Cam1.imagesUsed(match_result1);
pairsUsed2 = Cam2.imagesUsed(match_result2);
% logicalIndex1 = ismember(Cam1.imagesUsed, common_elements);
% logicalIndex2 = ismember(Cam2.imagesUsed, common_elements);

imagePoints1(:,:,r1)=[]; imagePoints2(:,:,r2)=[];
k1 = imagePoints1;
k2 = imagePoints2;
% k1 = imagePoints1(:,:,logicalIndex1);
% k2 = imagePoints2(:,:,logicalIndex2);
imgPts_1(:,:,:,1) = k1; imgPts_1(:,:,:,2) = k2;
WP =  Cam1.cameraParametersAUD.WorldPoints;

Cam1.cameraParametersAUD.ImageSize = imagesize;
Cam2.cameraParametersAUD.ImageSize = imagesize;
[stereoParams]  = estimateStereoBaseline(imgPts_1,WP,Cam1.cameraParametersAUD.Intrinsics,Cam2.cameraParametersAUD.Intrinsics);
figure; showExtrinsics(stereoParams)
end
%%
% % Compute the initial estimate of translation and rotation of camera 2
% [R, t] = vision.internal.calibration.estimateInitialTranslationAndRotation(...
%     Cam1.cameraParametersAUD, Cam2.cameraParametersAUD);
% 
% tform = rigidtform3d(R, t);
% save
% 
% stereoParams = stereoParameters(cameraParameters1, cameraParameters2, tform);
% 
% errors = refine(stereoParams, imagePoints1(:, :, pairsUsed1), ...
%     imagePoints2(:, :, pairsUsed2), shouldComputeErrors);
% 
% progressBar.update();
% delete(progressBar);


% Calibrate each camera separately
% shouldComputeErrors = calibrationParams.shouldComputeErrors;
% calibrationParams.shouldComputeErrors = false;
% [cameraParameters1, imagesUsed1] = calibrateOneCamera(imagePoints1, ...
%     worldPoints, imageSize, cameraModel, worldUnits, calibrationParams);

% progressBar.update();
% 
% [cameraParameters2, imagesUsed2] = calibrateOneCamera(imagePoints2, ...
%     worldPoints, imageSize, cameraModel, worldUnits, calibrationParams);
% 
% progressBar.update();

% Account for possible mismatched pairs
% pairsUsed = imagesUsed1 & imagesUsed2;
% cameraParameters1 = vision.internal.calibration.removeUnusedExtrinsics(...
%     cameraParameters1, pairsUsed, imagesUsed1);
% cameraParameters2 = vision.internal.calibration.removeUnusedExtrinsics(...
%     cameraParameters2, pairsUsed, imagesUsed2);


