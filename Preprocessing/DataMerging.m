%% Merges the for the Meta Menta Clinical Study (use after the DataPreparation.m script)
%elisavanderplasATgmail.com

clear all;close all; fs = filesep;
ASD_session = 'v8'; 
recruitment_code = ['data_exp_27169-' ASD_session];
addpath(['~' fs 'Dropbox' fs 'ASDclinical' fs 'Analyses' fs 'myfunctions' fs 'HMeta-d' fs 'Matlab' fs]);
baseDir =  ['~' fs 'Dropbox' fs 'ASDclinical' fs];
dirData_clinical = [baseDir 'Data' fs recruitment_code fs];
scriptDir = [baseDir 'Analyses' fs];

%read in the included ASD IDs
cd(dirData_clinical)
T=readtable(['total_IDs_' ASD_session '.csv']);
ASD_IDs = T.prolific_ID;
    
%append variables from workspace
temp = load(['ws_' ASD_session '.mat']);
names = {'MCQ_feelings', 'MCQ_cat', 'metaD', 'metaR','metaP','BCIS_SC','BCIS_SR', 'IQ', 'AQ10', 'AQ10_AD', 'AQ10_AS', 'AQ10_C', 'AQ10_S', 'AQ10_I','RAADS', 'RAADS_MENTA', 'RAADS_SOA', 'RAADS_SOR', 'acc', 'conf'};
    
%append behavioural vars to initial demographics
ASD_data = addvars(T, temp.MCQ_feelings', temp.MCQ_cat', temp.metaD, temp.metaR, temp.metaP, temp.BCIS_SC, temp.BCIS_SR', temp.IQ, temp.AQ10, temp.AQ10_AD, temp.AQ10_AS, temp.AQ10_C, temp.AQ10_S, temp.AQ10_I, temp.RAADS, temp.MENTA, temp.SOA, temp.SOR, mean(temp.acc_all,2),mean(temp.conf_all,2),'NewVariableNames', names);
metaData{1}.nR_S1 = temp.nR_S1; %metaData{1} = ASD group
metaData{1}.nR_S2 = temp.nR_S2;
dotsData = temp.numDots_all;

%load in IDs from selected comparison subjects (from prev. study)
CTL_IDs= readtable('selected_comparisons.csv');

%%get control ps
trait_sessions = {'v38', 'v39','v40', 'v41', 'v42', 'v43'}; %%select from all recruitment sessions
%initiate key vars after merging
CTL_dat = [];
CTL_metaD = [];
CTL_metaR = [];
CTL_metaP = [];

%%loop through all trait sessions
for loop = 1:length(trait_sessions)
    trait_code = 'data_exp_12022-';
    trait_recruitment = [trait_code  trait_sessions{loop}];
    traitDir =  ['~' fs 'Dropbox' fs 'ASDTrait' fs];
    dirData_trait = [traitDir 'Data' fs trait_recruitment fs];
    
    cd(dirData_trait);%get all collected data
    files = {'_task-pf6t', '_task-yzt9'}; %append split datasets
    
    %make one long dataset containing all the data of all recruitment
    %sessions
    for i = 1:length(files)
        data = [trait_recruitment files{i} '.csv'];
        CTL_dat = [CTL_dat; readtable(data)];
    end
end
unique_confratings=unique(round(CTL_dat.confidence_rating*100)/100); %find the possible confidence levels
unique_confratings(isnan(unique_confratings))=[]; %possible confidence ratings
    
%find the data of each selected IDs
for s = 1:length(CTL_IDs.prolific_ID)
    index_subject=CTL_dat(find(CTL_dat.ParticipantPrivateID==CTL_IDs.prolific_ID(s)),:); %take index for each subject and only look at this persons data
        
    correct=index_subject.correct;
    correct(isnan(correct))=0; %replace nans correct w 0
    label=index_subject.label;
    task_type=index_subject.Task_type;
    trial_type=index_subject.trial_type;
    confRating=index_subject.confidence_rating;
    keypress=index_subject.key_press;
    numDots=index_subject.numDots;

    %select trials from the confidence sub-task
    index_conftask=strfind(task_type, 'simpleperceptual');
    for i = length(index_conftask)
        if isempty(index_conftask{i})
            index_conftask{i} = 0;
        end
    end
    index_conftask=cell2mat(index_conftask);

    label_conftask=label(index_conftask==1);
    %%select initial binary decision (left/right) trials from confidence subtask
    index_vistrial=strfind(label_conftask, 'responsePerceptual');
    for i= 1:length(index_vistrial)
        if  isempty(index_vistrial{i})
            index_vistrial{i}=0;
        end
    end
    index_vistrial=cell2mat(index_vistrial);
    index_vistrial(1:26)=0; index_vistrial(end) = 0; %%do not include practice trials

    %%select the subsequent confidence rating from confidence trials
    index_conftrial=strfind(label_conftask, 'confidencerating');
    for i= 1:length(index_conftrial)
        if  isempty(index_conftrial{i})
            index_conftrial{i}=0;
        end
    end
    index_conftrial=cell2mat(index_conftrial);

    %%select variables from the conftask & appropriate trial
    %conftrials=trial_exp(index_conftask==1 & index_conftrial==1); %conf task + conf rating
    conf_conftrial=confRating(index_conftask==1 & index_conftrial==1);
    conf_conftrial=round(conf_conftrial*100)/100; %%to make sure the decimals are in the same format as 'unique_confratings'
    keypress_vistrial=keypress(index_conftask==1 & index_vistrial==1);
    acc_vistrial=correct(index_conftask==1 & index_vistrial==1);%%accuracy==1: correct, accuracy==0: wrong
    numDots_vistrial=numDots(index_conftask==1 & index_vistrial==1);
        
    %sloppy, but have to recompute objectively correct answer because js script doesn't give that yet
    dir=ones(1, length(acc_vistrial)); %%assume dir == right (1)
    dir(acc_vistrial==1 & keypress_vistrial == 87)= -1; %when correct and chose left, dir == left (-1)
    dir(acc_vistrial==0 & keypress_vistrial == 69)= -1; %when wrong and chose right, dir == left (-1)

    % calculate meta-d' variables
    for r = 1:length(unique_confratings) %%for all possible ratings
        nR_S1_corr{s}(r) = sum(conf_conftrial==unique_confratings(r) & dir'==-1 & acc_vistrial==1); %how often reported confrating r when dir==left & acc==1
        nR_S1_err{s}(r) = sum(conf_conftrial==unique_confratings(r) & dir'==-1 & acc_vistrial==0); %how often reported confrating r when dir==left & acc==0
        nR_S2_corr{s}(r) = sum(conf_conftrial==unique_confratings(r) & dir'==1 & acc_vistrial==1);%idem for dir==right
        nR_S2_err{s}(r) = sum(conf_conftrial==unique_confratings(r) & dir'==1 & acc_vistrial==0);
    end
    %get them in order from certainly left to certainly right
    metaData{2}.nR_S1{s} = [fliplr(nR_S1_corr{s}), nR_S1_err{s}];
    metaData{2}.nR_S2{s} = [fliplr(nR_S2_err{s}), nR_S2_corr{s}];%metaData{2} =CNTRL group
    %get the actual meta-d' scores 4 comparisom participants
    FIT = fit_meta_d_mcmc([fliplr(nR_S1_corr{s}), nR_S1_err{s}], [fliplr(nR_S2_err{s}), nR_S2_corr{s}]);
    CTL_metaD = [CTL_metaD; FIT.meta_d];
    CTL_metaR = [CTL_metaR; FIT.M_ratio];
    CTL_metaP = [CTL_metaP; FIT.d1]; 
    acc_all(s,:)=acc_vistrial;conf_all(s,:)=conf_conftrial; 
    dotsData(s+40,:) = numDots_vistrial;  
end
    
%get the corresponding questionnaire variables of previous recruitment
cd(scriptDir)
[quest_data] = GetQuestScores(CTL_IDs.prolific_ID, traitDir, trait_code, trait_sessions);%%reorders questionnaire data in required format
cd(scriptDir)
[MCQ_cat, MCQ_feelings, MCQ_cat_TOM, MCQ_cat_GD, MCQ_cat_RND] = TriangleTask(CTL_IDs.prolific_ID, traitDir,trait_code, trait_sessions);%computes mentalising ability
cd(scriptDir)
for s = 1:length(CTL_IDs.prolific_ID)
      if length(quest_data{4,s})>17 %%some people may not have completed the IQ becuase its boring, in that case, just retain a NaN
        IQ(s,:) = get_ICAR(quest_data{4,s}(2:17,:)); %get IQ (intelligence quotient)
    else IQ(s,:) = NaN;
    end
    [BCIS_SC(s,:),BCIS_SR(s),BCIS(s)] = get_BCIS(str2double(quest_data{1,s}));%get BCIS (geck cognitive insight scale)
    if length(quest_data{2,s}) < 10 %% idem for the AQ10
        AQ10(s,:) = NaN; AQ10_AD(s,:) = NaN;  AQ10_AS(s,:) = NaN;  AQ10_C(s,:) = NaN; AQ10_I(s,:) = NaN; AQ10_S(s,:) = NaN;
    else
        [AQ10(s,:), AQ10_AD(s,:), AQ10_AS(s,:), AQ10_C(s,:),AQ10_I(s,:),AQ10_S(s,:)] = get_AQ10(str2double(quest_data{2,s}));%get AQ10 (autism quotient)
    end
    if length(quest_data{3,s}) < 14 %%Idem for the RAADS
        MENTA(s,:)=NaN; SOA(s,:) = NaN; SOR(s,:)=NaN; RAADS(s,:)=NaN;
    else
        [MENTA(s,:), SOA(s,:), SOR(s,:), RAADS(s,:)] = get_RAADS(str2double(quest_data{3,s}));%get RAADS (autistic tendencies)
    end
end

%%append to initial demographics of extra participants
CTL_data = addvars(CTL_IDs, MCQ_feelings',MCQ_cat',CTL_metaD,CTL_metaR,CTL_metaP,BCIS_SC,BCIS_SR',IQ,temp.AQ10, temp.AQ10_AD, temp.AQ10_AS, temp.AQ10_C, temp.AQ10_S, temp.AQ10_I, temp.RAADS, temp.MENTA, temp.SOA, temp.SOR,mean(acc_all,2),mean(conf_all,2),'NewVariableNames', names);
%%append to dataset with ASD participants
Data = [ASD_data; CTL_data]; 

%get ASD vs no-ASD dummy
Data.group = [repmat(0.5,40,1);repmat(-0.5,40,1)]; 

%%safe all these variables in the workspace of curr session for analysis
cd([baseDir fs 'Data']); save('allClinicalData.mat', 'Data'); 
cd([baseDir fs 'Data']); save('allMetaData.mat', 'metaData'); 
cd([baseDir fs 'Data']); save('allDotsData.mat', 'dotsData'); 

save(['ws_comparisons.mat']) % write for reading in .R file  
