function [SC, SR, BCIS] = get_BCIS(ratings)

%ratings = participants' ratings on 15-item Beck Cognitive Insight Scale
%(0-3 from 0 'Do not agree at all' to 3 'Agree completely'
%nsubjects = number of subjects (also the number of rows of the ratings)

%returns SC rating = insight as self confidence 
%returns SR rating = insight as self reflectiveness 
%returns BCIS rating = main composite BCIS score
 
    SC = 0;
    SR = 0; 
    
    diff =length(ratings)- 15;
    
    if diff < 0
        ratings = [ratings; zeros(abs(diff),1)];
        %% add zeros to missing responses
    end
    
    if isnan(ratings(1))
         SC = NaN; SR = NaN; BCIS = NaN; 
    else
        
    for i = [1,4,5,6,8,12,14,15] %items pertaining to ID rating
        SR = SR + (ratings(i)-1);
    end
    
    for i = [2,7,9,10,11,13] %items pertaining to DESC rating
        SC = SC + (ratings(i)-1);
    end
    
    BCIS = sum(ratings -1); %all items 
    end
end
