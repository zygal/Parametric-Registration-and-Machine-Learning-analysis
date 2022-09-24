addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/mutils/My/'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/ptv'));

fixed_folder = '/home/saradh/Desktop/Thesis/matlab/first_visit/ref_fv/ref_female';
mov_folder = '/home/saradh/Desktop/Thesis/matlab/first_visit';
results = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/female_res/test';

filename = fullfile(results);


[X_f, META1] = nrrdread([fixed_folder,'/4286351_F.nrrd']);
[X_w, META2] = nrrdread([fixed_folder,'/4286351_W.nrrd']);
volfix = cat(4,X_f,X_w);

maskfix = readVTK([fixed_folder,'/4286351_mask.vtk']);
maskfix = permute(maskfix, [2, 1, 3]);
maskfix = im2double(maskfix);


m_fat_folder = [mov_folder,'/female_fat'];
m_water_folder = [mov_folder,'/female_water'];
m_mask_folder = [mov_folder,'/female_masks'];





%f_fat_files = dir(fullfile(f_fat_folder, '*.nrrd'));
%f_water_files = dir(fullfile(f_water_folder, '*.nrrd'));
%f_mask_files = dir(fullfile(f_mask_folder, '*.vtk'));
m_fat_files = dir(fullfile(m_fat_folder, '*.nrrd'));
%m_water_files = dir(fullfile(m_water_folder, '*.nrrd'));
%m_mask_files = dir(fullfile(m_mask_folder, '*.vtk'));



total_images = numel(m_fat_files);

reg_val = [0.5, 0.8];

for n = 101: 103
    mp = split(m_fat_files(n).name, '_');
    mp{1};

    %f_fat_folder = 'D:/Matlab/first_visit/female_fat';
    % To get all the files in that directory and with desired file name pattern.
    Allfiles_Exp = dir(fullfile(m_fat_folder, ['*',mp{1},'*']));
    for z = 1:length(Allfiles_Exp)
        g = split(Allfiles_Exp.name, '_');
        g{1};

        m_fat_file = fullfile(m_fat_folder, strcat(Allfiles_Exp(z).name));
        disp(m_fat_file)

        m_water_file = fullfile(m_water_folder, strcat(g{1},'_W.nrrd'));
        disp(m_water_file)

        m_mask_file = fullfile(m_mask_folder, strcat(g{1},'_mask.vtk'));
        disp(m_mask_file)

        [Y_f, META3] = nrrdread(m_fat_file);
        [Y_w, META4] = nrrdread(m_water_file);
        volmov = cat(4,Y_f,Y_w);


        maskmov = readVTK(m_mask_file);
        maskmov = permute(maskmov, [2, 1, 3]);
        maskmov = im2double(maskmov);

        niftiwrite(volfix, [filename,'/', g{1}, '_mov.nii'], 'Compressed',true);

         fprintf(' ----------%d. Outer Loop ----------\n',n)

    for k = 1: numel(reg_val)

        iso_val = round(reg_val(k), 2);
        iso_val_str = string(round(iso_val, 2));
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

        %fprintf(' ----------%.1f Iso changed----------\n',reg_val(k))

        %fprintf(' ----------%d. Inner Registration Started----------\n',k)
        tic
        [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
        toc
        %fprintf(' ----------%d. Inner Registration Ended----------\n',k)


        err = immse(volfix, voldef_pl);
        err_rmse = sqrt(err);
        %fprintf('\n%0.4f\n', err_rmse);
        rmse_manual = sqrt(sum((volfix(:)-voldef_pl(:)).^2)/numel(volfix));
        %fprintf('\n%0.4f\n', rmse_manual);

        fprintf(' ----------%d. Writing RMSE----------\n',k)
        dataset_file = fullfile(results, '/RMSE_low_reg.txt');
        r =  readtable(dataset_file);
        C = {string(g{1}),round(err_rmse,3), iso_val};
        T = cell2table(C,'VariableNames',{'SUBJECT','RMSE', 'ISO'});
        Tout = [r;T];
        writetable(Tout, dataset_file);


        fprintf(' ----------%d. Saving files----------\n',k)
        niftiwrite(voldef_pl, [filename,'/', g{1}, '_iso', fin_str, '_reg.nii'], 'Compressed',true);
        niftiwrite(Tmin_pl, [filename,'/', g{1}, '_iso', fin_str, '_tmin_pl.nii'], 'Compressed',true);

    end

    end

fprintf(' ----------%d. REGISTRATION SUCCESSFUL----------\n',n)
end
