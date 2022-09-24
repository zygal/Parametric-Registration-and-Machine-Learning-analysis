addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/mutils/My/'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/ptv'));

fixed_folder = '/home/saradh/Desktop/Thesis/matlab/first_visit';
mov_folder = '/home/saradh/Desktop/Thesis/matlab/second_visit';

f_fat_folder = [fixed_folder,'/sample/fat_channel'];
f_water_folder = [fixed_folder,'/sample/water_channel'];
f_mask_folder = [fixed_folder,'/sample/body_mask_fv'];

m_fat_folder = [mov_folder,'/sample/fat_channel'];
m_water_folder = [mov_folder,'/sample/water_channel'];
m_mask_folder = [mov_folder,'/sample/body_mask_sv'];

results = [fixed_folder,'/sample/post_reg'];


f_fat_files = dir(fullfile(f_fat_folder, '*.nrrd'));
f_mask_files = dir(fullfile(f_mask_folder, '*.vtk'));
m_fat_files = dir(fullfile(m_fat_folder, '*.nrrd'));
m_mask_files = dir(fullfile(m_mask_folder, '*.vtk'));


total_images = numel(f_fat_files);

reg_val = [0.1, 0.2, 0.3, 0.4, 0.5, 0.8, 1];

for n = 1: total_images

    fixed = fullfile(f_fat_folder, f_fat_files(n).name);
    [X_f, META1] = nrrdread(fixed);
    volfix = X_f;

    moving = fullfile(m_fat_folder, m_fat_files(n).name);
    [Y_f, META2] = nrrdread(moving);
    volmov = Y_f;

    maskfix = fullfile(f_mask_folder, f_mask_files(n).name);
    maskfix = readVTK(maskfix);
    maskfix = permute(maskfix, [2, 1, 3]);
    maskfix = im2double(maskfix);

    maskmov = fullfile(m_mask_folder, m_mask_files(n).name);
    maskmov = readVTK(maskmov);
    maskmov = permute(maskmov, [2, 1, 3]);
    maskmov = im2double(maskmov);

    fprintf(' ----------%d. Outer Loop ----------\n',n)

    for k = 1: numel(reg_val)

        iso_val = round(reg_val(k), 2);
        iso_val_str = string(round(iso_val, 1));
        isoStr = strrep(iso_val_str,'.','');
        fin_str = str2double(isoStr);
        fin_str = num2str(fin_str);


        opts = [];
        %opts.metric = 'loc_cc_fftn_gpu';
        opts.metric = 'ssd';
        opts.grid_spacing = [4, 4, 4];
        opts.display = 'off';
        opts.max_iters = 50;
        opts.metric_param = 2.5 * [1,1,1];
        opts.interp_type = 1;
        opts.spline_order = 1;
        %opts.isoTV = 0.11;
        opts.isoTV = iso_val;
        opts.loc_cc_approximate = true;
        opts.border_mask = 1;
        opts.k_down = 0.7;
        opts.check_gradients = 100*0;
        opts.fixed_mask = maskfix;
        opts.moving_mask = maskmov;
        %opts.border_mask = 3;


        fprintf(' ----------%.1f Iso changed----------\n',reg_val(k))

        fprintf(' ----------%d. Inner Registration Started----------\n',k)
        tic
        [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
        toc
        fprintf(' ----------%d. Inner Registration Ended----------\n',k)

        g = split(f_fat_files(n).name, '_');
        filename = fullfile(results);

        err = immse(volfix, voldef_pl);
        err_rmse = sqrt(err);
        fprintf('\n%0.4f\n', err_rmse);
        rmse_manual = sqrt(sum((volfix(:)-voldef_pl(:)).^2)/numel(volfix));
        fprintf('\n%0.4f\n', rmse_manual);

        fprintf(' ----------%d. Writing RMSE----------\n',k)
        dataset_file = fullfile(results, '/RMSE.txt');
        r =  readtable(dataset_file);
        C = {string(g{1}),round(err_rmse,3),iso_val};
        T = cell2table(C,'VariableNames',{'SUBJECT','RMSE', 'ISO'});
        Tout = [r;T];
        writetable(Tout, dataset_file);


        fprintf(' ----------%d. Saving files----------\n',k)
        %niftiwrite(voldef_pl, [filename,'/', g{1}, '_reg.nii'], 'Compressed',true);
        niftiwrite(Tmin_pl, [filename,'/', g{1}, '_iso0', fin_str, '_tmin_pl.nii'], 'Compressed',true);

    end

end
