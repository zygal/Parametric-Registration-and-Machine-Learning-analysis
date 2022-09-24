addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/mutils/My/'));
addpath(genpath('Desktop/Thesis/matlab/pTVreg-master/pTVreg-master/ptv'));

fixed_folder = '/mnt/asgard1/data/saradh/first_visit';
mov_folder = '/mnt/asgard1/data/saradh/second_visit';

f_fat_folder = [fixed_folder,'/female_fat'];
f_water_folder = [fixed_folder,'/female_water'];
f_mask_folder = [fixed_folder,'/female_masks'];

m_fat_folder = [mov_folder,'/female_fat'];
m_water_folder = [mov_folder,'/female_water'];
m_mask_folder = [mov_folder,'/female_masks'];


results = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/female_res/repr';


f_fat_files = dir(fullfile(f_fat_folder, '*.nrrd'));
%f_water_files = dir(fullfile(f_water_folder, '*.nrrd'));
%f_mask_files = dir(fullfile(f_mask_folder, '*.vtk'));
%m_fat_files = dir(fullfile(m_fat_folder, '*.nrrd'));
%m_water_files = dir(fullfile(m_water_folder, '*.nrrd'));
%m_mask_files = dir(fullfile(m_mask_folder, '*.vtk'));



total_images = numel(f_fat_files);

for n = 105: 108
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



        opts = [];
        %opts.metric = 'loc_cc_fftn_gpu';
        opts.metric = 'ssd';
        opts.grid_spacing = [4, 4, 4];
        opts.display = 'off';
        opts.max_iters = 50;
        opts.metric_param = 2.5 * [1,1,1];
        opts.interp_type = 1;
        opts.spline_order = 1;
        opts.isoTV = 0.1;
        opts.loc_cc_approximate = true;
        opts.border_mask = 1;
        opts.k_down = 0.7;
        opts.check_gradients = 100*0;
        opts.fixed_mask = maskfix;
        opts.moving_mask = maskmov;
        %opts.border_mask = 3;


        fprintf(' ----------%d. Inner Registration Started----------\n',n)
        tic
        [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
        toc
        fprintf(' ----------%d. Inner Registration Ended----------\n',n)

        filename = fullfile(results);

        err = immse(volfix, voldef_pl);
        err_rmse = sqrt(err);
        fprintf('\n%0.4f\n', err_rmse);
        rmse_manual = sqrt(sum((volfix(:)-voldef_pl(:)).^2)/numel(volfix));
        fprintf('\n%0.4f\n', rmse_manual);

        fprintf(' ----------%d. Writing RMSE----------\n',n)
        dataset_file = fullfile(results, '/RMSE_intra_repr.txt');
        r =  readtable(dataset_file);
        C = {string(g{1}),round(err_rmse,3)};
        T = cell2table(C,'VariableNames',{'SUBJECT','RMSE'});
        Tout = [r;T];
        writetable(Tout, dataset_file);



        fprintf(' ----------%d. Saving files----------\n',n)
        niftiwrite(voldef_pl, [filename,'/', g{1}, '_intra_reg.nii'], 'Compressed',true);




    end

fprintf(' ----------%d. REGISTRATION SUCCESSFUL----------\n',n)
end




