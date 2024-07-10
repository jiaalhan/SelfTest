function []=anim8_DIC_3D_stitchedSurface_faceMeasure(DIC3DStitched,faceMeasureString,varargin)
%% function for plotting 3D-DIC results of face measures in STEP3.
% plotting 3D surfaces from camera pairs, animation changing
% with time, and the faces colored according to faceMeasureString
% this function is called in plotMultiDICPairResults
%
% Options:
% anim8_DIC_3D_pairs_faceMeasure(DIC3DAllPairsResults,faceMeasureString)
% anim8_DIC_3D_pairs_faceMeasure(DIC3DAllPairsResults,faceMeasureString,optStruct)
%
% Inputs:
% * DIC3DAllPairsResults
% * faceMeasureString: can be any of the following:
%   'J','Emgn','emgn','Epc1','Epc2','epc1','epc2','dispMgn','dispX','dispY','dispZ','FaceColors','FaceIsoInd','pairInd','Lamda1','Lamda2'
% * optStruct: optional structure for plotting options which may include any of the following fields:
%   - smoothLogic: logical variable for smoothing (true)/not smoothing (false) the face measure
%   - FaceAlpha: transparacy of the faces (scalar between 0 and 1, where zero is transparent and 1 is opaque)
%   - colorBarLimits: a 2x1 scalar vector for the colobar limits. if not set, it's automatic
%   - dataLimits: a 2x1 scalar vector for the data limits of the face measure. if a face measure is outside these limits, it is set to NaN. if not set no face is set to NaN
%   - colorMap
%   - zDirection: 1 for z up and -1 for z down
%   - lineColor: line color for the mesh. can be for example 'b','k','none',etc...
%   - TitleString=faceMeasureString;

%% Assign plot options
Narg=numel(varargin);
switch Narg
    case 1
        optStruct=varargin{1};
    case 0
        optStruct=struct;
    otherwise
        ('wrong number of input arguments');
end

% complete the struct fields
if ~isfield(optStruct,'smoothLogic')
    optStruct.smoothLogic=0;
end
if ~isfield(optStruct,'dataLimits')
    optStruct.dataLimits=[-inf inf];
end
if ~isfield(optStruct,'zDirection') % 1 or -1
    optStruct.zDirection=1;
end
if ~isfield(optStruct,'lineColor') % 'none' or 'k'
    optStruct.lineColor='none';
end
if ~isfield(optStruct,'TitleString')
    optStruct.TitleString=faceMeasureString;
end
if ~isfield(optStruct,'maxCorrCoeff')
    optStruct.maxCorrCoeff=[];
end

%%
nFrames=numel(DIC3DStitched.Points3D);

%% Assign the right face measure into FC
FC=cell(nFrames,1);
switch faceMeasureString
    
    case {'FaceColors'}
        for it=1:nFrames
            FC{it}=DIC3DStitched.(faceMeasureString);
            if ~isempty(optStruct.maxCorrCoeff)
                %                     corrNow=DIC3DStitched.FaceCorrComb{it};
                %                     FC{it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
            end
        end
        if ~isfield(optStruct,'colorBarLimits')
            optStruct.colorBarLimits=[0 255];
        end
        colorBarLogic=1;
        if ~isfield(optStruct,'colorMap')
            optStruct.colorMap='gray';
        end
        if ~isfield(optStruct,'FaceAlpha')
            optStruct.FaceAlpha=1;
        end
    case 'FacePairInds'
        for it=1:nFrames
            FC{it}=DIC3DStitched.FacePairInds;
            if ~isempty(optStruct.maxCorrCoeff)
                %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
                %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
            end
        end
        if ~isfield(optStruct,'colorBarLimits')
            optStruct.colorBarLimits=[1 max(DIC3DStitched.FacePairInds)];
        end
        colorBarLogic=0;
        if ~isfield(optStruct,'colorMap')
            optStruct.colorMap='gjet';
        end
        if ~isfield(optStruct,'FaceAlpha')
            optStruct.FaceAlpha=0.8;
        end
        
        
        %     case {'J','Lamda1','Lamda2'}
        %             for it=1:nFrames
        %                 FC{it}=DIC3DStitched.Deform.(faceMeasureString){it};
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DStitched.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[1-prctile(abs(FCmat(:)-1),100) 1+prctile(abs(FCmat(:)-1),100)];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap=0.8*coldwarm;
        %         end
        %         if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=1;
        %         end
        %         legendLogic=0;
        %
        %     case {'Emgn','emgn'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 FC{ip,it}=DIC3DAllPairsResults{ip}.Deform.(faceMeasureString){it};
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[0 prctile(FCmat(:),100)];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'Epc1','Epc2','epc1','epc2'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 FC{ip,it}=DIC3DAllPairsResults{ip}.Deform.(faceMeasureString){it};
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[-prctile(abs(FCmat(:)),100) prctile(abs(FCmat(:)),100)];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap=0.8*coldwarm;
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'DispMgn'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 Fnow=DIC3DAllPairsResults{ip}.Faces;
        %                 dispNow=DIC3DAllPairsResults{ip}.Disp.(faceMeasureString){it}; % point measure
        %                 FC{ip,it}=mean(dispNow(Fnow),2); % turn into face measure
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[0 prctile(FCmat(:),100)];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'DispX'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 Fnow=DIC3DAllPairsResults{ip}.Faces;
        %                 dispNow=DIC3DAllPairsResults{ip}.Disp.DispVec{it}(:,1); % point measure
        %                 FC{ip,it}=mean(dispNow(Fnow),2); % turn into face measure
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[min(FCmat(:)) max(FCmat(:))];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'DispY'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 Fnow=DIC3DAllPairsResults{ip}.Faces;
        %                 dispNow=DIC3DAllPairsResults{ip}.Disp.DispVec{it}(:,2); % point measure
        %                 FC{ip,it}=mean(dispNow(Fnow),2); % turn into face measure
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[min(FCmat(:)) max(FCmat(:))];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'DispZ'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 Fnow=DIC3DAllPairsResults{ip}.Faces;
        %                 dispNow=DIC3DAllPairsResults{ip}.Disp.DispVec{it}(:,3); % point measure
        %                 FC{ip,it}=mean(dispNow(Fnow),2); % turn into face measure
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[min(FCmat(:)) max(FCmat(:))];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'FaceIsoInd'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 FC{ip,it}=DIC3DAllPairsResults{ip}.(faceMeasureString){it};
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[0 1];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        %
        %     case {'FaceCorrComb'}
        %         for ip=1:nPairs
        %             for it=1:nFrames
        %                 FC{ip,it}=DIC3DAllPairsResults{ip}.(faceMeasureString){it};
        %                 if ~isempty(optStruct.maxCorrCoeff)
        %                     corrNow=DIC3DAllPairsResults{ip}.FaceCorrComb{it};
        %                     FC{ip,it}(corrNow>optStruct.maxCorrCoeff,:)=NaN;
        %                 end
        %             end
        %         end
        %         FCmat = cell2mat(FC);
        %         if ~isfield(optStruct,'colorBarLimits')
        %             optStruct.colorBarLimits=[0 prctile(FCmat(:),100)];
        %         end
        %         colorBarLogic=1;
        %         if ~isfield(optStruct,'colorMap')
        %             optStruct.colorMap='parula';
        %         end
        %                 if ~isfield(optStruct,'FaceAlpha')
        %             optStruct.FaceAlpha=0.8;
        %         end
        %         legendLogic=0;
        
        
    otherwise
        error('unexpected face measure string. plots not created');
        
end


%% Plot
[xl,yl,zl]=axesLimits(DIC3DStitched.Points3D);

animStruct=struct;

hf=cFigure;
hf.Units='normalized'; hf.OuterPosition=[.05 .05 .9 .9]; hf.Units='pixels';

axisGeom;
ax=gca;
ax.CameraUpVector=[0 0 optStruct.zDirection];

colormap(optStruct.colorMap);
if colorBarLogic
    cbh=colorbar;
    caxis(optStruct.colorBarLimits);
end

gtitle(optStruct.supTitleString,20);
% axis off
% camlight headlight

it=1;
Fnow=DIC3DStitched.Faces;
Pnow=DIC3DStitched.Points3D{it};
CFnow=FC{it};
if optStruct.smoothLogic
    [CFnow]=triSmoothFaceMeasure(CFnow,Fnow,Pnow,[],[]);
end
CFnow(CFnow<optStruct.dataLimits(1))=NaN;
CFnow(CFnow>optStruct.dataLimits(2))=NaN;
hp=gpatch(Fnow,Pnow,CFnow,optStruct.lineColor,optStruct.FaceAlpha); hold on


h_ax=gca;
h_ax.XLim = xl; h_ax.YLim = yl; h_ax.ZLim = zl;

animStruct.Time=1:nFrames;
animStruct.Handles=cell(1,nFrames);
animStruct.Props=cell(1,nFrames);
animStruct.Set=cell(1,nFrames);


for it=1:nFrames
    animStruct.Handles{it}=[];
    animStruct.Props{it}=cell(1,2);
    animStruct.Set{it}=cell(1,2);
    
    Fnow=DIC3DStitched.Faces;
    Pnow=DIC3DStitched.Points3D{it};
    CFnow=FC{it};
    if optStruct.smoothLogic
        [CFnow]=triSmoothFaceMeasure(CFnow,Fnow,Pnow,[],[]);
    end
    CFnow(CFnow<optStruct.dataLimits(1))=NaN;
    CFnow(CFnow>optStruct.dataLimits(2))=NaN;
    animStruct.Handles{it}=[animStruct.Handles{it} hp hp]; %Handles of objects to animate
    animStruct.Props{it}{1}='CData';
    animStruct.Props{it}{2}='Vertices'; %Properties of objects to animate
    animStruct.Set{it}{1}=CFnow;
    animStruct.Set{it}{2}=Pnow; %Property values for to set in order to animate
    
    h_ax.XLim = xl; h_ax.YLim = yl; h_ax.ZLim = zl;
    
end
anim8(hf,animStruct);


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