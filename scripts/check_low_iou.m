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
% This function checks prediction against the bounding boxes of thing 
% classes. If the IoU between prediction and GT bounding box is less than
% thresh, then the bounding box is filled with appropriate train id. 
%  INPUT:
%  - pred_label : prediction
%  - annotation : GT boxes, area and class
%  - thresh   : IoU threshold below which filling is carried out 
%  - do_not_alter_existing_things : when set to true, the filling will 
%                                 not overwrite existing thing predictions
%                                 of a different class
%  - ignore_label  : label to ignore, normally 255
%
%  OUTPUT:
%  - modified_label: processed prediction
%
%  DEMO:
%  - See scripts/clean_label.m
% ------------------------------------------------------------------------

function modified_label = check_low_iou(pred_label, annotation, thresh, do_not_alter_existing_things, ignore_label)
% label: HxW label map
% annotation
%	L> object
%       L> bbox:   [xmin, ymin, xmax, ymax]
%          area:   rectangular area of bbox
%          class:  class_id as used in label

modified_label = pred_label;
stuff_classes = 0:10;
if do_not_alter_existing_things
    ignore_or_stuff_mask = or(pred_label==ignore_label, ismember(pred_label, stuff_classes));
end

if isempty(annotation) || isempty(annotation.object)
    return;
end

box_areas = extractfield(annotation.object, 'area');
% we assume the smaller boxes are in the front of bigger boxes
[~, ranking] = sort(box_areas, 'descend');

for k = 1:numel(annotation.object)
    % go from big to small
    ind = ranking(k);
    % get the gt class
    gt_class = annotation.object(ind).class;
    % skip stuff classes since their bounding boxes are image-level
    if ismember(gt_class, stuff_classes)
        continue;
    end
    % make a binary mask for the gt bbox
    xmin = annotation.object(ind).bbox(1)+1;
    ymin = annotation.object(ind).bbox(2)+1;
    xmax = annotation.object(ind).bbox(3)+1;
    ymax = annotation.object(ind).bbox(4)+1;
    cols = double([xmin xmax xmax xmin]);
    rows = double([ymin ymin ymax ymax]);
    gt_bbox_mask = poly2mask(cols, rows, size(pred_label, 1), size(pred_label, 2));
    % make a binary class mask for the region inside the gt bbox
    label_mask = and(pred_label==gt_class, gt_bbox_mask);
    % calculate the IoU
    bbox_iou = nnz(label_mask) / nnz(gt_bbox_mask);
    % if it is smaller than a threshold
    if bbox_iou < thresh
        % we fill the region inside the box which is not gt_class with
        % gt_class
        rectify_region = and(pred_label~=gt_class, gt_bbox_mask);
        if do_not_alter_existing_things
            rectify_region = and(rectify_region, ignore_or_stuff_mask);
        end
        modified_label(rectify_region) = gt_class;
    end
end
end