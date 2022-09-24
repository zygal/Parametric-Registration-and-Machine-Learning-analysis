addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/mutils/My/'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/ptv'));




ref_folder = fullfile('/home/saradh/Desktop/Thesis/matlab/first_visit/ref_fv/ref_male');

fixed_folder = fullfile('/home/saradh/Desktop/Thesis/matlab/first_visit');
mov_folder = fullfile('/home/saradh/Desktop/Thesis/matlab/second_visit');

results = fullfile('/home/saradh/Desktop/Thesis/matlab/results/final_results/male');
filename = fullfile(results);

[rX_f, META1] = nrrdread([ref_folder,'/3555525_F.nrrd']);
[rX_w, META2] = nrrdread([ref_folder,'/3555525_W.nrrd']);
rvolfix = cat(4,rX_f,rX_w);

rmaskfix = readVTK([ref_folder,'/3555525_mask.vtk']);
rmaskfix = permute(rmaskfix, [2, 1, 3]);
rmaskfix = im2double(rmaskfix);


f_fat_folder = fullfile([fixed_folder,'/male_fat']);
f_water_folder = fullfile([fixed_folder,'/male_water']);
f_mask_folder = fullfile([fixed_folder,'/male_masks']);

m_fat_folder = fullfile([mov_folder,'/male_fat']);
m_water_folder = fullfile([mov_folder,'/male_water']);
m_mask_folder = fullfile([mov_folder,'/male_masks']);



f_fat_files = dir(fullfile(f_fat_folder, '*.nrrd'));
%f_water_files = dir(fullfile(f_water_folder, '*.nrrd'));
%f_mask_files = dir(fullfile(f_mask_folder, '*.vtk'));
%m_fat_files = dir(fullfile(m_fat_folder, '*.nrrd'));
%m_water_files = dir(fullfile(m_water_folder, '*.nrrd'));
%m_mask_files = dir(fullfile(m_mask_folder, '*.vtk'));


D0_fat = zeros(174, 224, 362);

total_images = numel(f_fat_files);

for n = 1:total_images


    fprintf(' ----------%d. Outer Loop ----------\n',n)
    mp = split(f_fat_files(n).name, '_');
    mp{1};

    % To get all the files in that directory and with desired file name pattern.
     Allfiles_Exp = dir(fullfile(f_fat_folder, ['*',mp{1},'*']));
    for z = 1:length(Allfiles_Exp)
        g = split(Allfiles_Exp.name, '_');
        g{1};

        f_fat_file = fullfile(f_fat_folder, Allfiles_Exp(z).name);
        disp(f_fat_file);

        f_water_file = fullfile(f_water_folder, strcat(g{1},'_W.nrrd'));
        disp(f_water_file)

        f_mask_file = fullfile(f_mask_folder, strcat(g{1},'_mask.vtk'));
        disp(f_mask_file)

        m_fat_file = fullfile(m_fat_folder, strcat(Allfiles_Exp(z).name));
        disp(m_fat_file)

        m_water_file = fullfile(m_water_folder, strcat(g{1},'_W.nrrd'));
        disp(m_water_file)

        m_mask_file = fullfile(m_mask_folder, strcat(g{1},'_mask.vtk'));
        disp(m_mask_file)


        [X_f, META1] = nrrdread(f_fat_file);
        [X_w, META2] = nrrdread(f_water_file);
        volfix = cat(4,X_f,X_w);

        [Y_f, META3] = nrrdread(m_fat_file);
        [Y_w, META4] = nrrdread(m_water_file);
        volmov = cat(4,Y_f,Y_w);

        maskfix = readVTK(f_mask_file);
        maskfix = permute(maskfix, [2, 1, 3]);
        maskfix = im2double(maskfix);

        maskmov = readVTK(m_mask_file);
        maskmov = permute(maskmov, [2, 1, 3]);
        maskmov = im2double(maskmov);


        fprintf(' ----------%d. Intra-patient Registration----------\n',n)
        opts = [];
        opts.metric = 'ssd';
        opts.grid_spacing = [4, 4, 4];
        opts.display = 'off';
        opts.max_iters = 50;
        opts.metric_param = 2.5 * [1,1,1];
        opts.interp_type = 1;
        opts.spline_order = 1;
        %opts.isoTV = 0.11;
        opts.isoTV = 0.1;
        opts.loc_cc_approximate = true;
        opts.border_mask = 1;
        opts.k_down = 0.7;
        opts.check_gradients = 100*0;
        opts.fixed_mask = maskfix;
        opts.moving_mask = maskmov;

        %iso_val = round(reg_val(k), 2);
        %iso_val_str = string(round(iso_val, 2));
        %isoStr = strrep(iso_val_str,'.','');
        %fin_str = str2double(isoStr);
        fin_str = num2str(opts.isoTV);



        tic
       [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
        toc

        fprintf(' ----------%d. Computing fat difference----------\n',n)

        fat_diff = (voldef_pl(:,:,[1:362]) - volfix(:,:,[1:362]));

        niftiwrite(fat_diff,  [filename,'/', g{1},'_fat_diff.nii'], 'Compressed',true);

        fprintf(' ----------%d. Inter - patient Registration----------\n',n)

        opts_inter = [];
        opts_inter.metric = 'ssd';
        opts_inter.grid_spacing = [4, 4, 4];
        opts_inter.display = 'off';
        opts_inter.max_iters = 50;
        opts_inter.metric_param = 2.5 * [1,1,1];
        opts_inter.interp_type = 1;
        opts_inter.spline_order = 1;
        opts_inter.isoTV = 0.8;
        opts_inter.loc_cc_approximate = true;
        opts_inter.border_mask = 1;
        opts_inter.k_down = 0.7;
        opts_inter.check_gradients = 100*0;
        opts_inter.fixed_mask = rmaskfix;
        opts_inter.moving_mask = maskmov;

        tic
        [voldef_i, Tmin_i, Kmin_i] = ptv_register(volfix, rvolfix, opts_inter);
        toc

        fprintf(' ----------%d. warped ref_fat----------\n',n)
        fat_diff_wp = ptv_deform(fat_diff, Tmin_i);
        niftiwrite(fat_diff_wp, [filename,'/', g{1},'_fat_diff_wp.nii'], 'Compressed',true);
        fprintf(' ----------%d. computing moving sum----------\n',n)
        D0_fat = D0_fat + fat_diff_wp;
        niftiwrite(D0_fat, [filename,'/', 'moving_sum.nii'], 'Compressed',true);


        err = immse(volfix, voldef_pl);
        err_rmse = sqrt(err);
        fprintf('\n%0.4f\n', err_rmse);

        err_int = immse(rvolfix, voldef_i);
        err_rmse_int = sqrt(err_int);
        fprintf('\n%0.4f\n', err_rmse_int);

        fprintf(' ----------%d. Writing RMSE----------\n',n)
        dataset_file = fullfile(results, '/RMSE.txt');
        r =  readtable(dataset_file);
        C = {string(g{1}),round(err_rmse,3), 0.1};
        T = cell2table(C,'VariableNames',{'SUBJECT','RMSE', 'ISO'});
        Tout = [r;T];
        writetable(Tout, dataset_file);

        dataset_file = fullfile(results, '/RMSE_inter.txt');
        r =  readtable(dataset_file);
        C = {string(g{1}),round(err_rmse_int,3), 0.8};
        T = cell2table(C,'VariableNames',{'SUBJECT','RMSE', 'ISO'});
        Tout = [r;T];
        writetable(Tout, dataset_file);


        fprintf(' ----------%d. Saving files----------\n',n)
        niftiwrite(Tmin_pl, [filename,'/', g{1}, '_intra_tmin_pl.nii'], 'Compressed',true);
        niftiwrite(Tmin_i, [filename,'/', g{1}, '_inter_tmin_pl.nii'], 'Compressed',true);



    end

    fprintf(' ----------%d. REGISTRATION SUCCESSFUL----------\n',n)
end


fat_diff_avg = D0_fat / numel(D0_fat);
niftiwrite(fat_diff_avg, [filename,'/', 'final_fat_diff_avg.nii'], 'Compressed',true);
