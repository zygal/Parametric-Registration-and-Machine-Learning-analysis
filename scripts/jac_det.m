addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));

main_folder = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/female_res/low_reg';

m_det_files = dir(fullfile(main_folder, '*.mat'));


dataset_file = fullfile(main_folder, '/RMSE_low_reg.txt');
r =  readtable(dataset_file);
r.Var4(1,1) = 0;
r.Properties.VariableNames{4} = 'Det_Err';
r.Var5(1,1) = 0;
r.Properties.VariableNames{5} = 'Det_Min';
r.Var6(1,1) = 0;
r.Properties.VariableNames{6} = 'Det_Max';

disp(numel(m_det_files))

for n = 1:numel(m_det_files)
    fprintf('---%d inner loop---\n',n)
    sub = load(fullfile(main_folder, m_det_files(n).name));

    val = std2(sub.determinants);

    srss = sqrt(sum(sub.determinants(:).^2)/numel(sub.determinants));

    mean_det = mean(sub.determinants(:))

    min_det = min(sub.determinants(:));
    max_det = max(sub.determinants(:));

    r.Det_Err(n) = round(srss,4);
    r.Det_Min(n) = round(min_det, 4);
    r.Det_Max(n) = round(max_det, 4);

end


for j = 1:3:numel(m_det_files)
    fprintf('---%d saving---\n',j)
    isoTV = r.ISO(j:j+2);
    rms_p = r.RMSE(j:j+2);
    rms_n = normalize(rms_p, 'range',  [0 100]);
    det_p = r.Det_Err(j:j+2);
    det_n = normalize(det_p, 'range',  [0 100]);


    % Plotting and saving
    f = figure('visible', 'off');
    plot(isoTV, det_n);
    set(gca, 'XTick',isoTV, 'FontSize',7)
    xlabel('isoTV')
    grid on
    hold on
    plot(isoTV, rms_n);
    legend('det-srss','rmse')
    title([m_det_files(j).name,' Inter RMSE vs Det-err tradeoff'])
    hold off
    % Saving
    g = split(m_det_files(j).name, '_tmin');
    file_name = fullfile(main_folder, [g{1},'crossPlot',num2str(j)]);
    file_name2 = fullfile(main_folder, [g{1},'yyPlot',num2str(j)]);
    saveas(f,[file_name,'.jpg'])
    close(f)


    t = figure('visible', 'off');
    set(gca, 'XTick',isoTV, 'FontSize',7)
    yyaxis left
    plot(det_p)
    grid on
    yyaxis right
    plot(rms_p)

    yyaxis left
    title([m_det_files(j).name,' Inter RMSE vs Det-err tradeoff'])
    xlabel('isoTV from 0.1 to 0.8')
    ylabel('Det-Err')
    yyaxis right
    ylabel('RMSE')

    saveas(t,[file_name2,'.jpg'])
    close(t)

end

dataset_file_wr = fullfile(main_folder, '/RMSE_low_reg_inter_det.txt');
writetable(r, dataset_file_wr);

fprintf(' ----------Done----------\n')
