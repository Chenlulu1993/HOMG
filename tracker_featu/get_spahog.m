function [xl_spa] = get_spahog(Ix,Iy,im_patch,cell_size)
Ix = single(Ix);Iy = single(Iy);
 M=sqrt(Ix.^2+Iy.^2); 
 O=atan2(Iy,Ix);
binSize=cell_size;nOrients=9; clip=.2; crop=0; softBin = -1; useHog = 2; b = binSize;
ang=O;


ang=mod(ang*180/pi,360);    
if Ix<0             
    if ang<90               
        ang=ang+180;       
    end
    if ang>270             
        ang=ang-180;       
    end
end
% ang=ang+0.0000001;
O= (ang./360)*2*pi;

H = gradientMex('gradientHist',M,O,binSize,nOrients,softBin,useHog,clip);

if( crop ), e = mod(size(I),b)<b/2; H=H(2:end-e(1),2:end-e(2),:); end
 
xl_spa = H;
xl_spa(:,:,32) = cell_grayscale(im_patch,cell_size);


end