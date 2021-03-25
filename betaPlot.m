function [h01] = betaPlot(exp)

%% Plot the beta coefficients
% EVDP 2019 elisa.plas.18@ucl.ac.uk

fs = filesep;
h01 = figure;
c.corr =  [0.082, 0.615, 0.835];
c.err = [0.835, 0.250, 0.082];

if exp == 1
    baseDir =  ['~' fs 'Dropbox' fs 'MetaMenta' fs 'Data' fs 'Exp1' fs];
    
    for acc = 1:2
        for ASD = 1:2
            
            correct = {'corr_'; 'err_'};
            ASDtrait = {'hASD'; 'lASD'};
            suffix = [correct{acc} ASDtrait{ASD}];
            
            %% Load betas
            cd(baseDir)
            datafile = [suffix '.csv'];
            dat{ASD, acc} = readtable(datafile);
        end
    end
    
    ms = 20;
    axis_text = 26;
    axis_nr = 18;
    hold all
    plot(1,  [dat{1,1}{2,2}] , 'd', 'MarkerSize', ms, 'MarkerFaceColor', c.corr, 'Linewidth', 3, 'MarkerEdgeColor', c.corr);
    plot(1,  [dat{1,2}{2,2}] , 'd', 'MarkerSize', ms, 'MarkerFaceColor', c.err, 'Linewidth', 3, 'MarkerEdgeColor', c.err);
    plot(2,  [dat{2,1}{2,2}] , 'o', 'MarkerSize', ms, 'MarkerFaceColor', c.corr,'Linewidth', 3, 'MarkerEdgeColor', c.corr);
    plot(2,  [dat{2,2}{2,2}] , 'o', 'MarkerSize', ms, 'MarkerFaceColor', c.err, 'Linewidth', 3, 'MarkerEdgeColor', c.err);
    errorbar(1:2, [dat{1,1}{2,2} dat{2,1}{2,2}], [dat{1,1}{4,2} dat{2,1}{4,2}], '.', 'Color', c.corr*0.2, 'LineWidth', 2);
    errorbar(1:2, [dat{1,2}{2,2} dat{2,2}{2,2}], [dat{1,2}{4,2} dat{2,2}{4,2}], '.', 'Color', c.err*0.2 , 'LineWidth', 2);
    
    hline1 = line([0 22], [0,0], 'linestyle', '-', 'color', [0 0 0], 'linewidth', 0.7); %zeroline
    set(gca, 'XLim', [0 3], 'XTick', 1:2, 'YLim', [-0.55 0.05],'YTick', -0.5:0.2:0.1, 'FontSize',axis_nr, 'XTickLabels', {'high RAADS', 'low RAADS'});
    ylabel([{'logRT impact'};{'on confidence (a.u.)'}], 'FontSize', axis_text);
    set(gcf, 'color', 'w')
    
else
    
    baseDir =  ['~' fs 'Dropbox' fs 'MetaMenta' fs 'Data' fs 'Exp2' fs];
    filename = 'regression_betas_'; %'HierarchicalRegression_exp2.r'
    
    for acc = 1:2
        for ASD = 1:2
            correct = {'_corr'; '_err'};
            clinical = {'ASD'; 'CTL'};
            suffix = [clinical{ASD} correct{acc}];
            
            %% Load betas
            cd(baseDir)
            datafile = [filename suffix '.csv'];
            dat{ASD, acc} = readtable(datafile);
        end
    end
    
    ms = 20;
    axis_text = 26;
    axis_nr = 18;
    hold all
    plot(1,  [dat{1,1}{2,2}] , 'd', 'MarkerSize', ms, 'MarkerFaceColor', c.corr,'Linewidth', 3, 'MarkerEdgeColor', c.corr);
    plot(1,  [dat{1,2}{2,2}] , 'd', 'MarkerSize', ms, 'MarkerFaceColor', c.err, 'Linewidth', 3, 'MarkerEdgeColor', c.err);
    plot(2,  [dat{2,1}{2,2}] , 'o', 'MarkerSize', ms, 'MarkerFaceColor', c.corr,'Linewidth', 3, 'MarkerEdgeColor', c.corr);
    plot(2,  [dat{2,2}{2,2}] , 'o', 'MarkerSize', ms, 'MarkerFaceColor', c.err, 'Linewidth', 3, 'MarkerEdgeColor', c.err);
    errorbar(1:2, [dat{1,1}{2,2} dat{2,1}{2,2}], [dat{1,1}{2,2}./sqrt(80) dat{2,1}{2,2}./sqrt(80)], '.', 'Color', c.corr*0.2, 'LineWidth', 2);
    errorbar(1:2, [dat{1,2}{2,2} dat{2,2}{2,2}], [dat{1,2}{2,2}./sqrt(80) dat{2,2}{2,2}./sqrt(80)], '.', 'Color', c.err*0.2 , 'LineWidth', 2);
    
    hline1 = line([0 22], [0,0], 'linestyle', '-', 'color', [0 0 0], 'linewidth', 0.7); %zeroline
    set(gca, 'XLim', [0 3], 'XTick', 1:2, 'YLim', [-0.5 0.1],'YTick', -0.5:0.2:0.1, 'FontSize',axis_nr, 'XTickLabels', {'ASD', 'comparison'});
    ylabel([{'logRT impact'};{'on confidence (a.u.)'}], 'FontSize', axis_text);
    set(gcf, 'color', 'w')
    
end
end
