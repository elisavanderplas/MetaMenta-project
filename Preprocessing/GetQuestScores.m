function quest_data = GetQuestScores(IDs, baseDir, recruitment_code, curr_session)

%% Load each subjects' questionnaire data and compute composite scores
%% input: IDs as a row with included Participant IDs
%% output: quest_data structured order of the questionnaire data with order:
%%order = { 'bcis', 'AQ-10', 'RAADS-13', 'ICAR', 'demo'}
fs = filesep;

quest = {'betd', 'ch2f', 'dikw', 'pu6t', 'ynxa'};%4 CNTL participants
%quest = {'mi1h', 'o9hh', 'w5yv', 'pu6t'}; %4 ASD participants

for idx  = 1:length(quest)
    
    dat = [];
    for loop = 1:length(curr_session)
        dirDataQ = [recruitment_code curr_session{loop} '_questionnaire-' quest{idx}];
        quest_data{idx} = [];
        %% Load questionnaire data for this dataset
        cd([baseDir fs 'Data' fs recruitment_code curr_session{loop} fs]);
        dat = [dat; readtable([dirDataQ '.csv'])];
    end
    nsubjects = length(IDs);
    
    for subject=1:length(IDs)
        
        index_subject=dat(find(dat.ParticipantPrivateID==IDs(subject)),:); %take index for each subject and only look at this persons data
        
        %% remove the catch questions
        index_catch=strfind(index_subject.QuestionKey, 'catch');
        
        for i= 1:length(index_catch)
            if  isempty(index_catch{i})
                index_catch{i}=0;
            end
        end
        index_catch=cell2mat(index_catch);
        index_subject = index_subject(~(index_catch == 1),:);
        
        if idx == 4 %ICAR
             quest_data{idx,subject} = index_subject.Response;
            %%else NaNs and make note of it
        elseif idx == 5 %demo
            quest_data{idx,subject} = index_subject.Response;
        else 
            %% remove extra info such as trial nums etc
            index_quest=strfind(index_subject.QuestionKey, '-quantised');
            
            for i= 1:length(index_quest)
                if  isempty(index_quest{i})
                    index_quest{i}=0;
                end
            end
            index_quest=cell2mat(index_quest);
            
            quest_data{idx, subject}=index_subject.Response(~(index_quest == 0)); %all the answers for the asked items in chronological order
        end     
    end
end

