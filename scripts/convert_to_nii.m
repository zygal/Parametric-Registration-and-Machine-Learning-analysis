% NRRD to NII.gz

fixed_folder = '/home/saradh/Desktop/Thesis/matlab/first_visit';
mov_folder = '/home/saradh/Desktop/Thesis/matlab/second_visit';
resultsfv = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/male_res/repr/fv';
filename = fullfile(resultsfv);

results2 = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/male_res/repr/sv';
filename2 = fullfile(results2);

f_fat_folder = [fixed_folder,'/male_fat'];
f_water_folder = [fixed_folder,'/male_water'];

m_fat_folder = [mov_folder,'/male_fat'];
m_water_folder = [mov_folder,'/male_water'];


fv = {'3655800' };

sv = {'3655800'};

for n = 1:numel(fv)

    [X_f, META1] = nrrdread(fullfile(f_fat_folder,strcat(fv{n},'_F.nrrd')));
    [X_w, META2] = nrrdread(fullfile(f_water_folder,strcat(fv{n},'_W.nrrd')));
    volfix = cat(4,X_f,X_w);

    niftiwrite(volfix, [filename,'/',fv{n}, '_fixed.nii'], 'Compressed',true);

end

for n = 1:numel(sv)

   [Y_f, META1] = nrrdread(fullfile(m_fat_folder,strcat(sv{n},'_F.nrrd')));
   [Y_w, META2] = nrrdread(fullfile(m_water_folder,strcat(sv{n},'_W.nrrd')));
   volmov = cat(4,Y_f,Y_w);

  niftiwrite(volmov, [filename2,'/',sv{n}, '_moving.nii'], 'Compressed',true);

end

