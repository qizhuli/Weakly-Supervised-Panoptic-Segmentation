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
%
% It is a batch processor. Set split to 'train', 'val', or 'train_extra' 
% as appropriate. Make sure the instance ground truth files are found in
% data/Cityscapes/gt<Fine,Coarse>/<train,val,train_extra>/ respectively.
% If `visualise` is set to true, make sure the original RGB files are 
% available in data/Cityscapes/leftImg8bit/<train,val,train_extra>/ 
% following the standard Cityscapes data folder organisation.
% -----------------------------------------------------------------------

clearvars;
addpath utils
addpath scripts
addpath visualisation

%% Configure

split = 'val'; % train, val or train_extra

% set is_panoptic flag to include image-level stuff class dets
is_panoptic = true;

% set incl_grps flag to include thing groups present in Cityscapes
% annotation
incl_grps = true;

% trainIds of stuff classes
stuff_classes = 0:10;

% trainIds of thing classes
thing_classes = 11:18;

% class names
load objectName19.mat

% ignore label
ignore_label = 255;

% force overwrite
force_overwrite = true;

% visualise
visualise = false;
visualise_save_template = '%s_leftImg8bit.png';
load utils/colormapcs.mat

%% Parse
switch split
    case 'train'
        instanceTrainId_dir = 'data/Cityscapes/gtFine/train';
        instanceTrainId_template = '%s_gtFine_instanceTrainIds.png';
        list_path = 'data/Cityscapes/lists/train_id.txt';
        save_dir = 'data/Cityscapes/gtFine_bboxes/train/%s'; % panoptic or thing-only as the child folder
        save_template = '%s_leftImg8bit.mat';
        rgb_dir = 'data/Cityscapes/leftImg8bit/train';
    case 'val'
        instanceTrainId_dir = 'data/Cityscapes/gtFine/val';
        instanceTrainId_template = '%s_gtFine_instanceTrainIds.png';
        list_path = 'data/Cityscapes/lists/val_id.txt';
        save_dir = 'data/Cityscapes/gtFine_bboxes/val/%s'; % panoptic or thing-only as the child folder
        save_template = '%s_leftImg8bit.mat';
        rgb_dir = 'data/Cityscapes/leftImg8bit/val';
    case 'train_extra'
        instanceTrainId_dir = 'data/Cityscapes/gtCoarse/train_extra';
        instanceTrainId_template = '%s_gtCoarse_instanceTrainIds.png';
        list_path = 'data/Cityscapes/lists/train_extra_id.txt';
        save_dir = 'data/Cityscapes/gtCoarse_bboxes/train_extra/%s'; % panoptic or thing-only as the child folder
        save_template = '%s_leftImg8bit.mat';
        rgb_dir = 'data/Cityscapes/leftImg8bit/train_extra';
    otherwise
        error('Unrecognised data split.');
end

if is_panoptic
    save_dir = sprintf(save_dir, 'panoptic');
else
    save_dir = sprintf(save_dir, 'thing-only');
end
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

list = importdata(list_path);

%% Run the extraction
for k = 1:length(list)
    id = list{k};
    save_path = fullfile(save_dir, sprintf(save_template, id));
    % if the save_path file exists, and we don't require force-overwrite, skip the current file
    if ~force_overwrite && exist(save_path, 'file')
        continue;
    end
    city = strtok(id, '_');
    label_path = fullfile(instanceTrainId_dir, city, sprintf(instanceTrainId_template, id));
    label = imread(label_path);
    dets = instanceTrainId_to_dets(label, is_panoptic, incl_grps, ...
        stuff_classes, thing_classes, objectNames, ignore_label);
    save(fullfile(save_path), 'dets');
    if visualise
        vis_im = visualise_bboxes(id, objectNames, cmap, rgb_dir, save_dir);
        imwrite(vis_im, fullfile(save_dir, sprintf(visualise_save_template, id)));
    end
    if mod(k, 100) == 0
        fprintf('[%s] Processed %d/%d\n', char(datetime), k, length(list));
    end
end
