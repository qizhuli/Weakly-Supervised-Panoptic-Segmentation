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
% This script demos extracting bounding box information from Cityscapes
% instance ground truth (*_gtFine_instanceTrainIds.png files) for
% generation of iterative ground truths for weakly-supervised experiments
% ------------------------------------------------------------------------

addpath utils
addpath scripts

instanceTrainId_file_path = 'data/Cityscapes/gtFine/train/aachen/aachen_000000_000019_gtFine_instanceTrainIds.png';
label = imread(instanceTrainId_file_path);

% set is_panoptic flag to include image-level stuff class dets
is_panoptic = true;

% set incl_grps flag to include thing groups present in Cityscapes
% annotation
incl_grps = true;

% trainId of stuff classes
stuff_classes = 0:10;

% trainId of thing classes
thing_classes = 11:18;

% class names
load objectName19.mat

% ignore label
ignore_label = 255;

% run the extraction
dets = instanceTrainId_to_dets(label, is_panoptic, incl_grps, ...
    stuff_classes, thing_classes, objectNames, ignore_label);
save_dir = 'data/Cityscapes/gtFine_bboxes/train/panoptic';
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
save(fullfile(save_dir, 'aachen_000000_000019_leftImg8bit.mat'), 'dets');
