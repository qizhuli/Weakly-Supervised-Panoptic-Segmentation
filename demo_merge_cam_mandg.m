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
% This script demos generation of iterative ground truths for weakly-
% supervised experiments.
%
% It merges CAM predictions with MCG&Grabcut masks to produce GT for 
% the first round of iterative training
% Inputs:
%   1. results/cam/*.png: the CAMs obtained from a multi-class classifier
%   2. results/mcg_and_grabcut/*.png: the combined cues from MCG and
%   Grabcut.
% ------------------------------------------------------------------------

clearvars;
addpath scripts
addpath utils
addpath visualisation

% Extract detections from Cityscapes ground truth file and save as .mat
% this only need to be done once, as they do not change over iterative
% training stages
demo_instanceTrainId_to_dets;

clearvars;
dataset = 'cityscapes';
split = 'train';
opts = get_opts(dataset, split);
opts.list_path = 'lists/demo_id.txt';
opts.pred_dir = 'cam';
opts.sem_save_dir = 'pred_sem_cam_mandg_merged';
opts.ins_save_dir = 'pred_ins_cam_mandg_merged';
opts.run_score_thresh = false;
opts.visualise_results = true;
[opts, results] = run_sub(opts);

% visualise
visualise_results_cam_mandg(opts, results);