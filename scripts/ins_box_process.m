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
% This function produces instance prediction from semantic prediction 
% using cues from GT bounding boxes. Regions where multiple bounding boxes 
% of the same class overlap is marked with ignore_label in instance pred
%  INPUT:
%  - sem_label : semantic prediction
%  - annotation : GT boxes, area and class
%  - ignore_label  : label to ignore, normally 255
%
%  OUTPUT:
%  - ins_label: instance prediction
%
%  DEMO:
%  - See scripts/run_sub.m
% ------------------------------------------------------------------------

function ins_label = ins_box_process(sem_label, annotation, ignore_label)

ins_label = uint8(zeros(size(sem_label)));
% transfer all ignore region
ins_label(sem_label==ignore_label) = ignore_label;

if isempty(annotation) || isempty(annotation.object)
    return;
end

% remove repeated bboxes of the same class just to be cautious
bboxes = reshape(extractfield(annotation.object, 'bbox'), 4, [])';
classes = extractfield(annotation.object, 'class')';
[~, unique_indices, ~] = unique([classes, bboxes], 'rows', 'stable');

for i = unique_indices'
    
    ins_id = i;
    
    % thing grp is not an instance
    is_grp = annotation.object(i).is_grp;
    if is_grp
        continue;
    end
    
    bbox = annotation.object(i).bbox;
    class_id = annotation.object(i).class;
    xmin = bbox(1)+1;
    ymin = bbox(2)+1;
    xmax = bbox(3)+1;
    ymax = bbox(4)+1;
    
    sem_gt_inside_bbox = sem_label(ymin:ymax, xmin:xmax);
    ins_gt_inside_bbox = ins_label(ymin:ymax, xmin:xmax);
    
    % for non-ignore region, if gt_id = class_id && gt_id != 0, then gt_id :-> ignore
    ins_gt_inside_bbox(and(sem_gt_inside_bbox==class_id, ins_gt_inside_bbox~=0)) = ignore_label;
    % for non-ignore region, if gt_id = class_id && gt_id = 0, then gt_id :-> ins_id
    ins_gt_inside_bbox(and(sem_gt_inside_bbox==class_id, ins_gt_inside_bbox==0)) = ins_id;
    
    ins_label(ymin:ymax, xmin:xmax) = ins_gt_inside_bbox;
end

% sanity check: all instance labels should be present
ins_gt_labels = setdiff(unique(ins_label(:)), [0, ignore_label]);
if ~isempty(setdiff(1:ins_id, ins_gt_labels))
    warning('sanity not preserved');
end

end