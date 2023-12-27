function s = skew(x)
% Input:
% x : 3x1
% 
% Output:
%       - S is a 3x3 matrix with the form:
%         _        _
%        |0 -a3  a2 |
%        |a3  0 -a1 |
%        |-a2 a1  0 |
%        -          -
%
s = [ 0           -x(3)   x(2); 
      x(3)   0           -x(1);  
	 -x(2)   x(1)   0 ];