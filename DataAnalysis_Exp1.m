%% Runs all analyses for the Meta Menta Study (Experiment 1)
%elisavanderplasATgmail.com

clear all; close all; fs = filesep;
baseDir =  ['~' fs 'Dropbox' fs 'MetaMenta' fs];
dirData_clinical = [baseDir 'Data' fs 'Exp1' fs];
scriptDir = [baseDir 'Analyses' fs];
addpath([baseDir fs 'Analyses' fs 'myfunctions' fs 'HMeta-d' fs 'Matlab' fs]);
addpath([baseDir fs 'Analyses' fs 'myfunctions']);

%load in the prepared alldata   
load([dirData_clinical 'allData.mat'])
load([dirData_clinical 'allMetaData.mat'])

%zscore key variables in the table
data.MCQ_feelings = zscore(data.MCQ_feelings);
data.edu = zscore(data.education); 
data.IQ = (data.IQ-nanmean(data.IQ))/nanstd(data.IQ); 
data.age = zscore(data.age); 
data.AQ10 = (data.AQ10-nanmean(data.AQ10))/nanstd(data.AQ10)*-1; %because inv-scored
data.AQ10_C = (data.AQ10_C-nanmean(data.AQ10_C))/nanstd(data.AQ10_C)*-1; %because inv-scored
data.RAADS = (data.RAADS-nanmean(data.RAADS))/nanstd(data.RAADS);
data.RAADS_M = (data.RAADS_MENTA-nanmean(data.RAADS_MENTA))/nanstd(data.RAADS_MENTA);

%separate dataset without negative Mratios
data1 = data(data.metaR > 0,:);
data1.metaR = zscore(log(data1.metaR));

%separate dataset without NaN questionnaires
data2 = data(find(~isnan(data.RAADS)),:); 
metaData(2).nR_S1 = metaData(1).nR_S1;%to allow for no RAADS, remove 241 and 322
metaData(2).nR_S2 = metaData(1).nR_S2;

%check validity of menta-score, line 235-236
[RHO,PVAL] = corr(data2.MCQ_cat, data2.RAADS, 'Type', 'Spearman');
[RHO,PVAL] = corr(data2.MCQ_cat, data2.AQ10, 'Type', 'Spearman');

%% Hypothesis 1
%step 1: simultaneous HMeta-d' hierarchical regression
FIT1 = fit_meta_d_mcmc_regression(metaData(1).nR_S1, metaData(1).nR_S2, data.MCQ_feelings');
cd(scriptDir)
[fig1, fig2, fig3] = modelfit_checks(FIT1, data1.metaR, data1.MCQ_feelings, 'Menta');
% compute probability
samples = FIT1.mcmc.samples.mu_beta1 > 0;
p_theta = (sum(samples(:) == 0))/(sum(samples(:)));

%step 2: frequentist linear model w/ covariates
fitlm(data1, 'metaR~MCQ_feelings+age+gender+education+IQ')
%NB, for "distinct constructions of confidence in mentalizing" see 'hierarchicalRegression_Exp1.r' script

%% replicate menta-AQ effect, line 276-277
%step 1 - AQ: frequentist linear model w/ covariates
fitlm(data, 'MCQ_cat~AQ10+age+gender+education+IQ')
%step 2 - RAADS: frequentist linear model w/ covariates
fitlm(data, 'MCQ_cat~RAADS+age+gender+education+IQ') %% so focus on the RAADS

%% Hypothesis 2
%step 1 - RAADS: simultaneous HMeta-d' hierarchical regression
FIT2 = fit_meta_d_mcmc_regression(metaData(2).nR_S1, metaData(2).nR_S2, data2.RAADS');
cd(scriptDir)
[fig4, fig5, fig6] = modelfit_checks(FIT2,data2.metaR, data2.RAADS, 'RAADS-14');
% compute probability
samples = FIT2.mcmc.samples.mu_beta1 > 0;
p_theta = (sum(samples(:) == 0))/30000;

%step 2 - RAADS: frequentist linear model w/ covariates
fitlm(data1, 'metaR~RAADS+age+gender+education+IQ')

%NB, for "distinct constructions of confidence in RAADS" see 'hierarchicalRegression_Exp1.r' script
[fig7] = betaPlot(1); %%plot the coefficients for Experiment 1 (Figure 2a)

%% Exploratory 3
%step 1 - AQ10-communication: simultaneous HMeta-d' hierarchical regression
FIT3 = fit_meta_d_mcmc_regression(metaData(2).nR_S1, metaData(2).nR_S2, data2.AQ10_C');
[fig4, fig5, fig6] = modelfit_checks(FIT3, data2.metaR, data2.AQ10_C, 'AQ10 communication'); 
% compute probability
samples = FIT3.mcmc.samples.mu_beta1 > 0; 
p_theta = (sum(samples(:) == 1))/30000; 

%step 2 - communication: frequentist linear model w/ covariates
fitlm(data1, 'metaR~AQ10_C+age+gender+education+IQ') 

%step 1 - RAADS-Menta: simultaneous HMeta-d' hierarchical regression
FIT4 = fit_meta_d_mcmc_regression(metaData(2).nR_S1, metaData(2).nR_S2, data2.RAADS_M');
[fig4, fig5, fig6] = modelfit_checks(FIT4, data2.metaR, data2.RAADS_M, 'RAADS menta.'); 
% compute probability
samples = FIT4.mcmc.samples.mu_beta1 > 0; 
p_theta = (sum(samples(:) == 1))/30000; 

%step 2 - communication: frequentist linear model w/ covariates
fitlm(data1, 'metaR~RAADS_M+age+gender+education+IQ') 

