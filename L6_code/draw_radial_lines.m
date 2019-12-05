function  Ray_masks=draw_radial_lines(ROI,center,R,NL)
% The draw_radial_lines function creates a binary mask of size ROI, where NL radial lines
% of lenght R are depicted starting for the ROI center

ROI_lines=ROI;
theta= linspace(0,2*pi,NL);

Ray_masks=[];

for it=1:NL
    
    rho=1:R;
    [ii,jj] = pol2cart(theta(it),rho) ;
    
    iir=center(1)+round(ii);
    jjr=center(2)+round(jj);
    
    line1=[(iir') (jjr')];
    
    for il=1:size(line1,1)
        ROI_lines( line1(il,1),line1(il,2))=0;
    end
    
    Ray_mask=zeros(size(ROI));
    for il=1:size(line1,1)
        Ray_mask( line1(il,1),line1(il,2))=1;
    end
    Ray_masks=cat(3,Ray_masks,Ray_mask);
end
