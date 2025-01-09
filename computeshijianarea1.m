function shijianresult=computeshijianarea(cameraseting,cameraParams,problem,b,shijianmidu)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
A = [];
for i=1:length(cameraseting(:,1))
    
        cameraParams.pos = cameraseting(i,1:2);
        cameraParams.yaw = cameraseting(i,3);

        Area = ComputeOccupancyGrid2(problem,cameraParams);
        A = cat(2,A,Area & b);
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
%shijianresult = sum(occu,1);
ar=occu .* shijianmidu ;
shijianresult= sum(ar,1);


end

