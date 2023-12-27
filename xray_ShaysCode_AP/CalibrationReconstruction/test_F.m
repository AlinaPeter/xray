% Verify that the estimation matrix is correct
%
F = rand(3,3);
[U,S,V]=svd(F);
S(3,3)=0;
F=U*S*V';

N = 20;
p1=[rand(2,N); ones(1,N)];
Z=F*p1;
p2 = 1./Z;
p2(3,:) = -p2(3,:)*2;

p2(1,:) = p2(1,:) ./ p2(3,:);
p2(2,:) = p2(2,:) ./ p2(3,:);
p2(3,:) = 1;

diag(p2'*F*p1)

[Fest,P1,P2]=fundamental_from_correspondence(p1,p2)


diag(p2'*Fest*p1)
