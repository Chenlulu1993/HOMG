function [im_repatch,Ix,Iy,Ix_2,Iy_2,Il1,Il2] = ss_img(im_patch,ys,xs,model_sz,mosaic)
% MSSG operators design

model_sz = [model_sz(2),model_sz(1)];
[m,n] = size(im_patch);

%% mosaic 1st- and 2nd-order horizontal and vertical gradient coupuation

% Generate the spectral correlation matrix of each pixel in a mosaic period corresponding to im_patch
weights_1(:,:,:) = mosaic.mosaic.layers{1,1}.weights_SpaNeiSpew15_5(xs,ys,:);
w_spe = permute(weights_1(1:5,1:5,:),[1,2,3]);

for i = 1:5
    for j=1:5
        w_spe1 = reshape(w_spe(i,j,:),[5,5]);
        B=rot90(w_spe1,-2);
        im_spc1 = conv2(im_patch,B,'same')./sum(sum(abs(B)));
        im_spe1(i:5:m,j:5:n) = im_spc1(i:5:m,j:5:n);  
    end
end

%1st- and 2nd-order horizontal and vertical gradient operators
spay = [-1,-2,-3,-2,-1;
    -2,-4,-6,-4,-2;
    0,0,0,0,0;
    2,4,6,4,2;
    1,2,3,2,1];
spax = [-1,-2,0,2,1;
    -2,-4,0,4,2;
    -3,-6,0,6,3;
    -2,-4,0,4,2;
    -1,-2,0,2,1];
spay_2 = [1,2,3,2,1;
    2,4,6,4,2;
    -6,-12,-18,-12,-6;
    2,4,6,4,2;
    1,2,3,2,1];
spax_2 = [1,2,-6,2,1;
    2,4,-12,4,2;
    3,6,-18,6,3;
    2,4,-12,4,2;
    1,2,-6,2,1];


% Calculate the mosaic 1st- and 2nd-order horizontal and vertical gradient
im_spax = conv2(im_spe1,spax,'same')./sum(sum(abs(spax)));
im_spay = conv2(im_spe1,spay,'same')./sum(sum(abs(spay)));
im_spe2=wiener2(double(im_spe1),[5 5]);
im_spax_2 = conv2(im_spe2,spax_2,'same')./sum(sum(abs(spax_2)));
im_spay_2 = conv2(im_spe2,spay_2,'same')./sum(sum(abs(spay_2)));


%% mosaic 1st- and 2nd-order spectral gradient computation

% spatial correlation matrix of each pixel in im_patch
spa = [1,2,3,2,1;2,4,4,4,2;3,6,9,6,3;2,4,4,4,2;1,2,3,2,1];

% Generate the 1st- and 2nd-order spectral gradient operators of each pixel in a mosaic period corresponding to im_patch
weightsl1_1(:,:,:) = mosaic.mosaic.layers{1,1}.weights_SpeNeispe5_51(xs,ys,:);
weightsl2_1(:,:,:) = mosaic.mosaic.layers{1,1}.weights_SpeNeispe5_52(xs,ys,:);
wl1 = permute(weightsl1_1(1:5,1:5,:),[1,2,3]);
wl2 = permute(weightsl2_1(1:5,1:5,:),[1,2,3]);

% calculate the mosaic 1st- and 2nd-order spectral gradient
im_l1 = conv2(im_patch,spa,'same')./sum(sum(abs(spa)));
im_l2 = wiener2(double(im_l1),[5 5]);

for i = 1:5
    for j=1:5
        w1l1 = reshape(wl1(i,j,:),[5,5]);
        w1l2 = reshape(wl2(i,j,:),[5,5]);        
        Bl1=rot90(w1l1,-2);
        Bl2=rot90(w1l2,-2);        
        im_spc1l1 = conv2(im_l1,Bl1,'same')./sum(sum(abs(Bl1)));
        im_spc1l2 = conv2(im_l2,Bl2,'same')./sum(sum(abs(Bl2)));
        im_spe1l1(i:5:m,j:5:n) = im_spc1l1(i:5:m,j:5:n);  
        im_spe1l2(i:5:m,j:5:n) = im_spc1l2(i:5:m,j:5:n);  
    end
end


im_repatch = mexResize(im_patch, model_sz, 'auto');
im_spax = mexResize(im_spax, model_sz, 'auto'); 
im_spay = mexResize(im_spay, model_sz, 'auto');
im_spax_2 = mexResize(im_spax_2, model_sz, 'auto'); 
im_spay_2 = mexResize(im_spay_2, model_sz, 'auto');
im_spe1l1 = mexResize(im_spe1l1, model_sz, 'auto');
im_spe1l2 = mexResize(im_spe1l2, model_sz, 'auto');

Ix = im_spax;
Iy = im_spay;
Ix_2 = im_spax_2;
Iy_2 = im_spay_2;
Il1 = im_spe1l1;
Il2 = im_spe1l2;


end
