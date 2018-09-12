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
% This function merges network prediction with weak cues from MCG and 
% Grabcut. 
%  INPUT:
%  - mag : MCG&Grabcut output
%  - pred: semantic prediction
%  - stuff_clases : stuff class ids, e.g. 0:10
%  - thing_classes: thing class ids, e.g. 11:18
%  - ignore_label : label to ignore, normally 255
%
%  OUTPUT:
%  - merged_label: the combined label
%
%  DEMO:
%  - See scripts/clean_label.m
% ------------------------------------------------------------------------

function merged_label = merge_mag_and_pred(mag, pred, stuff_classes, thing_classes, ignore_label)

assert(all(size(mag) == size(pred)), 'Size mismatch');

mag_label_things_mask = ismember(mag, thing_classes);
mag_label_stuff_mask = ismember(mag, 0);
mag_label_ignore_mask = ismember(mag, ignore_label);
pred_label_things_mask = ismember(pred, thing_classes);
pred_label_stuff_mask = ismember(pred, stuff_classes);
pred_label_ignore_mask = ismember(pred, ignore_label);

merged_label = 255*uint8(ones(size(mag)));

%% 1) if m&g label predicts thing class label C1:
%   a. pred predicts thing class C1 => C1
    mask_1a = and(mag_label_things_mask, mag == pred);
    merged_label(mask_1a) = mag(mask_1a); 
%   b. pred predicts thing class C2 => C1
    mask_1b = and(and(mag_label_things_mask, pred_label_things_mask), ~mask_1a);
    merged_label(mask_1b) = mag(mask_1b);
%   c. pred predicts background class C3 => C1
    mask_1c = and(mag_label_things_mask, pred_label_stuff_mask);
    merged_label(mask_1c) = mag(mask_1c);
%   d. pred predicts 255 => C1
    mask_1d = and(mag_label_things_mask, pred_label_ignore_mask);
    merged_label(mask_1d) = mag(mask_1d);

%% 2) if m&g label predicts background class label 0:
%   a. pred predicts things class C1 => 255
    mask_2a = and(mag_label_stuff_mask, pred_label_things_mask);
    merged_label(mask_2a) = ignore_label;
%   b. pred predicts background class C2 => C2
    mask_2b = and(mag_label_stuff_mask, pred_label_stuff_mask);
    merged_label(mask_2b) = pred(mask_2b);
%   c. pred predicts 255 => 255
    mask_2c = and(mag_label_stuff_mask, pred_label_ignore_mask);
    merged_label(mask_2c) = ignore_label;

%% 3) if m&g label predicts ignore label 255:
%   a. pred predicts thing class C1 => 255
    mask_3a = and(mag_label_ignore_mask, pred_label_things_mask);
    merged_label(mask_3a) = ignore_label;
%   b. pred predicts background class C2 => C2
    mask_3b = and(mag_label_ignore_mask, pred_label_stuff_mask);
    merged_label(mask_3b) = pred(mask_3b);
%   c. pred predicts 255 => 255
    mask_3c = and(mag_label_ignore_mask, pred_label_ignore_mask);
    merged_label(mask_3c) = ignore_label;

end