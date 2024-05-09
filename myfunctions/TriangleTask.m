function [MCQ_cat, MCQ_feelings, MCQ_cat_TOM, MCQ_cat_GD, MCQ_cat_RND] = TriangleTask(IDs, baseDir, recruitment_code, curr_session)
% gets the scores for the mentalising tasks (triangle task)
%elisavanderplasATgmail.com

fs = filesep;
temp_dat = []; 

names = {'_task-h14t', '_task-olrx'}; 
for idx = 1:length(names)
    for loop = 1:length(curr_session)
        dirDataQ = [baseDir 'Data' fs recruitment_code curr_session{loop} fs recruitment_code curr_session{loop} names{idx} '.csv']; 
        temp_dat = [temp_dat; readtable(dirDataQ)];
    end

for s = 1:length(IDs)
    
    dat_subject = temp_dat(find(temp_dat.ParticipantPrivateID==IDs(s)),:); %take index for each subject and only look at this persons data
    
    %% remove unnecessary info
    index_quest=strfind(dat_subject.ZoneType, 'response_button_text');
    
    for i= 1:length(index_quest)
        if  isempty(index_quest{i})
            index_quest{i}=0;
        end
    end
    index_quest=cell2mat(index_quest);
    dat_subject = dat_subject(~(index_quest ~= 1),:); %only response button texts (i.e. needed to be answered)
  
    %% remove practise answers
    index_quest=strfind(dat_subject.display, 'Trial session');
    
    for i= 1:length(index_quest)
        if  isempty(index_quest{i})
            index_quest{i}=0;
        end
    end
    index_quest=cell2mat(index_quest);
    dat_subject = dat_subject(~(index_quest ~= 0),:); %remove the practice trials
     
    %% distinguish MCQ_cat from MCQ_feelings
    index_cat1=strfind(dat_subject.Response, 'interaction');
    for i= 1:length(index_cat1)
        if  isempty(index_cat1{i})
            index_cat1{i}=0;
        end
    end
    index_cat1=cell2mat(index_cat1);
    
    MCQ_feelings(s) = sum(dat_subject.Correct(~(index_cat1 ~= 0),:))/length(dat_subject.Correct(~(index_cat1 ~= 0),:)); %percentage correct on no feeling-question
    MCQ_cat(s) = sum(dat_subject.Correct((index_cat1 ~= 0),:))/length(dat_subject.Correct((index_cat1 ~= 0),:));%percentage correct on cat-quesiton
    %% Update 09 May 2024: only record MCQ feelings when MCQ cat was correct
    
    %% distinguish TOM condition
    index_cat2=strfind(dat_subject.display, 'TOM session');
    for i= 1:length(index_cat2)
        if  isempty(index_cat2{i})
            index_cat2{i}=0;
        end
    end
    index_cat2=cell2mat(index_cat2);

    MCQ_cat_TOM(s) = sum(dat_subject.Correct(index_cat1 ~= 0 & index_cat2  ~= 0))/length(dat_subject.Correct(index_cat1 ~= 0 & index_cat2  ~= 0)) ;
    
    % Initialize accuracy recording variable
    MCQ_feelings = zeros(size(dat_subject.Correct));

    % Iterate through TOM sessions
    for i = 1:length(index_cat2)
        if index_cat2(i) ~= 0 % If it's a TOM session
            if i > 1 && dat_subject.Correct(i-1) == 1 % If preceding MCQ_cat question was correct
                MCQ_feelings(i) = dat_subject.Correct(i); % Record accuracy of MCQ_feelings
            end
        end
    end

    % Accuracy of MCQ_feelings only for TOM sessions with preceding correct MCQ_cat
    MCQ_feelings_tom = MCQ_feelings(MCQ_feelings ~= 0);  

    %% distinguish GD condition
    index_cat3=strfind(dat_subject.display, 'GD session');
    for i= 1:length(index_cat3)
        if  isempty(index_cat3{i})
            index_cat3{i}=0;
        end
    end
    index_cat3=cell2mat(index_cat3);
    MCQ_cat_GD(s) = sum(dat_subject.Correct(index_cat3 ~= 0))/length(dat_subject.Correct(index_cat3 ~= 0));
    
    %% distinguish RND condition
    index_cat4=strfind(dat_subject.display, 'GD session');
    for i= 1:length(index_cat4)
        if  isempty(index_cat4{i})
            index_cat4{i}=0;
        end
    end
    index_cat4=cell2mat(index_cat4);
    MCQ_cat_RND(s) = sum(dat_subject.Correct(index_cat4 ~= 0))/length(dat_subject.Correct(index_cat4 ~= 0));
    
end
end
