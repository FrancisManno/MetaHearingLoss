function [Data]=SurfloadNplot( Name, Surf, Mask, Title, Color, Lim, RPATH, Save, Layer, h)
% home path
koti=getenv('KOTI');
% GitHUb path
git=[koti,'git_here/'];
% load toolboxes and define paths
addpath([koti, 'matlab_toolbox/export_fig/'])   % export figures
addpath([koti, 'matlab_toolbox/surfstat'])      % surfstats
addpath([git, 'MRI_MM_timing/Freesurfer'])      % read_mgh

%% ACQUIRED
% Load surfaces
Pial=read_mgh(Name,'pial_fsaverage5.mgh',Surf);
White=read_mgh(Name,'white_fsaverage5.mgh',Surf);
if Layer=='b'
    Data=(Pial+White./2).*Mask;
elseif Layer=='p'
    Data=Pial.*Mask;
else 
    Data=White.*Mask;
end

% histogram
% figure
% histogram(Data, 50);
% plot data
f=figure;
if h==1
        pos=[0 0 1260 275];
        hSurf(Data,Surf, Title)
    else
        pos=[0 0 700 500];
        midlatSurf(Data,Surf, Title)
end
    colormap(Color)
    SurfStatColLim(Lim)
    set(f,'Position',pos)
if Save==1
   disp(strcat('Exporting.... ',Title))
   export_fig(strcat(RPATH,'/',Title,'.tif'),'-m3')
   close(f)
end 
    
