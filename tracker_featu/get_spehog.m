function xl_spe = get_spehog(Ix,Iy,Il1,im_patch,cell_size)

Ib1 = single(Il1);
Ib1(find(isnan(Ib1)==1)) = 0;
Mb1=sqrt(Ix.^2+Iy.^2+Ib1.^2);            
Ixy1 = sqrt(Ix.^2+Iy.^2)./2;
cx = sign(Ix);cy = sign(Iy);
cxy = cx.*cy;
Ixy = Ixy1.*cxy;
Ob1 = atan2(Ib1,Ixy);


binSize=cell_size;nOrients=9; clip=.2; crop=0; softBin = -1; useHog = 2; b = binSize;
ang=Ob1;
ang=mod(ang*180/pi,360);   
if Ixy<0              
    if ang<90               
        ang=ang+180;        
    end
    if ang>270              
        ang=ang-180;        
    end
end

Ob1= (ang./360)*2*pi;
Hb1 = gradientMex('gradientHist',Mb1,Ob1,binSize,nOrients,softBin,useHog,clip);


if( crop ), e=mod(size(im_patch),b)<b/2; Hb1=Hb1(2:end-e(1),2:end-e(2),:); end

xl_spe = Hb1(:,:,1:32);

xl_spe(:,:,32) = cell_grayscale(im_patch,cell_size);

end