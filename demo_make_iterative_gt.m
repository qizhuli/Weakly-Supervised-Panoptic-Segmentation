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

% It post-process network predictions to produce iterative GT for training
% in the next iteration
% Inputs:
%   1. results/pred_flat_feat/*.mat: the softmax scores of the predicted
%   classes
%   2. results/pred_sem_raw/*.png: the prediction made by the current
%   weakly-supervised model
%   3. results/mcg_and_grabcut/*.png: the combined cues from MCG and
%   Grabcut. Optional, set opts.run_merge_with_mcg_and_grabcut = false to
%   disable. To reproduce the results in our paper, disable after first 5
%   iterations.
% ------------------------------------------------------------------------

clearvars;
addpath scripts
addpath utils

% Extract detections from Cityscapes ground truth file and save as .mat
% this only need to be done once, as they do not change over iterative
% training stages
demo_instanceTrainId_to_dets;

clearvars;
dataset = 'cityscapes';
split = 'train';
opts = get_opts(dataset, split);
opts.list_path = 'lists/demo_id.txt';
run_sub(opts);