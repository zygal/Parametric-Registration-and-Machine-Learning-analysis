dataset_file1 = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/female_res/low_reg/RMSE_low_reg_inter_det.txt';
dataset_file2 = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/female_res/RMSE_inter_det_fake.txt';

dataset_file3 = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/male_res/low_reg/RMSE_low_reg_inter_det.txt';

dataset_file4 = '/home/saradh/Desktop/Thesis/matlab/results/latitudinal/male_res/RMSE_inter_det_fake.txt';


A =  readtable(dataset_file1);
B = readtable(dataset_file2);
D = readtable(dataset_file3);
E = readtable(dataset_file4);
C = [A;B;D;E];

figure
boxplot(C.Det_Err, C.ISO)
title('Latitudinal')
xlabel('Regularization Strength')
ylabel('Jacobian Error')
savefig('/home/saradh/Desktop/Thesis/matlab/results/latitudinal/Jac_err_combined_low_reg_INTER_F', 'pdf', 'jpeg','-r300')

boxplot(C.RMSE, C.ISO)
title('Latitudinal')
xlabel('Regularization Strength')
ylabel('RMSE')
savefig('/home/saradh/Desktop/Thesis/matlab/results/latitudinal/RMSE_combined_low_reg_INTER_F', 'pdf', 'jpeg','-r300')
