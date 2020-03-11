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
addpath([git, 'micasoft/sandbox/raul/MICA-MTL/2020_OHBM']) % roi2annot

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
        w=0.25;
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
    %area.frontal   = [2,23,3,12,14,17,18,19,20,24,27,28,32,26];
    %area.parietal  = [10,8,22,25,29,31];
    area.occipital = [5,11,13,21];
    area.insula    = 35;
    area.callosum  = 4;
    
    area.cingulum  = [26, 23, 10, 2];
    area.frontal   = [3,12,14,17,18,19,20,24,27,28,32];
    area.parietal  = [8,22,25,29,31];
% Brain vertices id
brain.areas=aparc;

% Subcortical areas to 0
brain.areas(brain.areas==0)=0;
brain.areas(brain.areas==36)=0;

% LEFT BRAIN AREAS
% Temporal  ID=1
for i=area.temporal; brain.areas(brain.areas==i)=1; end

% Cingulum ID=7
for i=area.cingulum; brain.areas(brain.areas==i)=7; end
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
for i=area.cingulum+36; brain.areas(brain.areas==i)=17; end

% AREA      LEFT    RIGTH
%--------------------------------
% temporal  1       11
% frontal   2       12
% parietal  3       13
% occipital 4       14
% insula    5       15
% copus C   6       16
% cingulum  7       17
lut.num=[1:7 11:17];
lut.lab={'L.temporal', 'L.frontal', 'L.parietal', 'L.occipital', 'L.insula', 'L.corpuscallosum', 'L.cingulum','R.temporal', 'R.frontal', 'R.parietal', 'R.occipital', 'R.insula', 'R.corpuscallosum', 'R.cingulum',}';
mask=brain.areas~=0;
viewSurf(brain.areas, SI, 'Brain Areas', 'white')
    colormap([0 0 0; flipud(scimaps.roma); scimaps.roma])
    SurfStatColLim([0 18])
    %export_fig(strcat(RPATH,'/00_brain_areas.tif'),'-m3')
    
% % QC cingulum
% for i=area.cingulum
%     brain.test=aparc;
%     brain.test(brain.test==i)=1000;
%     figure(i)
%     viewSurf(brain.test, SP, ['ID=',num2str(i),colortable.struct_names(i+1)], 'white')
%     colormap(parula)
% end
% 
% for i=1:14
%     brain.test=brain.areas;
%     brain.test(brain.test==lut.num(i))=1000;
%     figure(i)
%     viewSurf(brain.test, SP, ['ID=',num2str(i),lut.lab(i)], 'white')
%     colormap(parula)
% end

% Meta regression BIG-AREA estimates Plot on Surface the ROIs
mod.GMvolC=[-0.115968088, -0.587984493, -0.887484999, -0.525152272, 0.062800467, 0, 1.499954326, -0.542741494, -2.559312123, -1.112501433, -1.730142548, -0.133917583, 0, -0.801750649];
mod.GMvolA=[-0.830154051, -1.140068795, 0.389620086, -1.397831853, -1.353470242, 0, -2.883459267, 0.727021645, -1.437655806, 0.340507847, -1.523678975, -1.524554362, 0, -1.482610039];
mod.WMvolC=[-0.478048387, -1.340237902, -1.308139044, 0.502440237, 0.007912898, 0, -1.378645378, -0.552894497, -2.309850909, 0, 0, 0.736985692, 0, 0];
mod.WMfaC=[-0.69803376, 0, 0, -0.72542994, 0, 0, 0.297000873, -0.829837182, 0, 0, -0.72542994, -0.81776699, 0, 0];

% Meta regression BIG-AREA p values
modP.GMvolC =[0.603853656, 0.188162824, 0.084783984, 0.250176514, 0.917530504, 1, 0.096942767, 0.046745516, 0.000339907, 0.012325121, 0.053414262, 0.82280821, 1, 0.501546243];
modP.GMvolA =[0.183131914, 0.030445325, 0.680259682, 0.394545895, 0.409491814, 1, 0.095088675, 0.157333211, 0.040339808, 0.71885862, 0.061796312, 0.189771446, 1, 0.120168956];
modP.WMvolC =[0.030575624, 0.0183781, 0.058501134, 0.299869946, 0.988530303, 1, 0.164860726, 0.0126575, 5.02E-05, 1, 1, 0.181932128, 1, 1];
modP.WMfaC =[3.42E-08, 1, 1, 0.055661226, 1, 1, 0.316479315, 1.12E-15, 1, 1, 0.055661226, 0.064000549, 1, 1];

% For loop over P.VALUES structure labels    
fn = fieldnames(modP);
surfaces={SI SI SW SW};
pos=[0 0 700 500];
for k=1:numel(fn)
    f=figure;
    val=roi2annot(lut.num, modP.(fn{k})<0.05, brain.areas);
    midlatSurfNone(val.*mask, surfaces{k}, fn(k), 'white')
    colormap([[0 0 0]; [1 0 0]])
    set(f,'Position',pos)
    SurfStatColLim([0 1])
     export_fig(strcat(RPATH,'/metareg_',fn{k},'_pval.tif'),'-m3')
     close(f)
end
% For loop over structure labels    
fn = fieldnames(mod);
for k=1:numel(fn)
    f=figure;
    val=roi2annot(lut.num, mod.(fn{k}), brain.areas);
    midlatSurf(val.*mask, surfaces{k}, fn(k), 'white')
    colormap([scimaps.vik(1:128,1:3); [0.65 0.65 0.65]; scimaps.vik(129:256,1:3)])
    set(f,'Position',pos)
    SurfStatColLim([-3 3])
    export_fig(strcat(RPATH,'/metareg_',fn{k},'.tif'),'-m3')
    close(f)
end

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


