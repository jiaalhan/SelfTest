function []=undistortCGImagesSavePlot(CBimagesInfo,cameraCBparameters,saveUndistortedImagesLogic,overWriteUDimagesLogic,savePath)
%% function for undistorting images and save them if required, in STEP0
%
% INPUTS:
% * CBimagesInfo
% * cameraCBparameters:  a structure containing all the calibration parameters created in STEP0
% * saveUndistortedImagesLogic: save (true) or not (false)
% * overWriteUDimagesLogic: overwrite existing undistorted images (true) or not (false)
% * savePath: path for saving the undistorted images

%%
% undistort images and save if required
index = 1:size(cameraCBparameters.imagePoints,3);
r= [];
for i = 1:length(cameraCBparameters.imagesUsed)
    if any(index(i) == cameraCBparameters.imagesUsed) ==false
        r = [r i];
    end
end
CBimagesInfo.I(:,:,:,r)=[];
% CBimagesInfoJ.I =CBimagesInfo.I;
J=zeros(size(CBimagesInfo.I),'uint8');
for ip=1:length(cameraCBparameters.imagesUsed)
    [J(:,:,:,ip),~] = undistortImage(CBimagesInfo.I(:,:,:,ip),cameraCBparameters.cameraParameters,'OutputView','same');
    % John - 2023/11/28
%     [J(:,:,:,ip), ~] = undistortFisheyeImage(CBimagesInfo.I(:,:,:,ip), cameraCBparameters.cameraParameters.Intrinsics);

end
if saveUndistortedImagesLogic
    warning('off','MATLAB:MKDIR:DirectoryExists');
    mkdir(fullfile(savePath, 'undistortedImages', num2str(CBimagesInfo.icam)));
    for ip=1:length(cameraCBparameters.imagesUsed)
        [~,name,~]=fileparts(CBimagesInfo.imageFileNames{ip});
        % save undistorted image as J_001_originalNAme.ext
        imName=fullfile(savePath, 'undistortedImages', num2str(CBimagesInfo.icam), ['J_' num2str(ip,'%03i') '_' name CBimagesInfo.imageType]);
        % warn about overwriting if already exists
        if exist(imName,'file')
            if overWriteUDimagesLogic
                if strcmp(CBimagesInfo.imageType,'.png')
                    imwrite(J(:,:,:,ip),imName,'Compression','none');  
                elseif strcmp(CBimagesInfo.imageType,'.tif')  %%%% if image type = tif ,true(1), write undistortion image of tif
                    imwrite(J(:,:,:,ip),imName,'Compression','none');  %%%%
                elseif strcmp(CBimagesInfo.imageType,'.jpg')  %%%% if image type = jpg ,true(1), write undistortion image of jpg
                    imwrite(J(:,:,:,ip),imName,'Quality',100);  %%%%
                else
                    imwrite(J(:,:,:,ip),imName,'Quality',100);
                end
            else
                waitfor(warndlg({'Undistorted image'; name ;' already exist so it will not be overwritten'}));
            end
        else
                if strcmp(CBimagesInfo.imageType,'.png')
                    imwrite(J(:,:,:,ip),imName,'Compression','none');
                elseif strcmp(CBimagesInfo.imageType,'.tif')  %%%% if image type = tif ,true(1), write undistortion image of tif
                    imwrite(J(:,:,:,ip),imName,'Compression','none');  %%%% 
                elseif strcmp(CBimagesInfo.imageType,'.jpg')  %%%% if image type = jpg ,true(1), write undistortion image of jpg
                    imwrite(J(:,:,:,ip),imName,'Quality',100);  %%%%
                else
                    imwrite(J(:,:,:,ip),imName,'Quality',100);
                end
        end
    end
end
CBimagesInfoJ.I=J;

% plot all undistorted images with reprojected points after correction
plot_reprojectCGreal_points_AUD(CBimagesInfoJ,cameraCBparameters);

end
 
%% 
% MultiDIC: a MATLAB Toolbox for Multi-View 3D Digital Image Correlation
% 
% License: <https://github.com/MultiDIC/MultiDIC/blob/master/LICENSE.txt>
% 
% Copyright (C) 2018  Dana Solav
% 
% If you use the toolbox/function for your research, please cite our paper:
% <https://engrxiv.org/fv47e>
