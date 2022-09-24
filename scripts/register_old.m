addpath(genpath('../mutils/My/'));
addpath(genpath('../ptv'));

[X, META] = nrrdread('first_visit/1715832_F.nrrd');
[Y, META] = nrrdread('second_visit/1715832_F.nrrd');
volfix = squeeze(X);
volmov = squeeze(Y);



%%
opts = [];
opts.metric = 'loc_cc_fftn_gpu';
opts.grid_spacing = [4,4,3];
opts.display = 'off';
opts.max_iters = 80; 
opts.metric_param = 2.5 * [1,1,1]; 
opts.interp_type = 1;
opts.spline_order = 1;
opts.isoTV = 0.11;
opts.loc_cc_approximate = false;
opts.border_mask = 1;
opts.k_down = 0.7;
opts.check_gradients = 100*0;


%%

[voldef_pl, Tmin_pl, Kmin_pl] = ptv_register(volmov, volfix, opts);


%%
WriteToVTK(voldef_pl, '../../results/secondM_firstF_F.vtk')
