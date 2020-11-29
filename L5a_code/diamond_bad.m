function shape = diamond_bad(r,c,rad,M)
% input anguments:
% the row (r) and column (c) image position,
% the object size (rad),
% and the squared image matrix size (M)

shape=zeros(M);
offset = 0;

rmin=max(r-rad,1);
rmax=min(r+rad,M);

for ri=[rmin:rmax]
    
    leftI = max(c-offset,1);
    rightI = min(c+offset,M);
    
    shape(ri,leftI:rightI)=1;
    
    if(ri<r)
        offset = offset + 1;
    else
        offset = offset - 1;
    end
end