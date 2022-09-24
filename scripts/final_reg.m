addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/mutils/My/'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/ptv'));




ref_folder = fullfile('/home/saradh/Desktop/Thesis/matlab/first_visit/ref_fv/ref_female');

fixed_folder = fullfile('/home/saradh/Desktop/Thesis/matlab/first_visit');
mov_folder = fullfile('/home/saradh/Desktop/Thesis/matlab/second_visit');

results = fullfile('/home/saradh/Desktop/Thesis/matlab/results/final_results/female');
filename = fullfile(results);


[rX_f, rMETA1] = nrrdread([ref_folder,'\2418642_F.nrrd']);
[rX_w, rMETA2] = nrrdread([ref_folder,'\2418642_W.nrrd']);
rvolfix = cat(4,rX_f,rX_w);

rmaskfix = readVTK([ref_folder, '\4286351_mask.vtk']);
rmaskfix = permute(rmaskfix, [2, 1, 3]);
rmaskfix = im2double(rmaskfix);



f_fat_folder = fullfile([fixed_folder,'/female_fat']);
f_water_folder = fullfile([fixed_folder,'/female_water']);
f_mask_folder = fullfile([fixed_folder,'/female_masks']);

m_fat_folder = fullfile([mov_folder,'/female_fat']);
m_water_folder = fullfile([mov_folder,'/female_water']);
m_mask_folder = fullfile([mov_folder,'/female_masks']);





f_fat_files = dir(fullfile(f_fat_folder, '*.nrrd'));
%f_water_files = dir(fullfile(f_water_folder, '*.nrrd'));
%f_mask_files = dir(fullfile(f_mask_folder, '*.vtk'));
%m_fat_files = dir(fullfile(m_fat_folder, '*.nrrd'));
%m_water_files = dir(fullfile(m_water_folder, '*.nrrd'));
%m_mask_files = dir(fullfile(m_mask_folder, '*.vtk'));



total_images = numel(f_fat_files);

reg_val = [0.5, 0.8];

for n = 3:3
    mp = split(f_fat_files(n).name, '_');
    mp{1};

    %f_fat_folder = 'D:/Matlab/first_visit/female_fat';
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

       % niftiwrite(volfix, [filename,'/', g{1}, '_mov.nii'], 'Compressed',true);

         fprintf(' ----------%d. Outer Loop ----------\n',n)

    %for k = 1: numel(reg_val)


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



        %fprintf(' ----------%.1f Iso changed----------\n',reg_val(k))

        %fprintf(' ----------%d. Inner Registration Started----------\n',k)
        tic
         fprintf(' ----------%d. Intra-patient Registration----------\n',n)
       % [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
        toc
        %fprintf(' ----------%d. Inner Registration Ended----------\n',k)

        fprintf(' ----------%d. Intra-patient fat diff----------\n',n)


        fprintf(' ----------%d. Inter - patient Registration----------\n',n)

        opts_inter = [];
        %opts.metric = 'loc_cc_fftn_gpu';
        opts.metric = 'ssd';
        opts.grid_spacing = [4, 4, 4];
        opts.display = 'off';
        opts.max_iters = 50;
        opts.metric_param = 2.5 * [1,1,1];
        opts.interp_type = 1;
        opts.spline_order = 1;
        %opts.isoTV = 0.11;
        opts.isoTV = 0.8;
        opts.loc_cc_approximate = true;
        opts.border_mask = 1;
        opts.k_down = 0.7;
        opts.check_gradients = 100*0;
        opts.fixed_mask = rmaskfix;
        opts.moving_mask = maskmov;

        tic
         fprintf(' ----------%d. Inter-patient Registration----------\n',n)
       % [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
        toc


        fprintf(' ----------%d. warped ref_fat----------\n',n)

        fprintf(' ----------%d. compute moving average----------\n',n)

        fprintf(' ----------%d. saving files----------\n',n)



        %err = immse(volfix, voldef_pl);
        %err_rmse = sqrt(err);
        %fprintf('\n%0.4f\n', err_rmse);
        %rmse_manual = sqrt(sum((volfix(:)-voldef_pl(:)).^2)/numel(volfix));
        %fprintf('\n%0.4f\n', rmse_manual);

        fprintf(' ----------%d. Writing RMSE----------\n',n)
        %dataset_file = fullfile(results, '/RMSE_low_reg.txt');
        %r =  readtable(dataset_file);
        %C = {string(g{1}),round(err_rmse,3), iso_val};
        %T = cell2table(C,'VariableNames',{'SUBJECT','RMSE', 'ISO'});
        %Tout = [r;T];
        %writetable(Tout, dataset_file);


        fprintf(' ----------%d. Saving files----------\n',n)
        %niftiwrite(voldef_pl, [filename,'/', g{1}, '_iso', fin_str, '_reg.nii'], 'Compressed',true);
        %niftiwrite(Tmin_pl, [filename,'/', g{1}, '_iso', fin_str, '_tmin_pl.nii'], 'Compressed',true);

    %end

    end

fprintf(' ----------%d. REGISTRATION SUCCESSFUL----------\n',n)
end
