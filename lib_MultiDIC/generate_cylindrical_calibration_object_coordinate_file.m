% generate a 3d coordinate file for a cylindrical calibration object

prompt = {'Cylinder diameter [mm]','Number of rows:','Number of clumns:','Distance between rows [mm]:','Distance between columns [mm]:'};
title = 'Input calibration object parameters';
dims = [1 35];
% definput = {'20','hsv'};
answer = inputdlg(prompt,title);

D=str2num(answer{1});
Nr=str2num(answer{2});
Nc=str2num(answer{3});
dr=str2num(answer{4});
dc=str2num(answer{5});

% total number of point
Np=Nr*Nc;
% angle between columns
angInc=2*dc/D;

P3d=zeros(Nr,Nc,3);
for ir=1:Nr
    z=dr*(ir-1);
    for ic=1:Nc
        ang=angInc*(ic-1);
        x=.5*D*cos(ang);
        y=.5*D*sin(ang);
        P3d(ir,ic,:)=[x y z];

    end
end

P3dVec=reshape(P3d,Np,3);
%plot
cFigure; hold all; axisGeom;
plotV(P3dVec,'sb','MarkerFaceColor','b');

save file
uisave('P3d','myCylinderCoordinates');

%% print object pattern

Nr = 15 ;
Nc = 23 ; 
dr = 5; % unit: mm
dc = 8; % unit: mm

% rectangle
for j = 1:15
    for i = 1:23
         rectangle('Position',[80*i 65*j 28 28],'FaceColor', 'k');
         axis equal;
%          axis([0 1000 0 1000]);
         ax.Units = 'centimeters';
    end
end

% set(gcf,'PaperUnits','centimeters'); 
set(gcf,'PaperSize',[21 29.7]); 
set(gca,'visible','off');
fig = gcf; 
set(gcf,'color','w');
exportgraphics(fig,'figure.pdf','BackgroundColor','none');

% fig = gcf; 
% fig.PaperUnits = 'centimeters';  
% fig.PaperPosition = [0 0 21 29.7]; 
% fig.Units = 'centimeters'; 
% fig.PaperSize=[21 29.7]; 
% fig.Units = 'centimeters'; 
% print(fig,'myFigPDF','-dpdf','-r200'); 

