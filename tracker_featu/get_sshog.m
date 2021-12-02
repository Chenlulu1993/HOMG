
 function [homg] = get_sshog(im_patch,cell_size, ys,xs, model_sz,mosaic)

% Calculate the mosaic 1st- and 2nd-order horizontal and vertical gradient  
% and the mosaic 1st- and 2nd-order spectral gradient
[im_repatch,Ix,Iy,Ix_2,Iy_2,Il1,Il2] = ss_img(im_patch,ys,xs,model_sz,mosaic);
%Calculate mosaic 1st- and 2nd-order spatial-spectral histogram
xl_spa1 = get_spahog(Ix,Iy,im_repatch,cell_size);
xl_spa_2 = get_spahog(Ix_2,Iy_2,im_repatch,cell_size);
xl_spe1 = get_spehog(Ix,Iy,Il1,im_repatch,cell_size);
xl_spe2 = get_spehog(Ix_2,Iy_2,Il2,im_repatch,cell_size);

% generate HOMG
xl_spa =xl_spa1 +xl_spa_2;xl_spe =xl_spe1 +xl_spe2;
xl_pca = cat(3,xl_spa,xl_spe);
homg = permute(xl_pca,[2 1 3]);

 end
