## cleans up and analyses autism + comparison data
## elisavanderplasATgmail.com

rm(list=ls())
require(R.matlab) 
require(lme4)
require(car)
require(optimx)
require(ggplot2)
require(plyr)
options(contrasts = c("contr.treatment", "contr.poly")) # This is R defaults but set it anyway to be safe

MCQ_cat = NULL
asdData = NULL 
ctlData = NULL
bigData = NULL
dat = NULL
asdDir = "~/Dropbox/MetaMenta/Data/Exp2/"
current_recruitment = "data_exp_27169-v8"
files = c('_task-pf6t', '_task-yzt9')
for (i in 1:length(files)){
  data = read.csv2(paste(asdDir, current_recruitment, '/', current_recruitment, files[i], '.csv', sep = ""), header = T, sep=",",)
  dat = rbind(dat,data)
}

ASDws = readMat(paste(asdDir, 'data_exp_27169-v8', '/', 'ws_v8.mat', sep = ""), header=T, sep = ",", )
CTLws = readMat(paste(asdDir, 'ws_comparisons.mat', sep = ""), header = T, sep = ",",)

MCQ_emo = c(t(CTLws$MCQ.feelings), t(ASDws$MCQ.feelings))

ASD = read.csv2(paste(asdDir, current_recruitment, '/','total_IDs_v8.csv', sep = ""), header = T, sep = ",",)
CTL = read.csv2(paste(asdDir, current_recruitment, '/','selected_comparisons.csv', sep = ""), header = T, sep=",",)
asdIDs = ASD$prolific_ID
ctlIDS = CTL$prolific_ID

for (s in 1:length(asdIDs)){
  subj_dat = dat[dat$Participant.Private.ID==asdIDs[s],] ##load variables for specific subject
  conftask_dat=subj_dat[subj_dat$Task_type=="simpleperceptual",]##select trials from the confidence sub-task
  
  vistrials=conftask_dat[conftask_dat$label=="responsePerceptual",]##select initial binary decision (left/right) trials from the confidence sub-task
  conftrials=conftask_dat[conftask_dat$label=="confidencerating",]##select subsequent confidence rating from the confidence sub-task
  
  logRT = scale(log(vistrials$Reactiontime))
  conf = round(as.numeric(conftrials$confidence_rating)*100)/100
  keypress=vistrials$key_press
  acc=vistrials$correct 
  acc[is.na(acc)]=0##accuracy==1: correct, accuracy==0: wrong
  acc = acc-0.5##accuracy==0.5: correct, accuracy==-0.5: wrong
  
  #have to ecompute objectively correct answer because js script doesn't give that yet
  dir=rep(1, length(acc))
  for (t in 1:length(acc)){
    if (acc[t] ==1 & keypress[t] == 87){
      dir[t]= -1}
    else if (acc[t] == 0 && keypress[t]==69){
      dir[t] = -1}
  }##correct and chose left, dir == -1 (left) or wrong and chose right, dir == -1 (left)
  
  #get all vars behind each other per subject
  subj = rep(s, length(acc))
  group = rep(-0.5, length(acc))
  menta = rep(MCQ_emo[s], length(acc))
  subData1 = data.frame("subj"=subj, "group"=group, "dir"=dir,"acc"=acc, "conf"=conf, "logRT"=logRT, "menta"=menta)
  
  #add to larger file 
  asdData = rbind(asdData, subData1)
}

##now do the same for comparisons
dat = NULL
CTLData = NULL
sessions = c('v38', 'v39', 'v40', 'v41', 'v42', 'v43')
#load in all data
for (i in 1:length(sessions)){ 
  currentData = paste('data_exp_12022-',sessions[i],sep="")
  ctlDir = "~/Dropbox/MetaMenta/Data/Exp1/"
  Dir = paste(ctlDir,currentData, '/', sep="")
  files = c('_task-pf6t', '_task-yzt9')
  for (j in 1:length(files)){
    data = read.csv2(paste(Dir, currentData, files[j],'.csv',sep=""), header=T, sep=",", )
    dat = rbind(dat, data)
  }
}
#scale ASD variables
for (s in 1:length(ctlIDS))
{
  subj_dat = dat[dat$Participant.Private.ID==ctlIDS[s],] ##load variables for specific subject
  conftask_dat=subj_dat[subj_dat$Task_type=="simpleperceptual",]##select trials from the confidence sub-task
 
  vistrials=conftask_dat[conftask_dat$label=="responsePerceptual",]##select initial binary decision (left/right) trials from the confidence sub-task
  conftrials=conftask_dat[conftask_dat$label=="confidencerating",]##select subsequent confidence rating from the confidence sub-task

  logRT = scale(log(vistrials$Reactiontime))
  conf = round(as.numeric(conftrials$confidence_rating)*100)/100
  keypress=vistrials$key_press
  acc=vistrials$correct 
  acc[is.na(acc)]=0##accuracy==1: correct, accuracy==0: wrong
  acc = acc-0.5##accuracy==0.5: correct, accuracy==-0.5: wrong
  
  #have to ecompute objectively correct answer because js script doesn't give that yet
  dir=rep(1, length(acc))
  for (t in 1:length(acc)){
    if (acc[t] ==1 & keypress[t] == 87){
      dir[t]= -1}
    else if (acc[t] == 0 && keypress[t]==69){
      dir[t] = -1}
    }##correct and chose left, dir == -1 (left) or wrong and chose right, dir == -1 (left)
    
  #get all vars behind each other per subject
  subj = rep(s, length(acc))
  group = rep(0.5, length(acc))
  menta = rep(MCQ_emo[s+40], length(acc))
  subData2 = data.frame("subj"=subj,"group"=group, "dir"=dir, "acc"=acc, "conf"=conf, "logRT"=logRT, "menta"=menta)
    
  #add to larger file 
  CTLData = rbind(CTLData, subData2)
}
bigData <- rbind(asdData, CTLData)
# Factors
bigData$subj <- factor(bigData$subj)
bigData$group <- factor(bigData$group, labels=c("ASD", "comparison"))

# skip rows with NaNs
bigData_clean <- na.omit(bigData)

# get median MCQ_feelings
MCQ_med <- median(bigData_clean$menta)
bigData_clean$menta_bi= cut(as.numeric(bigData_clean$menta),breaks=c(min(bigData_clean$menta),MCQ_med,max(bigData_clean$menta)),include.lowest=T, labels=c("low", "high"))
bigData_clean$menta_bi <- factor(bigData_clean$menta_bi)

## distinguish between error/correct trials
bigData_err <- bigData_clean[bigData_clean$acc == -0.5, ]
bigData_corr <- bigData_clean[bigData_clean$acc == 0.5, ]
asdData_err <- asdData[asdData$acc == -0.5, ]
asdData_corr <- asdData[asdData$acc == 0.5, ]
CTLData_err <- CTLData[CTLData$acc == -0.5, ]
CTLData_corr <- CTLData[CTLData$acc == 0.5, ]
bigData_lmenta <- bigData_clean[bigData_clean$menta_bi == "low", ]
bigData_hmenta <- bigData_clean[bigData_clean$menta_bi == "high", ]

# H1. conduct a hierarchical regression to see if interaction w/ MCQ can explain how much confidence is influenced by standardized log RT
confModel_noMCQ = lmer(conf ~ acc + logRT + acc * logRT + (1 + acc + logRT|subj), data=bigData_clean
                      , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))

confModel_wMCQ = lmer(conf ~ menta*(acc + logRT + acc * logRT) + (1 + acc + logRT|subj), data=bigData_clean
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE, REML = FALSE)))

fix <- fixef(confModel_wMCQ)
print(summary(confModel_wMCQ))
print(Anova(confModel_wMCQ, type = 3))
coef(summary(confModel_wMCQ)) #get the contrast statistics
fix.se <- sqrt(diag(vcov(confModel_wMCQ)))

## check if including mentalizing efficiency as interaction improved the fit of the model 
anova(confModel_noMCQ,confModel_wMCQ) 

##make a nice figure of conf~RTxMENTA interaction, Figure 3b
ggplot(bigData_clean, aes(x=logRT, y=conf, colour=menta_bi)) + 
  geom_count() + 
  scale_color_manual(values=c("salmon", "turquoise3")) +
  geom_point(shape=19, size=0.5, alpha = 1.0) + 
  geom_smooth(method="lm", se = T, aes(fill=menta_bi), alpha = 0.2) + 
  labs(y="Confidence", x = "logRT (z-score)", color = "Mentalizing efficiency") + 
  theme_minimal() + theme(axis.text=element_text(size=18),axis.title=element_text(size=25))

## get the coefficients for Figure 3a
# lowMENTA
lmenta_coef = lmer(conf ~ logRT + (1 + logRT|subj), data=bigData_lmenta
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))
fix <- fixef(lmenta_coef)
fix.se <- sqrt(diag(vcov(lmenta_coef)))
betas <- c(fix, fix.se)
write.csv(betas, file = paste(asdDir, 'regression_betas_lmenta.csv'))

# highMENTA
hmenta_coef = lmer(conf ~ logRT + (1 +  logRT|subj), data=bigData_hmenta
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))
fix <- fixef(hmenta_coef)
fix.se <- sqrt(diag(vcov(hmenta_coef)))
betas <- c(fix, fix.se)
write.csv(betas, file = paste(asdDir, 'regression_betas_hmenta.csv'))


#H2. Autism: conduct a hierarchical regression to see if interaction w/ RAADS can explain how much confidence is influenced by standardized log RT
confModel_noASD = lmer(conf ~ acc + logRT + acc * logRT + (1 + acc + logRT|subj), data=bigData_clean
                        , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))

confModel_wASD = lmer(conf ~ group*(acc + logRT + acc * logRT) + (1 + acc + logRT|subj), data=bigData_clean
                 , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE, REML = FALSE)))

fix <- fixef(confModel_wASD)
print(summary(confModel_wASD))
print(Anova(confModel_wASD, type = 3))
coef(summary(confModel_wASD)) #get the contrast statistics
fix.se <- sqrt(diag(vcov(confModel_wASD))) 

## check if including AQ trials as interaction improved the fit of the model 
anova(confModel_noASD,confModel_wASD) 

## Get the coefficients for error-correct independent analyses
# correct, ASD
ASD_corr_coef = lmer(conf ~ logRT + (1 + logRT|subj), data=asdData_corr
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))
fix <- fixef(ASD_corr_coef)
fix.se <- sqrt(diag(vcov(ASD_corr_coef)))
betas <- c(fix, fix.se)
write.csv(betas, file = paste(asdDir, 'regression_betas_ASD_corr.csv'))
# correct, CTL
CTL_corr_coef = lmer(conf ~ logRT + (1 +  logRT|subj), data=CTLData_corr
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))
fix <- fixef(CTL_corr_coef)
fix.se <- sqrt(diag(vcov(CTL_corr_coef)))
betas <- c(fix, fix.se)
write.csv(betas, file = paste(asdDir, 'regression_betas_CTL_corr.csv'))
# error, ASD
ASD_err_coef = lmer(conf ~ logRT + (1 + logRT|subj), data=asdData_err
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))
fix <- fixef(ASD_err_coef)
fix.se <- sqrt(diag(vcov(ASD_err_coef)))
betas <- c(fix, fix.se)
write.csv(betas, file = paste(asdDir, 'regression_betas_ASD_err.csv'))
# error, CTL
CTL_err_coef = lmer(conf ~ logRT + (1 + logRT|subj), data=CTLData_err
                     , control = lmerControl(optimizer = "optimx", calc.derivs = FALSE, optCtrl = list(method = "bobyqa", starttests = FALSE, kkt = FALSE)))
fix <- fixef(CTL_err_coef)
fix.se <- sqrt(diag(vcov(CTL_err_coef)))
betas <- c(fix, fix.se)
write.csv(betas, file = paste(asdDir, 'regression_betas_CTL_err.csv'))


