addpath(genpath('/home/saradh/Desktop/Thesis/matlab'));


% Main folder path
main_folder = fullfile('/mnt/asgard1/data/saradh/results/final_results/male');

% Read the kidney mask file
kidney_mask = ~~nrrdread('/home/saradh/Desktop/Thesis/matlab/first_visit/ref_fv/kidney_mask/3555525_out.nrrd');

% Read the final avg file from the registrations
final_fat_diff_avg = niftiread('/mnt/asgard1/data/saradh/results/final_results/male/final_fat_diff_avg.nii.gz');

% Put the kidney mask on the final fat avg file -- to get the kidney area only
final_fat_diff_avg_kidney = final_fat_diff_avg(kidney_mask);

%Get the median and mean of the kidney
f_fat_di_avg_kidney_median = median(final_fat_diff_avg_kidney);
f_fat_di_avg_kidney_mean = mean(final_fat_diff_avg_kidney);

disp(f_fat_di_avg_kidney_median);
disp(f_fat_di_avg_kidney_mean);

% Read the warped fat images
wp_fat = dir(fullfile(main_folder, '*_wp.nii.gz'));

% get total count for the loop
total_images = numel(wp_fat);
disp(total_images);

% Loop over everything
for n = 1:total_images
    mp = split(wp_fat(n).name, '_');
    mp{1};
    disp(mp{1});

    % read the warped fat diff file
    wp_fat_file = niftiread(fullfile(main_folder, strcat(string(mp{1}),'_fat_diff_wp.nii.gz')));

    % Put the ref kidney mask file on each warped fat diff file to get the kidey area
    wp_fat_kidney = wp_fat_file(kidney_mask);

    % get the mean and median of the kidney fat
    wp_fat_median = median(wp_fat_kidney);
    wp_fat_mean = mean(wp_fat_kidney);


    % Load the data file and write the values
    dataset_file = fullfile(main_folder, '/male_median_kidney_fat.txt');
    r =  readtable(dataset_file);
    C = {string(mp{1}),wp_fat_median,wp_fat_mean};
    T = cell2table(C,'VariableNames',{'SUBJECT','Median_fat','Mean_fat'});
    Tout = [r;T];
    writetable(Tout, dataset_file);



end

%dataset_file2 = fullfile(main_folder, '/median_fat.txt');
%r2 =  readtable(dataset_file2);
%C2 = {'final_fat_diff_kidney',f_fat_di_avg_kidney_median,f_fat_di_avg_kidney_mean};
%T2 = cell2table(C2,'VariableNames',{'SUBJECT','Median_fat','Mean_fat'});
%Tout2 = [r2;T2];
%writetable(Tout2, dataset_file2);


