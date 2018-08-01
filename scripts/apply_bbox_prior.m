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
% This function removes thing-class predictions outside their bounding 
% boxes.
%  INPUT:
%  - pred_label : prediction
%  - bbox_masks : object bounding box masks produced by make_bbox_masks.m 
%  - thing_classes : list of train ids for thing classes
%  - ignore_label  : label to ignore, normally 255
%
%  OUTPUT:
%  - modified_label: processed prediction
%
%  DEMO:
%  - See scripts/clean_label.m
% ------------------------------------------------------------------------

function modified_label = apply_bbox_prior(pred_label, bbox_masks, thing_classes, ignore_label)
modified_label = pred_label;
for j = reshape(thing_classes, 1, []);
    if isempty(bbox_masks{j+1})
        modified_label(modified_label == j) = ignore_label;
    else
        prediction_bbox_prior_mask = modified_label == j;
        gt_bbox_mask = bbox_masks{j+1};
        ignore_mask = and(prediction_bbox_prior_mask, ~gt_bbox_mask);
        modified_label(ignore_mask) = ignore_label;
    end
end
end