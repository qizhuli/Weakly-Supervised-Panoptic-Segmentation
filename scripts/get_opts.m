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
% This function produces a struct containing the required options used in 
% scripts/run_sub.m. 
%  INPUT:
%  - dataset : name of the dataset, e.g. "cityscapes"
%  - split : dataset split, e.g. "train", "val", "train_extra"
%
%  OUTPUT:
%  - opts: generated options
%
%  DEMO:
%  - See demo_make_iterative_gt.m
% ------------------------------------------------------------------------

function opts = get_opts(dataset, split)
% Dataset specific settings
switch dataset
    case 'cityscapes'
        switch split
            case 'train'
                opts.list_path = 'lists/train_id.txt';
                opts.annotation_dir = 'gtFine_bboxes/train/panoptic';
                opts.gt_label_dir = 'gtFine/train';
                opts.gt_label_template = '%s_gtFine_labelTrainIds.png';
            case 'train_extra'
                opts.list_path = 'lists/train_extra_id.txt';
                opts.annotation_dir = 'gtCoarse_bboxes/train_extra/panoptic';
                opts.gt_label_dir = 'gtCoarse/train_extra';
                opts.gt_label_template = '%s_gtCoarse_labelTrainIds.png';
            case 'val'
                opts.list_path = 'lists/val_id.txt';
                opts.annotation_dir = 'gtFine_bboxes/val/panoptic';
                opts.gt_label_dir = 'gtFine/val';
                opts.gt_label_template = '%s_gtFine_labelTrainIds.png';
            case 'test'
                error('Cannot post-process inferences on the test set.');
            otherwise
                error('Unknown split option.');
        end
        opts.data_root = 'data/Cityscapes';
        opts.annotation_template = '%s_leftImg8bit.mat';
        opts.objectNames_path = 'objectName19.mat';
        opts.colormap_path = 'colormapcs.mat';
        opts.canvas_size = [1024, 2048];
        opts.ignore_label = 255;
        opts.stuff_classes = 0:10;
        opts.thing_classes = 11:18;
        opts.pred_template = '%s_leftImg8bit.png';
        opts.pred_score_template = '%s_leftImg8bit.mat';
        opts.mcg_and_grabcut_template = '%s_leftImg8bit.png';
    otherwise
        error('Unknown dataset option');
end

% Job specific settings
opts.pred_root = 'results';
opts.score_thresh = 0.99;
opts.ichk_thresh = 0.5;
opts.ichk_do_not_alter_existing_things = true;
opts.schk_crop_size = [400, 500];

% General settings
opts.pred_dir = 'pred_sem_raw';
opts.pred_score_dir = 'pred_flat_feat';
opts.mcg_and_grabcut_dir = 'mcg_and_grabcut';
opts.sem_save_dir = 'pred_sem_clean';
opts.ins_save_dir = 'pred_ins_clean';
opts.force_overwrite = true;
opts.save_sem = true;
opts.save_ins = true;
opts.visualise_results = false;

% Select which stages to run
opts.run_score_thresh = true;
opts.run_apply_bbox_prior = true;
opts.run_check_low_iou = true;
opts.run_check_image_level_tags = true;
opts.run_merge_with_mcg_and_grabcut = true;
end