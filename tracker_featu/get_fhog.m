function [ feature_image ] = get_fhog( im1, fparam, gparam,output_sz,ys,xs,mosaic )
 

if ~isfield(fparam, 'nOrients')
    fparam.nOrients = 9;
end
if isfield(fparam, 'cell_size')
    cell_size = fparam.cell_size;
else
    cell_size = gparam.cell_size;
end

 im_height = output_sz(1);
 im_width = output_sz(2);
num_images = size(im1,2);
fparam.nDim = 64;
 feature_image = zeros(floor(im_height/cell_size), floor(im_width/cell_size), fparam.nDim, num_images, 'like', gparam.data_type);

for k = 1:num_images
    im = im1{1,k};
    ys1 = ys{1,k};
    xs1 = xs{1,k};
    homg_image = get_sshog(single(im'), cell_size,ys1,xs1,output_sz,mosaic);
    feature_image(:,:,:,k) = homg_image(:,:,1:end);
end
end