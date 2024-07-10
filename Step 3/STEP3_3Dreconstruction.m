%% STEP 3: 3D reconstruction
% 3D reconstruction of points correlated from Ncorr using triangulation method
% for running this step, you need to have DIC2DpairResults structures and
% stereo parameters
% The triangulate function does not account for lens distortion. 
% You can undistort the images using the undistortImage function before detecting the points. 
% Alternatively, you can undistort the points themselves using the undistortPoints function.

% Chia-Ying Shen, National Taiwan University (2023/5/04)

%% CHOOSE PATHS OPTIONS
clear;clc;

% select DIC2DpairResults structures
PathInitial=pwd;
structPaths = uipickfiles('FilterSpec',PathInitial,'Prompt','Select one or multiple 2D-DIC results structures');

% [file, Paths] = uigetfile('*.mat','Select one or multiple 2D-DIC results structures',PathInitial);
% structPaths = cell(1,1);
% structPaths{1,1} = [Paths, file];
nPairs = numel(structPaths);
indPairs = zeros(nPairs,2);
DIC2D = cell(nPairs,1);
for ip = 1:nPairs
    DIC2D{ip} = load(structPaths{ip});
    DIC2D{ip} = DIC2D{ip}.DIC2DpairResults;
    indPairs(ip,:) = [DIC2D{ip}.nCamRef DIC2D{ip}.nCamDef];
end
indCams = unique(indPairs(:));
nCams = numel(indCams);

% select the folder where the stereo parameters files are stored

folderPathInitial = structPaths{1,1};

[file, stereoFolder] = uigetfile('*.mat','Select the folder containing stereo parameters for cameras',folderPathInitial);
stereoParameterFolder = cell(1,1);
stereoParameterFolder{1,1} = [stereoFolder, file];

% stereoParameterFolder = uipickfiles('FilterSpec', folderPathInitial, 'Type', {'*.mat'}, 'Prompt','Select the folder containing stereo parameters for cameras');
stereoParams = load(stereoParameterFolder{1,1});



% remove distortion? If yes, choose the folder where the parameters are saved

% distortionRemovalButton = questdlg('Remove distortion?', 'Remove distortion?', 'Yes', 'No', 'Yes');
% switch distortionRemovalButton
%     case 'Yes'
%         distortionRemovalLogic = true(1);
%         distortionParametersPath = uigetdir([],'Select a folder where the cameraCBparameters are located');
%     case 'No'
%         distortionRemovalLogic = false(1);
% end

%% 3D reconstruction using triangulation
DIC3DAllPairsResults = cell(nPairs,1);

for ip = 1:nPairs % loop over stereo pairs
    hw = waitbar(0,['Reconstructing 3D points for pair ' num2str(ip) '...']);
    
    % create 3D-DIc results struct
    DIC3DpairResults = struct;
    
    % camera indices of current pair
    nCamRef = indPairs(ip,1);
    nCamDef = indPairs(ip,2);
    
    iCamRef = find(indCams==nCamRef);
    iCamDef = find(indCams==nCamDef);
    
    DIC3DpairResults.cameraPairInd = [nCamRef nCamDef];
    

    % extract information from 2d-dic results
    nImages = DIC2D{ip}.nImages;
    CorCoeff = DIC2D{ip}.CorCoeffVec;
    F = DIC2D{ip}.Faces;
    FC = DIC2D{ip}.FaceColors;
    DIC3DpairResults.Faces = F;
    DIC3DpairResults.FaceColors = FC;
    Points = DIC2D{ip}.Points;
    
    % pre-allocate 3D-DIC result variables
    DIC3DpairResults.Points3D = cell(nImages,1);
    DIC3DpairResults.Disp.DispVec = cell(nImages,1);
    DIC3DpairResults.Disp.DispMgn = cell(nImages,1);
    DIC3DpairResults.FaceCentroids = cell(nImages,1);
    DIC3DpairResults.corrComb = cell(nImages,1);
    DIC3DpairResults.FaceCorrComb = cell(nImages,1);

    points3D = cell(nImages,1);
    P1 = cell(nImages,1);
    P2 = cell(nImages,1);

    for ii = 1:nImages % loop over images (time frames)
        waitbar(1/3+ii/(3*nImages));
        
        % correlated points from 2 cameras
        P1{ii,1} = Points{ii};
        P2{ii,1} = Points{ii+nImages};

        if any(isnan(P1{ii}(:))) || any(isinf(P1{ii}(:))) || any(isnan(P2{ii}(:))) || any(isinf(P2{ii}(:)))
            warning(['NaN or Inf values found in input for pair ' num2str(ip) ' frame ' num2str(ii)]);

        end
        P1_1 = replaceNaNInf(P1);
        P2_1 = replaceNaNInf(P2);


        % 3d reconstruction by triangulation (3-D locations)
        points3D = triangulate(P1_1{ii}, P2_1{ii}, stereoParams.stereoParams); % (unit: 'mm')
        DIC3DpairResults.Points3D{ii} = points3D;
        
        % Combined (worst) correlation coefficients
        DIC3DpairResults.corrComb{ii} = max([CorCoeff{ii} CorCoeff{ii+nImages}],[],2);
        % Face correlation coefficient (worst)
        DIC3DpairResults.FaceCorrComb{ii} = max(DIC3DpairResults.corrComb{ii}(F),[],2);
        
        % compute face centroids
        for iface = 1:size(F,1)
            DIC3DpairResults.FaceCentroids{ii}(iface,:) = mean(points3D(F(iface,:),:));
        end

        % Compute displacements between frames (per point)
        DispVec = DIC3DpairResults.Points3D{ii}-DIC3DpairResults.Points3D{1};
        DIC3DpairResults.Disp.DispVec{ii} = DispVec;
        DIC3DpairResults.Disp.DispMgn{ii} = sqrt(DispVec(:,1).^2+DispVec(:,2).^2+DispVec(:,3).^2);
        
    end
    
%     put all pairs in a cell array
    DIC3DAllPairsResults{ip} = DIC3DpairResults;
    
     delete(hw) 
end
%% Stitch pairs
if nPairs>1
    % Stitch pairs? If yes, selesct which pairs to stitch and in which order
    stitchButton = questdlg('Stitch surfaces together?', 'Stitch surfaces together?', 'Yes', 'No', 'Yes');
    switch stitchButton
        case 'Yes'
            stitchButton=true(1);
        case 'No'
            stitchButton=false(1);
    end
else
    stitchButton=false(1);
end

if stitchButton
    % stitch or stitch+append
    anim8_DIC3D_reconstructedPairs_faceMeasure(DIC3DAllPairsResults,'pairInd');  %%
    answer = inputdlg({sprintf('Enter the indices of camera-pairs to stitch to each other (in the order they should be stitched):\nSurfaces deleted from the list will not be stitched, but will be included in the results')},'Input',[1,100],{mat2str(1:nPairs)});
    pairIndList=str2num(answer{1});
    [DIC3Dcombined]= DIC3DsurfaceStitch(DIC3DAllPairsResults,pairIndList);
else
    % only append
    [DIC3Dcombined]= DIC3DsurfaceStitch(DIC3DAllPairsResults,[]);
end

% add all information to DIC3Dcombined structure
for ipair=1:nPairs

    % add 2D-DIC data to DIC3Dcombined
    DIC3Dcombined.DIC2Dinfo{ipair}=DIC2D{ipair};
    % add 3D-DIC data to DIC3Dcombined
    DIC3Dcombined.AllPairsResults=DIC3DAllPairsResults;
end
%% show the point3D
anim8_DIC3D_reconstructedPairs_faceMeasure(DIC3Dcombined.AllPairsResults ,'DispMgn')
anim8_DIC3D_reconstructedPairs_faceMeasure(DIC3DAllPairsResults,'FaceColors');  %% DispMgn
anim8_DIC3D_reconstructedPairs_faceMeasure(DIC3Dcombined.AllPairsResults ,'DispZ')
%% save 3D-DIC results? choose save path and overwrite options

[saveCameraParametersLogic,savePath] = Qsave3DDICresults(structPaths);
% save(fullfile(savePath, 'DIC3D_reconstruction'), 'DIC3DAllPairsResults');
save(fullfile(savePath, 'DIC3D_reconstruction'), 'DIC3Dcombined');

