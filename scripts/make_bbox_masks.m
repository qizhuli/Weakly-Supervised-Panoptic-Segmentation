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
% This function processes the output of instanceTrainId_to_dets.m to make 
% two formats of annotation used by other code. 
%  INPUT:
%  - annotation_file_path : file path to the saved output of 
%                           instanceTrainId_to_dets.m
%  - objectNames: cell of class names
%  - canvas_size: size of original full image
%
%  OUTPUT:
%  - bbox_masks: class-specific bounding box masks by combining 
%                bounding box masks of the same predicted class
%  - bboxes: struct storing bbox location, class, area, whether group
%
%  DEMO:
%  - See scripts/load_data.m
% ------------------------------------------------------------------------

function [bbox_masks, bboxes] = make_bbox_masks(annotation_file_path, objectNames, canvas_size)
bbox_masks = cell(length(objectNames), 1);
temp = load(annotation_file_path);
annotation = temp.dets;
if ~isfield(annotation.annotation, 'object') || isempty(annotation.annotation.object)
    bboxes = [];
    return;
end
for k = 1:length(annotation.annotation.object)
    class = annotation.annotation.object(k).name;
    class_id = find(strcmp(class, objectNames)) - 1;
    bndbox = annotation.annotation.object(k).bndbox;
    xmin = str2double(bndbox.xmin)+1;
    ymin = str2double(bndbox.ymin)+1;
    xmax = str2double(bndbox.xmax)+1;
    ymax = str2double(bndbox.ymax)+1;
    is_grp = logical(str2double(annotation.annotation.object(k).is_grp));
    is_stuff = logical(str2double(annotation.annotation.object(k).is_stuff));
    xmin = max(1, xmin);
    ymin = max(1, ymin);
    xmax = min(canvas_size(2), xmax);
    ymax = min(canvas_size(1), ymax);
    annotation.annotation.object(k).bbox = [xmin, ymin, xmax, ymax] - 1;
    annotation.annotation.object(k).area = (xmax - xmin + 1) * (ymax - ymin + 1);
    annotation.annotation.object(k).class = class_id;
    annotation.annotation.object(k).is_grp = is_grp;
    annotation.annotation.object(k).is_stuff = is_stuff;
    if isempty(bbox_masks{class_id + 1})
        class_mask = false(canvas_size);
    else
        class_mask = bbox_masks{class_id + 1};
    end
    class_mask(ymin:ymax, xmin:xmax) = true;
    bbox_masks{class_id + 1} = class_mask;
end
bboxes = annotation.annotation;
end