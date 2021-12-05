function shape = diamond(r,c,rad,M)
% Returns an image MxM with a diamond of size rad.
% Input arguments: 
% the row (r) and column (c) image position, 
% the object size (rad), 
% and the squared image matrix size (M) 

vec=1:M;
[C,R]=meshgrid(vec,vec);
deltaC = abs(C-c);
deltaR = abs(R-r);

distance = deltaC + deltaR;
shape = (distance<=rad);

% One of the advantage of using this formulation is that it is easy 
% to change the shape of the object to design.
% We can change the shape by defining different distance measures, e.g. try
%distance = deltaC.^2 + deltaR.^2;
%shape = (distance<=rad^2);