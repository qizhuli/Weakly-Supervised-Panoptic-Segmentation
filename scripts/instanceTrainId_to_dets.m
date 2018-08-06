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
% This function extracts bounding box information from Cityscapes ground
% truth (*_gtFine_instanceTrainIds.png files). 
%  INPUT:
%  - label : Cityscapes ground truth image
%  - is_panoptic: whether to include pseudo-detections for stuff classes
%                 (image-wide detections) which are present
%  - incl_grps : whether to include thing groups in output struct
%  - stuff_clases: stuff class ids, e.g. 0:10
%  - thing_classes: thing class ids, e.g. 11:18
%  - objectNames: cell of class names
%  - ignore_label  : label to ignore, normally 255
%
%  OUTPUT:
%  - dets: struct obtaining bounding box information
%
%  DEMO:
%  - See demo_instanceTrainId_to_dets.m
% ------------------------------------------------------------------------

function dets = instanceTrainId_to_dets(label, is_panoptic, incl_grps, ...
    stuff_classes, thing_classes, objectNames, ignore_label)

unique_ids = unique(label(:));
unique_ids = sort(unique_ids, 'ascend');
unique_ids = setxor(unique_ids, ignore_label);

% each entry in unique_ids is an id
% if id > 1000:
%   it is an instance of a thing, = trainId*1000 + instance_id ...(CASE 1)
% elseif id <= 1000:
%   if id in 0:1:10 :
%       it is stuff ...(CASE 2)
%       include image-wide det if is_panoptic
%   if id in 11:1:18 :
%       it is a thing group ...(CASE 3)
%       include group-wide det if incl_grps

instance_counter = 0;
dets.annotation = [];
canvas_dims = size(label);

for k = 1:numel(unique_ids)
    
    valid = false;
    is_grp = false;
    is_stuff = false;
    id = unique_ids(k);
    
    if is_panoptic && ismember(id, stuff_classes)
        % CASE 2
        valid = true;
        is_stuff = true;
        xmin = num2str(0);
        ymin = num2str(0);
        xmax = num2str(canvas_dims(2) - 1);
        ymax = num2str(canvas_dims(1) - 1);
        class = objectNames{id + 1};
    elseif id > 1000
        % CASE 1
        valid = true;
        trainId = floor(id/1000);
        mask = label == id;
        [y, x] = find(mask);
        xmin = num2str(min(x) - 1);
        ymin = num2str(min(y) - 1);
        xmax = num2str(max(x) - 1);
        ymax = num2str(max(y) - 1);
        class = objectNames{trainId + 1};
    elseif incl_grps && ismember(id, thing_classes)
        % CASE 3
        valid = true;
        is_grp = true;
        mask = label == id;
        [y, x] = find(mask);
        xmin = num2str(min(x) - 1);
        ymin = num2str(min(y) - 1);
        xmax = num2str(max(x) - 1);
        ymax = num2str(max(y) - 1);
        class = objectNames{id + 1};
    end
    
    if valid
        % record class name, and 0-based bbox coordinates
        instance_counter = instance_counter + 1;
        dets.annotation.object(instance_counter).name = class;
        dets.annotation.object(instance_counter).bndbox.xmin = xmin;
        dets.annotation.object(instance_counter).bndbox.ymin = ymin;
        dets.annotation.object(instance_counter).bndbox.xmax = xmax;
        dets.annotation.object(instance_counter).bndbox.ymax = ymax;
        dets.annotation.object(instance_counter).is_grp = num2str(is_grp);
        dets.annotation.object(instance_counter).is_stuff = num2str(is_stuff);
    end
    
end

end