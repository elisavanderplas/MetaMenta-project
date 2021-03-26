%% Runs all analyses for the Meta Menta Clinical Study (Experiment2)
%elisavanderplasATgmail.com

clear all; close all; fs = filesep;
baseDir =  ['~' fs 'Dropbox' fs 'MetaMenta-project' fs];
dirData_clinical = [baseDir 'Data' fs 'Exp2' fs];
scriptDir = [baseDir 'Analyses' fs];
addpath([baseDir fs 'Analyses' fs 'myfunctions' fs 'HMeta-d' fs 'Matlab' fs]);
addpath([baseDir fs 'Analyses' fs 'myfunctions']);

%load in the prepared data   
load([dirData_clinical 'allClinicalData.mat'])
load([dirData_clinical 'allMetaData.mat'])
load([dirData_clinical 'allDotsData.mat'])

%merge two groups of MetaData together for whole-sample analyses
metaData{3}.nR_S1 = [metaData{1}.nR_S1, metaData{2}.nR_S1];
metaData{3}.nR_S2 = [metaData{1}.nR_S2, metaData{2}.nR_S2];

%zscore all variables in the table
Data.MCQ_feelings = zscore(Data.MCQ_feelings);
Data.edu = zscore(Data.edu); 
Data.iq = (Data.iq-nanmean(Data.iq))/nanstd(Data.iq); 
Data.age = zscore(Data.age); 

%make a separate dataset without negative Mratios
Data1 = Data(Data.metaR > 0,:);
Data1.metaR = zscore(log(Data1.metaR));

%make a separate dataset without NaN Raads
Data2 = Data(find(~isnan(Data.RAADS)),:);

%independent samples ttest accuracy, line 362
[H,P,CI, STATS] = ttest2(Data.acc(1:40), Data.acc(41:end));
[H,P,KSSTAT] = kstest2(Data.acc(1:40), Data.acc(41:end));

%% Hypothesis 1
%step 1: simultaneous HMeta-d' hierarchical regression
mcmc_params.nsamples =20000; 
FIT1 = fit_meta_d_mcmc_regression(metaData{3}.nR_S1, metaData{3}.nR_S2, Data.MCQ_feelings');
cd(scriptDir)
[fig1, fig2, fig3] = regrModelfit_checks(FIT1, Data.metaR, Data.MCQ_feelings);
% compute probability
samples = FIT1.mcmc.samples.mu_beta1 > 0;
p_theta = (sum(samples(:) == 0))/(sum(samples(:)));

%step 2: frequentist linear model w/ covariates
fitlm(Data1, 'metaR~MCQ_feelings+age+gender+edu+IQ')

%NB. for the mixed-effect hierarchical regression model, see:
%hierarchicalRegression_Exp2.R

%check menta-ASD impairment effect, line 408
fitlm(Data, 'MCQ_feelings~group+age+gender+edu+IQ')

%% Hypothesis 2
%step 1 - ASD: frequentist linear model w/ covariates
fitlm(Data1, 'metaR~group+age+gender+edu+IQ')

%step 2 - ASD: simultaneous HMeta-d' hierarchical regression
Data4 = Data(find(~isnan(Data.iq)),:);
cov_CTL = [Data4.age(35:end)'; Data4.edu(35:end)';Data4.gender(35:end)'; Data4.iq(35:end)'];  
cov_ASD = [Data4.age(1:35)'; Data4.edu(1:35)';Data4.gender(1:35)'; Data4.iq(1:35)']  ;
FIT2.ASDregr = fit_meta_d_mcmc_regression(metaData{1}.nR_S1, metaData{1}.nR_S2, cov_ASD); %%TO DO remove ASD: 9, 14, 18, 26, 36
FIT2.CTLregr = fit_meta_d_mcmc_regression(metaData{2}.nR_S1, metaData{2}.nR_S2, cov_CTL); %%TO DO remove CTL: 23
cd(scriptDir)
[fig4, fig5] = groupModelfit_checks(FIT2.ASDregr, FIT2.CTLregr,Data.metaR);

