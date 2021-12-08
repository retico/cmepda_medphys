function roughborder= max_var_points_interp(normalized,ROI,Ray_masks,NL,nhood)
% The max_var_points_interp function creates a roughborder of the mass
% constituted by the points on the radial lines with maximum standard
% deviation

J = stdfilt(normalized,nhood);
%figure,imagesc(J),colormap(gray)

B_points=[];
roughborder=zeros(size(normalized));

for it=1:NL
    
    Jmasked=J.*Ray_masks(:,:,it);
    Jmasked=Jmasked.*imbinarize(ROI); % We confine the result within the ROI
    
    [c1, c2]= find(Jmasked==max(Jmasked(:)));
    B_points=[B_points; c1(1) c2(1) J(c1(1),c2(1))];
    
    roughborder(c1(1),c2(1))=normalized(c1(1),c2(1));
end

B_points=[B_points; B_points(1,:) ]; % to close the boundary


[latout,lonout]=interpm(B_points(:,1),B_points(:,2),1); 
% interpm requires mapping toolbox
% interpm densifies latitude-longitude sampling in lines or polygons

for i=1:size(latout)
    roughborder(round(latout(i)),round(lonout(i)))=1;
end
roughborder=roughborder.*imbinarize(ROI);
%figure,imagesc(roughborder),colormap(gray),title('rough border')


