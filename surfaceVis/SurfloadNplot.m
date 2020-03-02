function [ Pial, White ] = SurfloadNplot( data, surf, title, background)

cd([koti, 'data/OSF_meta/surfaces/fsaverage5'])
%% ACQUIRED
% Load surfaces
Pial=read_mgh('ale_acquired-Voxel','pial_fsaverage5.mgh',SM);
White=read_mgh('ale_acquired-Voxel','white_fsaverage5.mgh',SM);
% plot data
figure
midlatSurf((Pial+White./2).*mask, SI, 'Acquired', 'white')
    colormap([.65 .65 .65; scimaps.lajolla])
    SurfStatColLim([1 200])
