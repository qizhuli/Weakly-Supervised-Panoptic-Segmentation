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
% This function cleans up raw network predictions by performance 5 
% operations as numbered below. 
%  INPUT:
%  - opts : options as produced by scripts/get_opts.m
%  - results : struct containing required data and original prediction
%
%  OUTPUT:
%  - results: struct containing required data, original prediction and 
%              processed prediction
%
%  DEMO:
%  - See scripts/run_sub.m
% ------------------------------------------------------------------------

function results = clean_label(opts, results)
%% 1. Confidence threshold
% requires pred_scores + prediction + conf_thresh
if opts.run_score_thresh
    results.pred_threshed = results.final_pred;
    results.pred_threshed(results.pred_scores < opts.score_thresh) = opts.ignore_label;
    results.final_pred = results.pred_threshed;
end

%% 2. Remove things outside bounding boxes
% requires gt_bbox_masks + prediction
if opts.run_apply_bbox_prior
    results.pred_bbox_prior = apply_bbox_prior(results.final_pred, results.gt_bbox_masks, ...
        opts.thing_classes, opts.ignore_label);
    results.final_pred = results.pred_bbox_prior;
end

%% 3. Stuff class check, using image tags of crops
% requires gt_label + prediction
if opts.run_check_image_level_tags
    results.pred_schk = check_image_level_tags(results.final_pred, results.gt_label, ...
        opts.schk_crop_size, opts.canvas_size, opts.ignore_label);
    results.final_pred = results.pred_schk;
end

%% 4. Merge with MCG&Grabcut cues
if opts.run_merge_with_mcg_and_grabcut
    results.pred_merge_w_mandg = merge_mag_and_pred(results.mandg_pred, results.final_pred, ...
        opts.stuff_classes, opts.thing_classes, opts.ignore_label);
    results.final_pred = results.pred_merge_w_mandg;
end

%% 5. IoU check, fill low IoU with solid colour
% requires gt_bboxes + prediction
if opts.run_check_low_iou
    results.pred_ichk = check_low_iou(results.final_pred, results.gt_bboxes, opts.ichk_thresh, ...
        opts.ichk_do_not_alter_existing_things, opts.ignore_label);
    results.final_pred = results.pred_ichk;
end

end