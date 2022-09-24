addpath(genpath('../mutils/My/'));
addpath(genpath('../ptv'));

%%
fix_f = '2477703_W';
fix_w = '2477703_F';
mov_f = '2492841_W';
mov_w = '2492841_F';

fprintf('--------done----------\n');
%%
fix_mask = '2477703_mask';
mov_mask = '2492841_mask';

fprintf('--------done----------\n');
%%
[X_f, META1] = nrrdread(['first_visit/',fix_f,'.nrrd']);
[X_w, META2] = nrrdread(['first_visit/first_2/', fix_w, '.nrrd']);
[Y_f, META3] = nrrdread(['first_visit/', mov_f, '.nrrd']);
[Y_w, META4] = nrrdread(['first_visit/first_2/', mov_w ,'.nrrd']);


volfix = cat(4,X_f,X_w);
volmov = cat(4,Y_f,Y_w);

fprintf('--------done----------\n');
%%
maskfix = readVTK(['first_visit/body_mask_fv/', fix_mask ,'.vtk']);
maskfix = permute(maskfix, [2, 1, 3]);
maskfix = im2double(maskfix);

maskmov = readVTK(['first_visit/body_mask_fv/', mov_mask ,'.vtk']);
maskmov = permute(maskmov, [2, 1, 3]);
maskmov = im2double(maskmov);

fprintf('\n--------done----------\n');
%%
niftiwrite(volfix,[fix_f,'F_mu_fix.nii'], 'Compressed',true);
niftiwrite(volmov,[mov_f,'F_mu_mov.nii'], 'Compressed',true);

fprintf('\n--------done----------\n');
%%
opts = [];
%opts.metric = 'loc_cc_fftn_gpu';
opts.metric = 'ssd';
opts.grid_spacing = [4, 4, 4];
opts.display = 'off';
opts.max_iters = 50; 
opts.metric_param = 2.5 * [1,1,1]; 
opts.interp_type = 1;
opts.spline_order = 1;
opts.isoTV = 1;
opts.loc_cc_approximate = true;
opts.border_mask = 1;
opts.k_down = 0.7;
opts.check_gradients = 100*0;
opts.fixed_mask = maskfix;
opts.moving_mask = maskmov;
%opts.border_mask = 3;


%%
tic
[voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
toc

%% Write variables as nii

niftiwrite(Tmin_pl,[fix_f,'_',mov_f,'_iso08_tmin_pl.nii'], 'Compressed',true);

niftiwrite(voldef_pl,[fix_f,'_',mov_f,'_iso08_reg.nii'], 'Compressed',true);

fprintf('\n--------done----------\n');
%%

%% Difference and Misc

%difference = voldef_pl - volfix;

err = immse(volfix, voldef_pl);

fprintf('\n The mean-squared error is %0.4f\n', err);

err_rmse = sqrt(err);

fprintf(['\nRMSE for ',fix_f, '--',mov_f, ' when isoTV  is 0.8 %0.4f\n']);

fprintf('\n%0.4f\n', err_rmse);

rmse_manual = sqrt(sum((volfix(:)-voldef_pl(:)).^2)/numel(volfix));

fprintf('\n%0.4f\n', rmse_manual);

%% Save mats


%%
% Bar plot (RMSE)

y = [41.1413 25.3061 25.6412 32.5313 25.5089 40.1034 25.4858 28.9533];
bar(y)

%%


cdfplot(V.determinants)
hold on
x = linspace(min(V.determinants),max(V.determinants));
plot(x,evcdf(x,0,3))
legend('Empirical CDF','Theoretical CDF','Location','best')
hold off


%%

file_name = '2477703_W_2418642_W';

iso011 = load([file_name,'_iso011_tmin_pl.mat']);
iso025 = load([file_name,'_iso025_tmin_pl.mat']);
iso05 = load([file_name,'_iso05_tmin_pl.mat']);
iso08 = load([file_name,'_iso08_tmin_pl.mat']);
iso1 = load([file_name,'_iso1_tmin_pl.mat']);
iso15 = load([file_name,'_iso1.5_tmin_pl.mat']);
iso2 = load([file_name,'_iso2_tmin_pl.mat']);
%iso5 = load([file_name,'_iso5_tmin_pl.mat']);



histogram(iso080.determinants, 50);
title('new')

figure

histogram(iso5.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso2.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso15.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso1.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso08.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso05.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso025.determinants, (-0.5:0.02:0.5));
hold on
histogram(iso011.determinants, (-0.5:0.02:0.5));
legend('reg 5', 'reg 2','reg 1.5', 'reg 1', 'reg 0.8', 'reg 0.5', 'reg 0.25', 'reg 0.11')



% Standard deviation
val = std2(iso08.determinants)

srss = sqrt(sum(iso011.determinants(:).^2)/numel(iso08.determinants))

mean_det = mean(iso08.determinants(:))

min(iso08.determinants(:))

%sqrt(sum(iso2.determinants(:).^2))
%mean_det = mean(iso011.determinants(:))
%var = ((iso2.determinants(:) - mean_det).^2)/numel(iso2.determinants);
%sqrt(var)
%var(iso2.determinants)
%%

%Plots



det_srss = [7.57e+03,6.69e+03,5.87e+03,4.93e+03,4.52e+03,3.62e+03,3.19e+03,1.72e+03 ];

det_srss = normalize(det_srss,'range', [0 100]);

rmse = [51.4514, 57.6759, 62.8354, 62.6401, 64.4893, 68.7675, 68.8882, 76.5745];
rmse = normalize(rmse, 'range',  [0 100]);

isoTV = [0.11, 0.25, 0.5, 0.8, 1, 1.5, 2, 5];

y_val = linspace(0,20,21)*5;



figure 
plot(isoTV, det_srss)
set(gca, 'XTick',isoTV, 'FontSize',7)
xlabel('isoTV')
grid on
%ylim([-1 2.0])
%set(gca,'ytick',y_val)
hold on
plot(isoTV, rmse)
legend('det-srss','rmse')


figure
plot(rand(10,1))
yyaxis right
plot(rand(10,1))



%%


%
%[X, META1] = nrrdread('first_visit/4397818_F.nrrd');
%[Y, META2] = nrrdread('second_visit/4397818_F.nrrd');
%volmov = squeeze(X);
%volfix = squeeze(Y);

%[Y_f, META3] = nrrdread('second_visit/1733880_F.nrrd');
%[Y_w, META4] = nrrdread('second_visit/second_2/1733880_W.nrrd');


%X_f = squeeze(X_f);
%X_w = squeeze(X_w);
%Y_f = squeeze(Y_f);
%Y_w = squeeze(Y_w);


% 1715832_3046603
% Inter-patient
%[X, META5] = nrrdread('first_visit/1652017_F.nrrd');
%[Y, META6] = nrrdread('second_visit/3133117_F.nrrd');

%X = squeeze(X);
%Y = squeeze(Y);

%volfix = X;
%volmov = Y;

%%

fixed_folder = 'D:\Matlab\biobank\NRRD_SIGNALS_ONLY\first_visit';
mov_folder = 'D:\Matlab\biobank\NRRD_SIGNALS_ONLY\second_visit';

f_fat_folder = [fixed_folder,'\sample\fat_channel'];
f_water_folder = [fixed_folder,'\sample\water_channel'];
f_mask_folder = [fixed_folder,'\sample\body_mask_fv'];

m_fat_folder = [mov_folder,'\sample\fat_channel'];
m_water_folder = [mov_folder,'\sample\water_channel'];
m_mask_folder = [mov_folder,'\sample\body_mask_sv'];

results = [fixed_folder,'\sample\post_reg'];


f_fat_files = dir(fullfile(f_fat_folder, '*.nrrd'));
f_mask_files = dir(fullfile(f_mask_folder, '*.vtk'));
m_fat_files = dir(fullfile(m_fat_folder, '*.nrrd'));
m_mask_files = dir(fullfile(m_mask_folder, '*.vtk'));


total_images = numel(f_fat_files);

opts = [];

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
    
    if isempty(opts)
        opts = [];
        %opts.metric = 'loc_cc_fftn_gpu';
        opts.metric = 'ssd';
        opts.grid_spacing = [4, 4, 4];
        opts.display = 'off';
        opts.max_iters = 50; 
        opts.metric_param = 2.5 * [1,1,1]; 
        opts.interp_type = 1;
        opts.spline_order = 1;
        opts.isoTV = 1;
        opts.loc_cc_approximate = true;
        opts.border_mask = 1;
        opts.k_down = 0.7;
        opts.check_gradients = 100*0;
        opts.fixed_mask = maskfix;
        opts.moving_mask = maskmov;
        %opts.border_mask = 3;
    end
    
    fprintf(' ----------%d. Registration Started----------\n',1)
    tic
    [voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);
    toc
   fprintf(' ----------%d. Registration Ended----------\n',1)
     
    g = split(f_fat_files(n).name, '_');
    filename = fullfile(results);  
    
    fprintf(' ----------%d. Saving files----------\n',1)
    niftiwrite(voldef_pl, [filename,'\', g{1}, '_reg.nii'], 'Compressed',true);
    niftiwrite(Tmin_pl, [filename,'\', g{1}, '_tmin_pl.nii'], 'Compressed',true);
    
   
end

