%% Loads and prepares data for the Meta Menta Study (Exp 1)
%elisavanderplasATgmail.com
clear all; close all; fs = filesep;
all_sessions = {'v38', 'v39','v40', 'v41', 'v42', 'v43'}; %v33 + v34 = pilots, from v38 onwards: exp data

dat = [];full_IDs=[];
TMCQ_feelings = []; TMCQ_cat = [];TMCQ_cat_GD = [];TMCQ_cat_RND = [];TMCQ_cat_TOM = [];
TmetaD = []; TmetaR = []; TmetaP = [];
TBCIS = []; Tage = []; Teducation = []; Tgender = []; 
TIQ = []; TAQ10 = []; TAQ10_AD = []; TAQ10_AS = []; TAQ10_C= []; TAQ10_S=[]; TAQ10_I=[];
TRAADS=[]; TRAADS_SOA = []; TRAADS_SOR = []; TRAADS_MENTA = [];   
TnR_S1 =[];TnR_S2 =[]; sj_index = 1; 

for loop = 1:length(all_sessions)
    recruitment_code = 'data_exp_12022-';
    current_recruitment = [recruitment_code  all_sessions{loop}];
    baseDir =  fileparts(findpath);
    dirData = [baseDir 'Data' fs 'Exp1' fs];
    
    addpath([baseDir fs 'myfunctions' fs 'HMeta-d' fs 'Matlab' fs]);
    addpath([baseDir fs 'myfunctions']);
    
    cd(dirData);%get all collected data
    files = {'_task-pf6t', '_task-yzt9'}; %append split datasets
    
    for i = 1:length(files)
        data = [current_recruitment files{i} '.csv'];
        dat = [dat; readtable(data)];
    end
    
    % IDs = unique(dat.ParticipantPrivateID);% find the IDs of our participants; % IDs = IDs(~isnan(IDs));
    unique_confratings=unique(round(dat.confidence_rating*100)/100); %find the possible confidence levels
    unique_confratings(isnan(unique_confratings))=[]; %possible confidence ratings
    
    %%get the IDs of the participants
    %IDs = unique(dat.ParticipantPrivateID);% find the IDs of our participants
    %IDs = IDs(~isnan(IDs));
    
    %%or read it in from the inclusion sheet for curr session
    IDs = csvread(['total_IDs_' all_sessions{loop} '.csv']);

    for s=1:length(IDs)
        index_subject=dat(find(dat.ParticipantPrivateID==IDs(s)),:); %take index for each subject and only look at this persons data
        ParticipantPrivateID=index_subject.ParticipantPrivateID(end);%what is the ID of the current subject?
        
        %load variables
        correct=index_subject.correct;
        correct(isnan(correct))=0; %replace nans correct w 0
        label=index_subject.label;
        task_type=index_subject.Task_type;
        trial_type=index_subject.trial_type;
        RT=index_subject.Reactiontime;
        trial_exp=index_subject.Trial_real_experiment;
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
        
        %%adapt it if a participant has more than 26 practice trials, and if > 26 only keep the first 26
        if length(index_vistrial) > 336
            [r,st] = runlength(index_vistrial,numel(index_vistrial));
            result = r(logical(st));
            
            if max(result) > 26
                diff = max(result) - 26;
                index_vistrial(27:27+diff) = 0;
            end
        end
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
        conftrials=trial_exp(index_conftask==1 & index_conftrial==1); %conf task + conf rating
        RT_vistrial = RT(index_conftask==1 & index_vistrial==1);
        numDots_vistrial=numDots(index_conftask==1 & index_vistrial==1);
        conf_conftrial=confRating(index_conftask==1 & index_conftrial==1);
        conf_conftrial=round(conf_conftrial*100)/100; %%to make sure the decimals are in the same format as 'unique_confratings'
        keypress_vistrial=keypress(index_conftask==1 & index_vistrial==1);
        acc_vistrial=correct(index_conftask==1 & index_vistrial==1);%%accuracy==1: correct, accuracy==0: wrong
        
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
        nR_S1{s} = [fliplr(nR_S1_corr{s}), nR_S1_err{s}]; nR_S2{s} = [fliplr(nR_S2_err{s}), nR_S2_corr{s}];
        
        var_confrating(s)= max(sum([nR_S1{s}; nR_S2{s}]))/length(dir); %get the variance of confratings (for exclusion)
        acc_all(s,:)=acc_vistrial;conf_all(s,:)=conf_conftrial; numDots_all(s,:)=numDots_vistrial; nTrials(s)=length(acc_vistrial); %save variables in cell x subjects-format
    
        metaData.nR_S1{sj_index} = nR_S1{s};
        metaData.nR_S2{sj_index} = nR_S2{s};
     
        sj_index = sj_index + 1; 
    end
    
    %% Define exclusion criteria
    %%index_inclusion = find(mean(acc_all,2)<.85 & mean(acc_all,2)>.6 & var_confrating'<.9 & nTrials' == 153);
    %%index_exclusion = find(mean(acc_all,2)>.85 | mean(acc_all,2)<.6 | var_confrating'>.9);
    
    %%IDs_exclusion=IDs(index_exclusion);
    %%write the inclusion sheet for curr session
    %%dlmwrite(['total_IDs_' curr_session{loop} '.csv'], IDs_inclusion, 'precision', '%i') %%csvwrite messes up the decimal places
    
    %Single-fit Metacognition
    metaD = []; %%metacognitive sensitivity (meta-d')
    metaP = []; %%first-order performance (d1)
    metaR = []; %%metacognitive efficiency (meta-d'/d')
    for s = 1:length(IDs)
        FIT{s} = fit_meta_d_mcmc(nR_S1{s}, nR_S2{s}); %fitted at the individual level
        metaD = [metaD; FIT{s}.meta_d];
        metaR = [metaR; FIT{s}.M_ratio];
        metaP = [metaP; FIT{s}.d1];
    end
    
    %%Theory of Mind & questionnaire scores
    cd(scriptDir)
    [quest_data] = GetQuestScores(IDs, baseDir, recruitment_code, all_sessions);%%reorders questionnaire data in required format
    cd(scriptDir)
    [MCQ_cat, MCQ_feelings, MCQ_cat_TOM, MCQ_cat_GD, MCQ_cat_RND] = TriangleTask(IDs, baseDir, recruitment_code, all_sessions);%computes mentalising ability
    cd(scriptDir)
    for s = 1:length(IDs)
        Tage = [Tage; str2double(quest_data{5,s}(6))]; 
        Tgender = [Tgender; abs(str2double(quest_data{5,s}(3))-2)]; %male = 0, femal = 1
        Teducation = [Teducation; str2double(quest_data{5,s}(5))]; %1 = No education, 2 = High school or equivalent, 3 = Some college, 4 = BSc, 5 = MSc, 6 = Doctoral
        if length(quest_data{4,s})>17 %%some people may not have completed the IQ becuase its boring, in that case, just retain a NaN
            TIQ = [TIQ; get_ICAR(quest_data{4,s}(2:17,:))]; %get IQ (intelligence quotient)
        else TIQ = [TIQ; NaN];
        end
        [BCIS_SC,BCIS_SR,BCIS] = get_BCIS(str2double(quest_data{1,s}));%get BCIS (geck cognitive insight scale)
        TBCIS = [TBCIS; BCIS];
        
        if length(quest_data{2,s}) < 10 %% idem for the AQ10
            AQ10 = NaN; AQ10_AD = NaN;  AQ10_AS = NaN;  AQ10_C = NaN; AQ10_I = NaN; AQ10_S = NaN;
        else
            [AQ10, AQ10_AD, AQ10_AS, AQ10_C,AQ10_I,AQ10_S] = get_AQ10(str2double(quest_data{2,s}));%get AQ10 (autism quotient)
        end
        TAQ10 = [TAQ10; AQ10]; TAQ10_AD = [TAQ10_AD; AQ10_AD]; TAQ10_AS = [TAQ10_AS; AQ10_AS]; TAQ10_C= [TAQ10_C; AQ10_C]; TAQ10_S=[TAQ10_S; AQ10_S]; TAQ10_I=[TAQ10_I; AQ10_I];
        
        if length(quest_data{3,s}) < 14 %%Idem for the RAADS
            MENTA=NaN; SOA= NaN; SOR=NaN; RAADS=NaN;
        else
            [MENTA, SOA, SOR, RAADS] = get_RAADS(str2double(quest_data{3,s}));%get RAADS (autistic tendencies)
        end
        TRAADS=[TRAADS; RAADS]; TRAADS_SOA = [TRAADS_SOA; SOA]; TRAADS_SOR = [TRAADS_SOR; SOR]; TRAADS_MENTA = [TRAADS_MENTA; MENTA];
    
    end
    %%safe all these variables in the workspace of curr session for analysis
    cd(dirData)
    cd(dirData); save(['ws_' all_sessions{loop} '.mat']) % write for reading in .R file
    
    TMCQ_feelings = [TMCQ_feelings; MCQ_feelings'];TMCQ_cat = [TMCQ_cat; MCQ_cat'];TMCQ_cat_GD = [TMCQ_cat_GD; MCQ_cat_GD'];TMCQ_cat_TOM = [TMCQ_cat_TOM; MCQ_cat_TOM'];TMCQ_cat_RND = [TMCQ_cat_RND; MCQ_cat_RND'];
    TmetaD = [TmetaD; metaD]; TmetaR = [TmetaR; metaR]; TmetaP = [TmetaP; metaP];

end
    names = {'age', 'gender', 'education', 'MCQ_feelings', 'MCQ_cat', 'MCQ_cat_TOM', 'MCQ_cat_GD', 'MCQ_cat_RND', 'metaD', 'metaR','metaP','BCIS', 'IQ', 'AQ10', 'AQ10_AD', 'AQ10_AS', 'AQ10_C', 'AQ10_S', 'AQ10_I','RAADS', 'RAADS_MENTA', 'RAADS_SOA', 'RAADS_SOR'};
    data = table(Tage, Tgender, Teducation, TMCQ_feelings, TMCQ_cat, TMCQ_cat_TOM, TMCQ_cat_GD, TMCQ_cat_RND, TmetaD, TmetaR, TmetaP,TBCIS, TIQ, TAQ10,     TAQ10_AD, TAQ10_AS,    TAQ10_C,  TAQ10_S, TAQ10_I, TRAADS,  TRAADS_MENTA,  TRAADS_SOA,   TRAADS_SOR, 'VariableNames', names);

    %save the datasets
    cd([baseDir fs 'Data']); save('allData.mat', 'data'); 
    cd([baseDir fs 'Data']); save('allMetaData.mat', 'metaData'); 