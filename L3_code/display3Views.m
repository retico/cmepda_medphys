function display3Views(V_3D,P)
% Display the axial, coronal and sagittal views of a volume, intersectiong
% at point P
figure;
subplot(2,2,1:2)
imagesc(fliplr(V_3D(:,:,P(3))))
subplot(2,2,3)
imagesc(fliplr(rot90(squeeze(V_3D(P(1),:,:)))));
subplot(2,2,4)
imagesc(rot90(squeeze(V_3D(:,P(2),:))));
