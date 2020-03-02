clear all
close all
%% Set paths
% ---------------------------------------
% home path
koti='/host/yeatman/local_raid/rcruces/';
% GitHUb path
git=[koti,'git_here/']
% load toolboxes and define paths
addpath([koti, 'matlab_toolbox/export_fig/'])
addpath([koti, 'matlab_toolbox/surfstat'])
addpath([git, 'oma/matlab_scripts/surfStat'])   % fs_read_annotation
addpath([git, 'oma/matlab_scripts'])            % load_scientific_colormaps
addpath([git, 'MRI_MM_timing/Freesurfer'])      % read_mgh

% Working Directory
P = [koti, 'git_here/MetaHearingLoss/'];
% Results Directory
RPATH = [koti, 'tmp/Meta_figures'];
        if isequal(exist(RPATH, 'dir'),7)
            display('Directory Results/ already exists');
        else
            mkdir(RPATH)
        end
addpath(P); addpath([P,'surfaceVis'])

% Scientific Colormaps
scimaps=load_scientific_colormaps(git);

%% LOADS SURFACES
    % ---------------------------------------
    % SW= white matter surface  & SP = Pial Surface
        cd([koti, '/atlas/fsaverage5'])
        SW = SurfStatReadSurf({'surf/lh.white','surf/rh.white'});
        SP = SurfStatReadSurf({'surf/lh.pial','surf/rh.pial'});
        sphere = SurfStatReadSurf({'surf/lh.sphere','surf/rh.sphere'});
        
    % generate a mid thickness surface 
    % SM = Surface Mean
        SM.coord = (SP.coord + SW.coord)./2; 
        SM.tri   = SP.tri; 

    % Inflated mean surface
        w=0.4;
        maxs=max(SM.coord,[],2);
        mins=min(SM.coord,[],2);
        maxsp=max(sphere.coord,[],2);
        minsp=min(sphere.coord,[],2);
        SI=SM;
        for i=1:3
            SI.coord(i,:)=((sphere.coord(i,:)-minsp(i))/(maxsp(i)-minsp(i))...
                *(maxs(i)-mins(i))+mins(i))*w+SM.coord(i,:)*(1-w);
        end

        
    % load LEFT:  Desikan-Killiany Atlas
        [~, label, colortable] = fs_read_annotation('label/lh.aparc.annot');
        aparcleft = label; 
        for i = 1:size(colortable.table,1)
            mycode = colortable.table(i,5); 
            aparcleft(aparcleft == mycode) = i-1;
        end
    % load RIGHT:  Desikan-Killiany Atlas
        [~, label, colortable] = fs_read_annotation('label/rh.aparc.annot');
        aparcright = label; 
        for i = 1:size(colortable.table,1)
            mycode = colortable.table(i,5); 
            aparcright(aparcright == mycode) = i-1;
        end

    % Merges Right and left with unique labels
        aparc = [aparcleft;aparcright+36]; 
        aparc = aparc'; 
        % QC plot
        f = figure; 
        viewSurf(aparc, SP, 'Destrieux', 'black')
        pos=[0 0 1260 275];

            

    %% ---------------------------- 
    % VECTOR OF ALL LABELS
    labels=[colortable.struct_names;colortable.struct_names];
    for i=1:36
        labels(i)=strcat('Left_',labels(i));
    end
    for i=37:72
        labels(i)=strcat('Right_',labels(i));
    end
     cd (P);
     
%% ---------------------------- 
% MERGE LABELS BY BRAIN REGION
    area.temporal  = [1,6,7,9,15,16,30,33,34];
    area.frontal   = [2,23,3,12,14,17,18,19,20,24,27,28,32,26];
    area.parietal  = [10,8,22,25,29,31];
    area.occipital = [5,11,13,21];
    area.insula    = 35;
    area.callosum  = 4;
    area.cingulum  = [26, 23, 10, 2];

% Brain vertices id
brain.areas=aparc;

% Subcortical areas to 0
brain.areas(brain.areas==0)=0;
brain.areas(brain.areas==36)=0;

% LEFT BRAIN AREAS
% Temporal  ID=1
for i=area.temporal; brain.areas(brain.areas==i)=1; end
% Frontal   ID=2
for i=area.frontal; brain.areas(brain.areas==i)=2; end
% Parietal  ID=3
for i=area.parietal; brain.areas(brain.areas==i)=3; end
% Occipital ID=4, callosum ID=6
for i=area.callosum; brain.areas(brain.areas==i)=6; end
for i=area.occipital; brain.areas(brain.areas==i)=4; end
% Insula    ID=5
for i=area.insula; brain.areas(brain.areas==i)=5; end

% RIGHT BRAIN AREAS
for i=area.temporal+36; brain.areas(brain.areas==i)=11; end
for i=area.frontal+36; brain.areas(brain.areas==i)=12; end
for i=area.parietal+36; brain.areas(brain.areas==i)=13; end
for i=area.callosum+36; brain.areas(brain.areas==i)=16; end
for i=area.occipital+36; brain.areas(brain.areas==i)=14; end
for i=area.insula+36; brain.areas(brain.areas==i)=15; end

% AREA      LEFT    RIGTH
%--------------------------------
% temporal  1       11
% frontal   2       12
% parietal  3       13
% occipital 4       14
% insula    5       15
% copus C   6       16
mask=brain.areas~=0;
viewSurf(brain.areas, SM, 'Brain Areas', 'white')
    colormap([0 0 0; flipud(scimaps.roma); scimaps.roma])
    SurfStatColLim([0 18])

% % QC cingulum
% for i=area.cingulum
%     brain.test=aparc;
%     brain.test(brain.test==i)=1000;
%     figure(i)
%     viewSurf(brain.test, SP, ['ID=',num2str(i),colortable.struct_names(i+1)], 'white')
%     colormap(parula)
% end

%% Load MNI152 1mm data
cd([koti, 'data/OSF_meta/surfaces/fsaverage5']) 
%% ACQUIRED
% Load surfaces
p=read_mgh('ale_acquired-Voxel','pial_fsaverage5.mgh',SM);
w=read_mgh('ale_acquired-Voxel','white_fsaverage5.mgh',SM);
% plot data
figure
midlatSurf((p+w./2).*mask, SI, 'Acquired', 'white')
    colormap([.65 .65 .65; scimaps.lajolla])
    SurfStatColLim([1 200])    

%% CONGENITAL
% Load surfaces
p=read_mgh('ale_congenital-voxel','pial_fsaverage5.mgh',SM);
w=read_mgh('ale_congenital-voxel','white_fsaverage5.mgh',SM);
% plot data
figure
midlatSurf((p+w./2).*mask, SI, 'Acquired', 'white')
    colormap([.65 .65 .65; scimaps.lajolla])
    SurfStatColLim([1 200])    
