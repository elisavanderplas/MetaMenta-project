function [IQ] = get_ICAR(ratings)

%ratings = participants' ratings on Toronto Alexhitymia Scale (1-20 from 1
%'Do not agree at all' to 5 'Agree completely'
%nsubjects = number of subjects (also the number of rows of the ratings)

%returns ID rating = difficulties 'identifying' feelings
%returns DESC rating = difficulties 'describing' feelings
%returns TAS rating = main composite TAS score

answers = {'5';'It''s impossible to tell';'53';'Sunday';'X';'G';'X';'N';'E';'B';'B';'D';'C';'B';'F';'G'};

IQ_temp = []; 

diff =length(answers)- length(ratings); 
    if diff > 0
        ratings = [ratings; zeros(diff,1)]; 
    elseif diff < 0
        ratings = [ratings; zeros(abs(diff),1)];
    end %% add zeros to missing responses
    
for i = 1:length(answers)%items pertaining to IQ rating
        IQ_temp = [IQ_temp; isequal(answers{i},ratings{i})];
end  
    IQ = sum(IQ_temp); %all items
end
