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
% This function checks prediction against the image-level tags. If a class
% is predicted by network but not present as indicated by image-level 
% tags, the predicted label is changed to ignore_label.
%  INPUT:
%  - pred_label : prediction
%  - gt_label   : ground truth label to generate image level tags
%  - crop_size  : size of crops used in training the multi-class 
%                 classifier. In our experiments, [w,h] = [500, 400]
%  - canvas_size : size of original full image
%  - ignore_label  : label to ignore, normally 255
%
%  OUTPUT:
%  - modified_label: processed prediction
%
%  DEMO:
%  - See scripts/clean_label.m
% ------------------------------------------------------------------------

function modified_label = check_image_level_tags(pred_label, gt_label, crop_size, canvas_size, ignore_label)
modified_label = pred_label;

n_tiles_width = ceil(canvas_size(2) / crop_size(2));
n_tiles_height = ceil(canvas_size(1) / crop_size(1));

overlap_width = ceil((n_tiles_width * crop_size(2) - canvas_size(2)) / (n_tiles_width - 1));
overlap_height = ceil((n_tiles_height * crop_size(1) - canvas_size(1)) / (n_tiles_height - 1));

for j = 1:n_tiles_width
    for k = 1:n_tiles_height
        w_start = 1 + (j - 1) * (crop_size(2) - overlap_width);
        w_end = w_start + crop_size(2) - 1;
        h_start = 1 + (k - 1) * (crop_size(1) - overlap_height);
        h_end = h_start + crop_size(1) - 1;
        % check everything is within range
        assert(w_start >= 1 && h_start >= 1 && w_end <= canvas_size(2) && h_end <= canvas_size(1));
        gt_label_crop = gt_label(h_start:h_end, w_start:w_end);
        pred_label_crop = modified_label(h_start:h_end, w_start:w_end);
        present_gt_labels = unique(gt_label_crop);
        present_pred_labels = unique(pred_label_crop);
        for i = 1:numel(present_pred_labels)
            label = present_pred_labels(i);
            if ~ismember(label, present_gt_labels)
                pred_label_crop(pred_label_crop==label) = ignore_label;
            end
        end
        modified_label(h_start:h_end, w_start:w_end) = pred_label_crop; 
    end
end
end