% Fitness Function
function L = ourSetCoverageProblem1(x,CandidateCameraPos,problem,cameraParams,b,shijianmidu,r)
%CandidateCameraPos£º
%problem£º
%cameraParams£º
%b£º
% N = sum(x);     % quantity of Cameras

% minimize coverage zone between cameras
A = [];
for i=1:length(x)
    if x(i)==1
        cameraParams.pos = CandidateCameraPos(i,1:2);
        cameraParams.yaw = CandidateCameraPos(i,3);

        Area = myComputeOccupancyGrid1(r,problem,cameraParams);
        A = cat(2,A,Area & b);
    end
end

if numel(A)==0
    A = zeros(numel(b),1);
end
occu = sum(A,2);
for j=1:length(occu)
    if occu(j) >= 2
        occu(j)=1;
    end
end
%%%
ar=occu .* shijianmidu ;
L = -sum(ar,1);

%occu = sum(A,2);
%L = norm(occu-b);
