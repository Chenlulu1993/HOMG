function [feature_map, img_samples] = extract_features(image, pos, scales, features, gparams, extract_info,mosaic)

% Sample image patches at given position and scales. Then extract features
% from these patches.
% Requires that cell size and image sample size is set for each feature.

if ~iscell(features)
    error('Wrong input');
end

if ~isfield(gparams, 'use_gpu')
    gparams.use_gpu = false;
end
if ~isfield(gparams, 'data_type')
    gparams.data_type = zeros(1, 'single');
end
if nargin < 6
    % Find used image sample size
    extract_info = get_feature_extract_info(features);
end

num_features = length(features);
num_scales = size(scales,2);
num_sizes = length(features);

% Extract image patches
img_samples = cell(num_sizes,1);
for sz_ind = 1:num_sizes
    img_sample_sz = extract_info.img_sample_sz{sz_ind};
    img_input_sz = features{sz_ind}.img_input_sz;
%     a = {[],[],[],[],[],[],[]};
%     for i = 1:7
%      ys{sz_ind}.ys{1,i} = a{1,i};
%     end
%     img_samples{sz_ind} = zeros(img_input_sz(1), img_input_sz(2), size(image,3), num_scales, 'uint8');
    for scale_ind = 1:num_scales
        [img_samples{sz_ind}.im_patch{scale_ind}(:,:,:),output_sz,ys{sz_ind}.ys{scale_ind},xs{sz_ind}.xs{scale_ind}] = sample_patch(image, pos, img_sample_sz*scales(features{sz_ind}.fparams.feature_is_deep+1,scale_ind), img_input_sz, gparams);
    end
end

% Find the number of feature blocks and total dimensionality
num_feature_blocks = 0;
total_dim = 0;
for feat_ind = 1:num_features
    num_feature_blocks = num_feature_blocks + length(features{feat_ind}.fparams.nDim);
    total_dim = total_dim + sum(features{feat_ind}.fparams.nDim);
end

feature_map = cell(1, 1, num_feature_blocks);

% Extract feature maps for each feature in the list
ind = 1;
for feat_ind = 1:num_features
    feat = features{feat_ind};
    
    % do feature computation
    if feat.is_cell
        num_blocks = length(feat.fparams.nDim);
        feature_map(ind:ind+num_blocks-1) = feat.getFeature(img_samples{feat_ind}, feat.fparams, gparams);
    else
        num_blocks = 1;
        feature_map{ind} = feat.getFeature(img_samples{feat_ind}.im_patch, feat.fparams, gparams,output_sz,ys{feat_ind}.ys,xs{feat_ind}.xs,mosaic);
%         feature_map{ind} = feat.getFeature(img_samples{feat_ind}, feat.fparams, gparams);
    end
    
    ind = ind + num_blocks;
end
              
% Do feature normalization
if ~isempty(gparams.normalize_power) && gparams.normalize_power > 0
    if gparams.normalize_power == 2
        feature_map = cellfun(@(x) bsxfun(@times, x, ...
            sqrt((size(x,1)*size(x,2))^gparams.normalize_size * size(x,3)^gparams.normalize_dim ./ ...
            (sum(reshape(x, [], 1, 1, size(x,4)).^2, 1) + eps))), ...
            feature_map, 'uniformoutput', false);
    else
        feature_map = cellfun(@(x) bsxfun(@times, x, ...
            ((size(x,1)*size(x,2))^gparams.normalize_size * size(x,3)^gparams.normalize_dim ./ ...
            (sum(abs(reshape(x, [], 1, 1, size(x,4))).^gparams.normalize_power, 1) + eps)).^(1/gparams.normalize_power)), ...
            feature_map, 'uniformoutput', false);
    end
end
if gparams.square_root_normalization
    feature_map = cellfun(@(x) sign(x) .* sqrt(abs(x)), feature_map, 'uniformoutput', false);
end

end