close all
%% Set paths
% ---------------------------------------
% home path
koti=getenv('KOTI');
% GitHUb path
git=[koti,'git_here/'];
% load toolboxes and define paths
addpath([koti, 'matlab_toolbox/export_fig/'])   % export figures
addpath([koti, 'matlab_toolbox/surfstat'])      % surfstats
addpath([koti, 'git_here/oma/matlab_scripts/spharm/']) %hSurf
addpath([git, 'oma/matlab_scripts/surfStat'])   % fs_read_annotation
addpath([git, 'oma/matlab_scripts'])            % load_scientific_colormaps
addpath([git, 'MRI_MM_timing/Freesurfer'])      % read_mgh

% Working Directory
P = [koti, 'git_here/MetaHearingLoss/'];
% Results Directory
RPATH = [koti, 'tmp/Meta_figures'];
        if isequal(exist(RPATH, 'dir'),7)
            disp('Directory Results/ already exists');
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
    export_fig(strcat(RPATH,'/00_brain_areas.tif'),'-m3')
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

%% ALE plots 
Col=[.6 .6 .6; scimaps.lajolla];
Lim=[1 200];
SurfloadNplot('ale_congenital-voxel', SI, mask, 'ale_con', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('ale_acquired-Voxel', SI, mask, 'ale_acq', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('ale_Adult', SI, mask, 'ale_adult', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('ale_AgedAdult', SI, mask, 'ale_aged', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('ale_Pediatric', SI, mask, 'ale_pediatric', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('ale_GM', SI, mask, 'ale_GM', Col, Lim, RPATH, 1, 'p', 1);
SurfloadNplot('ale_WM', SW, mask, 'ale_WM', [.75 .75 .75; scimaps.lajolla], Lim, RPATH, 1, 'w', 1);
%% ALE Cluster
Col=[0 0 0; [ones(255,2) zeros(255,1)]];
SurfloadNplot('ale_congenital-voxel_FWE01', SI, mask, 'ale_con_FWE', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('ale_acquired-Voxel_FWE01', SI, mask, 'ale_acq_FWE', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('ale_Adult_C01', SI, mask, 'ale_adult_C01', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('ale_AgedAdult_C01', SI, mask, 'ale_aged_C01', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('ale_Pediatric_C01', SI, mask, 'ale_pediatric_C01', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('ale_GM_C01', SI, mask, 'ale_GM_C01', Col, Lim, RPATH, 1, 'p', 1);
SurfloadNplot('ale_WM_C01', SW, mask, 'ale_WM_C01', Col, Lim, RPATH, 1, 'w', 1);


%% SDM plots 
Col=[scimaps.devon; repmat(.6,150,3); scimaps.lajolla];
Lim=[-3 3];
SurfloadNplot('sdm_con_z', SI, mask, 'sdm_con', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('sdm_acq_z', SI, mask, 'sdm_acq', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('sdm_adult_z', SI, mask, 'sdm_adult', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('sdm_aged_z', SI, mask, 'sdm_aged', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('sdm_pediatric_z', SI, mask, 'sdm_pediatric', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('sdm_gm_z', SI, mask, 'sdm_GM', Col, Lim, RPATH, 1, 'p', 1);
SurfloadNplot('sdm_wm_z', SW, mask, 'sdm_WM', [scimaps.devon; .75 .75 .75; scimaps.lajolla], Lim, RPATH, 1, 'w', 1);
%% SDM FWE
Col=[0 0 0; [ones(255,2) zeros(255,1)]];
Lim=[0 2];
SurfloadNplot('sdm_con_thr_p05', SI, mask, 'sdm_con-thr', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('sdm_acq_thr_p05', SI, mask, 'sdm_acq-thr', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('sdm_adult_thr_p05', SI, mask, 'sdm_adult-thr', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('sdm_aged_thr_p05', SI, mask, 'sdm_aged-thr', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('sdm_pediatric_thr_p05', SI, mask, 'sdm_pediatric-thr', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('sdm_gm_thr_p05', SI, mask, 'sdm_GM-thr', Col, Lim, RPATH, 1, 'p', 1);
SurfloadNplot('sdm_wm_thr_p05', SW, mask, 'sdm_WM-thr', Col, Lim, RPATH, 1, 'w', 1);


%% mKDA plots 
Col=[scimaps.devon; .6 .6 .6; scimaps.lajolla];
colW=[scimaps.devon; .75 .75 .75; scimaps.lajolla];
Lim=[-0.5 .5];
SurfloadNplot('mkda_con_contrast_proportion', SI, mask, 'mkda_con', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_con_GM_proportion', SI, mask, 'mkda_con_GM', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_con_WM_proportion', SW, mask, 'mkda_con_WM', colW, Lim, RPATH, 1, 'b', 1);

SurfloadNplot('mkda_acq_contrast_proportion', SI, mask, 'mkda_acq', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_acq_GM_proportion', SI, mask, 'mkda_acq_GM', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_acq_WM_proportion', SW, mask, 'mkda_acq_WM', colW, Lim, RPATH, 1, 'b', 1);

SurfloadNplot('mkda_Adult_proportion', SI, mask, 'mkda_adult', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('mkda_AgedAdult_proportion', SI, mask, 'mkda_aged', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('mkda_pediatric_proportion', SI, mask, 'mkda_pediatric', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('mkda_GM_proportion', SI, mask, 'mkda_GM', Col, Lim, RPATH, 1, 'p', 1);
SurfloadNplot('mkda_WM_proportion', SW, mask, 'mkda_WM', colW, Lim, RPATH, 1, 'w', 1);

%% mKDA FWE
Col=[0 0 0; [ones(255,2) zeros(255,1)]];
Lim=[0 2];
SurfloadNplot('mkda_con_contrast_FWE_all', SI, mask, 'mkda_con-fwe', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_con_GM_FWE_all', SI, mask, 'mkda_con_GM-fwe', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_con_WM_FWE_all', SW, mask, 'mkda_con_WM-fwe', Col, Lim, RPATH, 1, 'b', 1);

SurfloadNplot('mkda_acq_contrast_FWE_all', SI, mask, 'mkda_acq-fwe', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_acq_GM_FWE_all', SI, mask, 'mkda_acq_GM-fwe', Col, Lim, RPATH, 1, 'b', 1);
SurfloadNplot('mkda_acq_WM_FWE_all', SW, mask, 'mkda_acq-WM-fwe', Col, Lim, RPATH, 1, 'b', 1);

SurfloadNplot('mkda_Adult_FWE_all', SI, mask, 'mkda_adult-fwe', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('mkda_AgedAdult_FWE_all', SI, mask, 'mkda_aged-fwe', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('mkda_pediatric_FWE_all', SI, mask, 'mkda_pediatric-fwe', Col, Lim, RPATH, 1, 'b', 0);
SurfloadNplot('mkda_GM_FWE_all', SI, mask, 'mkda_GM-fwe', Col, Lim, RPATH, 1, 'p', 1);
SurfloadNplot('mkda_WM_FWE_all', SW, mask, 'mkda_WM-fwe', Col, Lim, RPATH, 1, 'w', 1);


