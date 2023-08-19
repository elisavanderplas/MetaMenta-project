function [age, gender, education, diagnosis] = GetDemographics(IDs, baseDir, recruitment_code, curr_session)

%% Load each included subjects' ID number 
%% Find the associated personalised code with the link question
%% Read the demographics of included participants in the corresponding order from the spreadsheet
%% input: IDs as a row with included Participant IDs
%% output: [age, gender, education, diagnosis]

fs = filesep;
quest = 'er13';

%% Load convertor data for this dataset
dirDataQ = [recruitment_code curr_session{loop} '_questionnaire-' quest];
cd([baseDir fs 'Data' fs recruitment_code curr_session{loop} fs]);
convertor = readtable([dirDataQ '.csv']);
responses = readtable('Demographics_v8.csv'); 

age = []; 
gender = []; 
education = []; 
diagnosis = []; 

for s = 1:length(IDs)

index_subject_code=convertor(find(convertor.ParticipantPrivateID==IDs(s)),:); %take index for each subject and only look at this persons data
code = index_subject_code.Response{2}; 

index_subject_responses = strfind(responses.ID, 'code'); %%doesn;t find the appropriate numbers!
       for i= 1:length(index_subject_responses)
            if  isempty(index_subject_responses{i})
                index_temp{i}=0;
            end
        end
        index_subj=cell2mat(index_temp);
        index_subject = index_subject_responses(~(index_subj == 1),:);
        
age = [age; index_subject.age]; 
gender = [gender; index_subject.sex];
diagnosis = [diagnosis; index_subject.diagnosis]; 
education = [education; index_subject.education]; 
end

    
  
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

