% ------------------------------------------------------------------------ 
%  Copyright (C)
%  Torr Vision Group (TVG)
%  University of Oxford - UK
% 
%  Qizhu Li <liqizhu@robots.ox.ac.uk>
%  August 2018
% ------------------------------------------------------------------------ 
% This file is part of the weakly-supervised training method presented in:
%    Qizhu Li*, Anurag Arnab*, Philip H.S. Torr,
%    "Weakly- and Semi-Supervised Panoptic Segmentation,"
%    European Conference on Computer Vision (ECCV) 2018.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
% This function loads data required by run_sub.m. 
%  INPUT:
%  - opts : options as produced by scripts/get_opts.m
%  - k: instructs the function to load data for the k-th entry in 
%       opts.list
%
%  OUTPUT:
%  - results: struct obtaining loaded data
%
%  DEMO:
%  - See scripts/run_sub.m
% ------------------------------------------------------------------------

function results = load_data(opts, k)
%% Initialisation
results.id = opts.list{k};

%% Load required data
% pred, pred_scores, gt_bbox_masks, gt_bboxes, gt_label, mandg_pred (MCG&Grabcut)
[results.pred, results.cmap] = imread(fullfile(opts.pred_root, opts.pred_dir, ...
    sprintf(opts.pred_template, results.id)));
if opts.run_score_thresh
    temp = load(fullfile(opts.pred_root, opts.pred_score_dir, ...
        sprintf(opts.pred_score_template, results.id)));
    temp_name = fieldnames(temp);
    results.pred_scores = temp.(temp_name{1});
end
[results.gt_bbox_masks, results.gt_bboxes] = make_bbox_masks(fullfile(opts.data_root, opts.annotation_dir, ...
    sprintf(opts.annotation_template, results.id)), opts.objectNames, opts.canvas_size);
city = strtok(results.id, '_');
results.gt_label = imread(fullfile(opts.data_root, opts.gt_label_dir, city, ...
    sprintf(opts.gt_label_template, results.id)));
[results.mandg_pred, results.mandg_cmap] = imread(fullfile(opts.pred_root, opts.mcg_and_grabcut_dir, ...
    sprintf(opts.mcg_and_grabcut_template, results.id)));

results.final_pred = results.pred;

end