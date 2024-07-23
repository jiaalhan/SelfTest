function [] = Phd_UndistortedNonDetectObj(CBimagesInfo,cameraCBparametersAllCams,saveUndistortedImagesLogic,overWriteUDimagesLogic, savePath)
% load('C:\Users\John\Desktop\3D surface validation\Undistorted only need import CameraParameter\cameraCBparametersAllCams.mat') ; 
cameraCBparameters = cameraCBparametersAllCams ;
% Ncam=numel(cameraCBparameters); % number of cameras in this analysis
nonUsed = 1:length(cameraCBparameters.imagesUsedAll) ;
nonUsed = setdiff(nonUsed,cameraCBparameters.imagesUsed) ;
J=zeros([1200 1920 1 length(nonUsed)],'uint8') ;
for ip =1:length(nonUsed)
    %     undistortCGImagesSavePlot(CBimagesInfo,cameraCBparameters{ic,1},saveUndistortedImagesLogic,overWriteUDimagesLogic,savePath)
    [J(:,:,:,ip),~] = undistortImage(CBimagesInfo.I(:,:,:,nonUsed(ip)),cameraCBparameters.cameraParameters,'OutputView','same');
end
if saveUndistortedImagesLogic
    warning('off','MATLAB:MKDIR:DirectoryExists');
    mkdir(fullfile(savePath, 'nonDetectedImages', num2str(CBimagesInfo.icam))) ;
    for ip=1:length(nonUsed)
        [~,name,~]=fileparts(CBimagesInfo.imageFileNames{ip}) ;
        [str, ~] = split(name,"_") ; name1 = str{1,1} ;
        % imageUsed will hide at here, Solved 2024.07.23
        imName=fullfile(savePath, 'nonDetectedImages', num2str(CBimagesInfo.icam), ['J-' num2str(ip,'%03i') '-' name1(1:end-2) num2str(nonUsed(ip),'%02i') CBimagesInfo.imageType]);
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
% plot_reprojectCGreal_points_AUD(CBimagesInfoJ,cameraCBparameters);



