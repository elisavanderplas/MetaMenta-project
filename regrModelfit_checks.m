function [fig1, fig2, fig3] = regrModelfit_checks(MODEL, var1, var2)

%% takes as input a HMeta-d regression model fit, as well as the group level metacognition (var1) and the dependent variable (var2)
%% returns the trace plot and posterior density histogram plot (fig1), and a correlation plot between var1 and var2 (fig2),

color_TOM = {[0.129, 0.050, 0.568], [0.960, 0.325, 0.019]};%http://doc.instantreality.org/tools/color_calculator/

fig1 = figure;
subplot(2,3,1)
histogram(exp(MODEL.mcmc.samples.mu_logMratio(:)),500, 'facecolor', [0.8, 0.8, 0.8], 'edgecolor',[0.7, 0.7, 0.7], 'facealpha', 0.4);
title('95% HDI Mratio', 'fontsize', 20);
HDI = calc_HDI(exp(MODEL.mcmc.samples.mu_logMratio(:)));
xline(HDI(1), '--', 'color', [0.7, 0.7, 0.7], 'linewidth', 2)
xline(HDI(2), '--', 'color', [0.7, 0.7, 0.7], 'linewidth', 2)
text(HDI(1), 200, num2str(round(HDI,3)), 'FontSize', 14);
xline(0, '-', 'color', 'k', 'linewidth', 1)
ylabel('No. of samples', 'FontSize', 18);
xlabel('Metacognitive efficiency', 'FontSize',18);
xlim([0.6 1.0])

subplot(2,3,[2,3,5,6])
hold all
scatter(var1, var2',70,'Marker', 'o', 'MarkerEdgeColor', [0.7, 0.7, 0.7], 'MarkerFaceColor',[0.7, 0.7, 0.7],'LineWidth',2);
hLine = refline;
hLine.Color = 'k';
hLine.LineWidth = 2;
xlabel('Mentalizing efficiency', 'FontSize', 26);
ylabel('Metacognitive efficiency', 'FontSize',26);
xlim([-0.5 1.5])
set(gcf, 'color', 'w');

subplot(2,3,4)
histogram(MODEL.mcmc.samples.mu_beta1(:),500,'facecolor', [0.8, 0.8, 0.8], 'edgecolor', [0.7, 0.7, 0.7], 'facealpha', 0.4);
title(['95% HDI Menta'], 'fontsize', 20);
HDI = calc_HDI(MODEL.mcmc.samples.mu_beta1(:));
xline(HDI(1), '--', 'color', [0.7, 0.7, 0.7], 'linewidth', 2)
xline(HDI(2), '--', 'color', [0.7, 0.7, 0.7], 'linewidth', 2)
text(HDI(1)+0.02, 235, num2str(round(HDI,3)), 'FontSize', 14);
xline(0, '-', 'color', 'k', 'linewidth', 1)
ylabel('No. of samples', 'FontSize', 18);
xlabel('Mentalizing efficiency', 'FontSize',18);
xlim([-0.1 0.3])
set(gcf, 'color', 'w')

fig2 = figure;
set(gcf, 'Units', 'normalized');
set(gcf, 'Position', [0.2 0.2 0.5 0.5]);
set(gcf, 'color', 'w')

Nsub = length(MODEL.d1);
ts = tinv([0.05/2,  1-0.05/2],Nsub-1);

if any(isnan(MODEL.obs_FAR2_rS1(:))) || any(isnan(MODEL.obs_HR2_rS1(:))) || any(isnan(MODEL.obs_FAR2_rS2(:))) || any(isnan(MODEL.obs_HR2_rS2(:)))
    warning('One or more subjects have NaN entries for observed confidence rating counts; these will be omitted from the plot')
end

mean_obs_FAR2_rS1 = nanmean(MODEL.obs_FAR2_rS1);
mean_obs_HR2_rS1 = nanmean(MODEL.obs_HR2_rS1);
mean_obs_FAR2_rS2 = nanmean(MODEL.obs_FAR2_rS2);
mean_obs_HR2_rS2 = nanmean(MODEL.obs_HR2_rS2);

CI_obs_FAR2_rS1(1,:) = ts(1).*(nanstd(MODEL.obs_FAR2_rS1)./sqrt(Nsub));
CI_obs_FAR2_rS1(2,:) = ts(2).*(nanstd(MODEL.obs_FAR2_rS1)./sqrt(Nsub));
CI_obs_HR2_rS1(1,:) = ts(1).*(nanstd(MODEL.obs_HR2_rS1)./sqrt(Nsub));
CI_obs_HR2_rS1(2,:) = ts(2).*(nanstd(MODEL.obs_HR2_rS1)./sqrt(Nsub));
CI_obs_FAR2_rS2(1,:) = ts(1).*(nanstd(MODEL.obs_FAR2_rS2)./sqrt(Nsub));
CI_obs_FAR2_rS2(2,:) = ts(2).*(nanstd(MODEL.obs_FAR2_rS2)./sqrt(Nsub));
CI_obs_HR2_rS2(1,:) = ts(1).*(nanstd(MODEL.obs_HR2_rS2)./sqrt(Nsub));
CI_obs_HR2_rS2(2,:) = ts(2).*(nanstd(MODEL.obs_HR2_rS2)./sqrt(Nsub));

mean_est_FAR2_rS1 = nanmean(MODEL.est_FAR2_rS1);
mean_est_HR2_rS1 = nanmean(MODEL.est_HR2_rS1);
mean_est_FAR2_rS2 = nanmean(MODEL.est_FAR2_rS2);
mean_est_HR2_rS2 = nanmean(MODEL.est_HR2_rS2);

CI_est_FAR2_rS1(1,:) = ts(1).*(nanstd(MODEL.est_FAR2_rS1)./sqrt(Nsub));
CI_est_FAR2_rS1(2,:) = ts(2).*(nanstd(MODEL.est_FAR2_rS1)./sqrt(Nsub));
CI_est_HR2_rS1(1,:) = ts(1).*(nanstd(MODEL.est_HR2_rS1)./sqrt(Nsub));
CI_est_HR2_rS1(2,:) = ts(2).*(nanstd(MODEL.est_HR2_rS1)./sqrt(Nsub));
CI_est_FAR2_rS2(1,:) = ts(1).*(nanstd(MODEL.est_FAR2_rS2)./sqrt(Nsub));
CI_est_FAR2_rS2(2,:) = ts(2).*(nanstd(MODEL.est_FAR2_rS2)./sqrt(Nsub));
CI_est_HR2_rS2(1,:) = ts(1).*(nanstd(MODEL.est_HR2_rS2)./sqrt(Nsub));
CI_est_HR2_rS2(2,:) = ts(2).*(nanstd(MODEL.est_HR2_rS2)./sqrt(Nsub));

%% Observed and expected type 2 ROCs for S1 and S2 responses
subplot(1,2,1);
errorbar([1 mean_obs_FAR2_rS1 0], [1 mean_obs_HR2_rS1 0], [0 CI_obs_HR2_rS1(1,:) 0], [0 CI_obs_HR2_rS1(2,:) 0], ...
    [0 CI_obs_FAR2_rS1(1,:) 0], [0 CI_obs_FAR2_rS1(2,:) 0], 'ko-','linewidth',1.5,'markersize', 12);
hold on
errorbar([1 mean_est_FAR2_rS1 0], [1 mean_est_HR2_rS1 0], [0 CI_est_HR2_rS1(1,:) 0], [0 CI_est_HR2_rS1(2,:) 0], ...
    [0 CI_est_FAR2_rS1(1,:) 0], [0 CI_est_FAR2_rS1(2,:) 0], 'd-','color',[0.5 0.5 0.5], 'linewidth',1.5,'markersize',10);
set(gca, 'XLim', [0 1], 'YLim', [0 1], 'FontSize', 16);
ylabel('HR2');
xlabel('FAR2');
line([0 1],[0 1],'linestyle','--','color','k');
axis square
box off
legend('Data', 'Model', 'Location', 'SouthEast')
legend boxoff
title('Response = S1')

subplot(1,2,2);
errorbar([1 mean_obs_FAR2_rS2 0], [1 mean_obs_HR2_rS2 0], [0 CI_obs_HR2_rS2(1,:) 0], [0 CI_obs_HR2_rS2(2,:) 0], ...
    [0 CI_obs_FAR2_rS2(1,:) 0], [0 CI_obs_FAR2_rS2(2,:) 0], 'ko-','linewidth',1.5,'markersize', 12);
hold on
errorbar([1 mean_est_FAR2_rS2 0], [1 mean_est_HR2_rS2 0], [0 CI_est_HR2_rS2(1,:) 0], [0 CI_est_HR2_rS2(2,:) 0], ...
    [0 CI_est_FAR2_rS2(1,:) 0], [0 CI_est_FAR2_rS2(2,:) 0], 'd-','color',[0.5 0.5 0.5], 'linewidth',1.5,'markersize',10);
set(gca, 'XLim', [0 1], 'YLim', [0 1], 'FontSize', 16);
ylabel('HR2');
xlabel('FAR2');
line([0 1],[0 1],'linestyle','--','color','k');
axis square
box off
legend('Data', 'Model', 'Location', 'SouthEast')
legend boxoff
title('Response = S2')

fig3 = figure; %%fig 3c

baseDir =  ['~' fs 'Dropbox' fs 'MetaMenta' fs 'Data' fs 'Exp2' fs];
setwd(baseDir)
color_TOM = {[0.917, 0.341, 0.427], [0.141, 0.737, 0.698]};%http://doc.instantreality.org/tools/color_calculator/
cnt_dat = readtable('regression_betas_lmenta.csv');
asd_dat = readtable('regression_betas_hmenta.csv');

hold all
plot(1, asd_dat{2,2}, 'd', 'MarkerSize', ms, 'MarkerFaceColor', color_TOM{1}, 'LineWidth', 3, 'MarkerEdgeColor', color_TOM{1})
plot(2, cnt_dat{2,2}, 'o', 'MarkerSize', ms, 'MarkerFaceColor', color_TOM{2}, 'LineWidth', 3, 'MarkerEdgeColor', color_TOM{2})

errorbar(1:2, [asd_dat{2,2} cnt_dat{2,2}], [asd_dat{4,2}./sqrt(40) cnt_dat{4,2}./sqrt(40)], '.', 'Color', 'k', 'LineWidth', 2);
hline1 = line([0 22], [0,0], 'linestyle', '-', 'color', [0 0 0], 'linewidth', 0.7); %zeroline
set(gca, 'XLim', [0 3], 'XTick', 1:2, 'YLim', [-0.6 0.1],'YTick', -0.6:0.2:0.1, 'FontSize',axis_nr, 'XTickLabels', {'low', 'high'});
ylabel([{'logRT impact'};{'on confidence (a.u.)'}], 'FontSize', axis_text);
xlabel('mentalizing efficiency', 'Fontsize', axis_text);
set(gcf, 'color', 'w')


end
