addpath(genpath('../mutils/My/'));
addpath(genpath('../ptv'));


dir_fixed = 'first_visit/reg_bulk_sub';
dir_mov = 'second_visit/reg_bulk_sub';
%csvfiles = dir_fixed('*.csv');

%for file = csvfiles'

%    fprintf(1, 'Doing something with %s.\n', file.name)

%end