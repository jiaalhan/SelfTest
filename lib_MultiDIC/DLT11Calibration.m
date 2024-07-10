 function L = DLT11Calibration(P2,P3)
%% function for calculating the DLT parameters in step 1

% INPUT:
% P2: a Nx2 array of N 2D image points  ,  N: number of image centroids 
% P3: a Nx3 array of N 3D world points
% The points must be corresponded (the indeces of the points have to match)

% OUTPUT:
% L: an 11x1 array representing the 11 DLT parameters
% These parameters are to be used for stereo calibration of corresponded image points

%%
% DLTstruct = load('C:\Users\Jenny\Dropbox\2023 FootDIC\DICDatabase\CS20230306\CS\calibrationObjectImages\DLTstruct_cam_201.mat');
% P2 = DLTstruct.DLTstructCam.imageCentroids;
% C3Dtrue = DLTstruct.DLTstructCam.C3Dtrue;
% cInds = [12, 13, 14, 15, 16, 17, 18, 19];
% C3Dtemp=C3Dtrue(:,cInds,:);
% Np = 120;
% P3=reshape(C3Dtemp,Np,3);

if size(P2,1)~=size(P3,1)
    error('Number of points in both matrices must match');
end
if size(P2,2)~=2
    error('Size of first input must be Npx2');
end
if size(P3,2)~=3
    error('Size of first input must be Npx3');
end

N=size(P3,1);
% a vector containing both coordiantes of the image points [u1, v1, u2, v2, u3, v3,...]
P2array(1:2:2*N-1,1)=P2(:,1); % u
P2array(2:2:2*N,1)=P2(:,2);   % v

% Matrix for solving DLT calibration parameters (2N x 11)
M(1:2:2*N-1,:)=[P3 ones(N,1) zeros(N,4) -P2(:,1).*P3];
M(2:2:2*N,:)=[zeros(N,4) P3 ones(N,1)  -P2(:,2).*P3];

% L * M = P2array
L = M\P2array; % least square method : The solution for the 11 DLT parameters


end

