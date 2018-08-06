function vis_im = visualise_bboxes(id, objectNames, cmap, rgb_dir, detection_dir)

font_size = 25;

city = strtok(id, '_');

image_filename = fullfile(rgb_dir, city, [id '_leftImg8bit.png']);
detection_filename = fullfile(detection_dir, [id '_leftImg8bit.mat']);

rgb_im = imread(image_filename);
temp = load(detection_filename);
detections = temp.dets.annotation;
vis_im = rgb_im;

if ~isfield(detections, 'object') || isempty(detections.object)
    return;
end

rectangle_position = zeros(length(detections), 4);
colour = zeros(length(detections), 3);
text_strings = cell(length(detections), 1);
% we eventually want to display the bboxes differently depending on whether
% they are a group annotation or not. unfortunately it seems insertShape as
% it is now doesn't support changes to line style.
is_grp = zeros(length(detections), 1);

for k = length(detections.object):-1:1
    name = detections.object(k).name;
    train_id = find(strcmp(objectNames, name)) - 1;
    assert(~isempty(train_id));
    xmin = str2double(detections.object(k).bndbox.xmin) + 1;
    ymin = str2double(detections.object(k).bndbox.ymin) + 1;
    xmax = str2double(detections.object(k).bndbox.xmax) + 1;
    ymax = str2double(detections.object(k).bndbox.ymax) + 1;
    width = xmax - xmin + 1;
    height = ymax - ymin + 1;
    rectangle_position(k, :) = [xmin, ymin, width, height];
    
    colour(k, :) = cmap(train_id + 1,:);
    text_strings{k} = name;
    is_grp(k) = logical(str2double(detections.object(k).is_grp));
    % this is a temporary workaround
    if is_grp(k)
        text_strings{k} = [text_strings{k}, 'group'];
    end

end

text_position = rectangle_position(:,1:2);
vis_im = insertShape(vis_im, 'Rectangle', rectangle_position,...
    'LineWidth', 4, 'Color', colour*255);

% scale font size according to width of bbox for clearer visual
max_font_shrink_ratio = 2;
pixel_to_font_size_ratio = 2.6; % for three-letter word
step_size = 0.25;
width_threshes = [0, ...
    (pixel_to_font_size_ratio/max_font_shrink_ratio + step_size) : step_size : pixel_to_font_size_ratio,...
    Inf] * font_size;
for k = (numel(width_threshes) - 1):(-1):1
    dets_in_range = width_threshes(k) <= rectangle_position(:,3) & ...
        rectangle_position(:,3) < width_threshes(k+1);
    adjusted_font_size = floor(max(width_threshes(k)/pixel_to_font_size_ratio, ...
        font_size/max_font_shrink_ratio));
    if any(dets_in_range)
        vis_im = insertText(vis_im, text_position(dets_in_range, :), text_strings(dets_in_range),...
            'Font', 'UbuntuMono-R', 'FontSize', adjusted_font_size,...
            'BoxColor', colour(dets_in_range, :)*255, 'BoxOpacity', 0.5, 'TextColor', 'white', ...
            'AnchorPoint', 'LeftBottom');
    end
end
end
