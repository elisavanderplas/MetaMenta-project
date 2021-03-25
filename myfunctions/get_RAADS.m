
function [MENTA, SOA, SOR, RAADS] = get_RAADS(ratings)

%ratings = participants' ratings on 14-item RAADS-14 scale
%(3: 'True now and when I was young', 2: 'True only now', 1: 'True only when I was younger than 16', 0: 'Never true'
%nsubjects = number of subjects (also the number of rows of the ratings)

%returns MENTA rating = mentalizing deficits
%returns SOA rating = social anxiety score 
%returns SOR rating = social reactivity score
%returns RAADS rating = main composite RAADS-14 score

%elisavanderplasATgmail.com

ratings = 5-ratings; %%inverse score
ratings(6) = 5-ratings(6);
MENTA = 0;
SOA = 0; 
SOR = 0;
RAADS = 0; 

    for i = [1,4,9,11,12,13,14] %items pertaining to MENTA rating
        MENTA = MENTA + ratings(i);
    end
    
    for i = [3,5,6,8] %items pertaining to SOA
        SOA = SOA + ratings(i);
    end
    
    for i =[2,7,10] %items pertaining to SOR
        SOR = SOR + ratings(i);
    end
    
    RAADS = sum(ratings); %all items
end
