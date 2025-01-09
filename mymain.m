clc,clear,close all;

%% Scene Setup
% Edge List
ELC = [[0 0,1500 0];
    [1500 0,1500 1500];
    [1500 1500,0 1500];
    [0 1500,0 0]];
% Define the Obstacle
%obstacle = [[900 1221,900 1946];];
%% Floor Plan & Camera Parameters
%EL = [ELC;obstacle];
EL = ELC;
%EL = ELC;
x = [20 15];  % 3D Coord [x y ]
cameraParams.pos = x;
cameraParams.yaw = 45;   % direct right as 0 degree (in plane)
cameraParams.fovy = 90;
%cameraParams.aspect_ratio = 1.0;
cameraParams.sight =500; % sight distance
problem.EL = EL;
problem.step = 50;
problem.sample_lbx = 0;
problem.sample_ubx = 1500;
problem.sample_lby = 0;
problem.sample_uby = 1500;
problem.sample_yawN = 8;
lengthScene = (problem.sample_ubx - problem.sample_lbx)/problem.step + 1;
widthScene = (problem.sample_uby - problem.sample_lby)/problem.step + 1;
problem.size = [lengthScene widthScene];

yawN = problem.sample_yawN;
sample_x = problem.sample_lbx:problem.step:problem.sample_ubx;%Spatial point sampling
sample_y = problem.sample_lby:problem.step:problem.sample_uby;%Spatial point sampling
step_yaw = 360/yawN;
sample_yaw = 0:step_yaw:360;
sample_yaw(end) = [];   % delete 360 element

[SX,SY] = meshgrid(sample_x,sample_y);
SX = reshape(SX,[],1);
SY = reshape(SY,[],1);
m = [SX SY];%253*2
M = [];
for i = 1:length(sample_yaw)
	tmp = sample_yaw(i) * ones(length(m),1);
    tmp = cat(2,m,tmp);
    M = cat(1,M,tmp);
end
%%%The location in the edge area where the camera deployment is available
CandidateCameraConfig = SamplePointsNearEdges1(EL,50,M);%
%%%The location where the camera deployment is available in a non-edge area
newstep=100
sample_x1 = problem.sample_lbx:newstep:problem.sample_ubx;%
sample_y1 = problem.sample_lby:newstep:problem.sample_uby;%

[SX1,SY1] = meshgrid(sample_x1,sample_y1);
SX1 = reshape(SX1,[],1);
SY1 = reshape(SY1,[],1);
m1 = [SX1 SY1];%253*2


CandidateCameraConfigindex = myComputeOccupancyGrid1(newstep,problem);%
indexnum=0;
for k=1:length(CandidateCameraConfigindex(:,1))
    if CandidateCameraConfigindex(k,1)==1
        indexnum=indexnum+1;
        CandidateCameraConfig0(indexnum,1:2)=m1(k,1:2);
    end
end
shunum=0;
newCandidateCameraConfig0=[];
for ck=1:length(CandidateCameraConfig0(:,1))
    xx=CandidateCameraConfig0(ck,1);
    yy=CandidateCameraConfig0(ck,2);
    flagg=1;
    for ck1=1:length(CandidateCameraConfig(:,1))
        xx1=CandidateCameraConfig(ck1,1);
        yy1=CandidateCameraConfig(ck1,2);
        if xx1==xx & yy1==yy
             flagg=0;
        end
    end
    if flagg==1
       shunum= shunum+1;
       newCandidateCameraConfig0(shunum,1)=CandidateCameraConfig0(ck,1);
       newCandidateCameraConfig0(shunum,2)=CandidateCameraConfig0(ck,2);
    end
    
end

CandidateCameraConfig1=[];
for i = 1:length(sample_yaw)
	tmp1 = sample_yaw(i) * ones(length(newCandidateCameraConfig0),1);
    tmp1 = cat(2,newCandidateCameraConfig0,tmp1);
    CandidateCameraConfig1 = cat(1,CandidateCameraConfig1,tmp1);
end

%%%The set of all solutions
finalCandidateCameraConfig=[];
finalCandidateCameraConfig=cat(1,CandidateCameraConfig,CandidateCameraConfig1);
finalCandidateCameraConfig = unique(finalCandidateCameraConfig,'rows');

%% Plot the results

nVar = length(finalCandidateCameraConfig);
samplecoveragestep=50;%
coveragesample_x = problem.sample_lbx:samplecoveragestep:problem.sample_ubx;
coveragesample_y = problem.sample_lby:samplecoveragestep:problem.sample_uby;
[SX1,SY1] = meshgrid(coveragesample_x,coveragesample_y);
SX1 = reshape(SX1,[],1);
SY1 = reshape(SY1,[],1);
coverageM = [SX1 SY1];
coverageb1 = myComputeOccupancyGrid1(samplecoveragestep,problem);%
msize=size(coverageb1,1);


%% Target density

a01=4000;
a02=1500;
a11=813;
a12=28728;
asum=a01+a02+a11+a12
a01=a01/asum;
a02=a02/asum;
a11=a11/asum;
a12=a12/asum;

shijianmidu=computeshijianmidu(coverageM,coverageb1);
numshijianmidu=size(shijianmidu,1);
%% Plot the results

% only choose one config in each position --> Aeq * x' <= beq
cameraPosNum = nVar/(yawN);
degreeOfFreedom = yawN;
Aueq = zeros(cameraPosNum,nVar);
for i=1:cameraPosNum
    for j=1:degreeOfFreedom
        Aueq(i,(i-1)*degreeOfFreedom+j)=1;
    end
end
bueq = ones(cameraPosNum,1);
%% Run GA
tic;
lb = zeros(1,nVar);
ub = ones(1,nVar);
intintices = (1:nVar);
initialx = zeros(1,nVar);

%% 
options = optimoptions(@ga,                              'InitialPopulationMatrix',initialx, ...
                            'Display','iter', ...
                            'CrossoverFraction',0.75, ...
                            'MaxStallGenerations',50, ...
                            'PopulationSize',1000,...
                            'Generations', 1000);
f = @(x)ourSetCoverageProblem2(x,finalCandidateCameraConfig,problem,cameraParams,coverageb1,shijianmidu,samplecoveragestep);
%% Plot the results
%f(initialx)
[x,fval] = ga(f, nVar, Aueq, bueq, [], [], lb, ub, @AnsConstrains, intintices, options);
toc;
%% Plot the results


ll=0;
cmaxcamera=[];
% Floor Plan & Camera Parameters
probleb = ComputeOccupancyGridfov1(problem);

for i=1:numel(x)
    if x(i)==1
        ll=ll+1;
        cmaxcamera(ll,1:2)= finalCandidateCameraConfig(i,1:2);
        cmaxcamera(ll,3)= finalCandidateCameraConfig(i,3);
        disp(i)
        cameraParams.pos = finalCandidateCameraConfig(i,1:2);
        cameraParams.yaw = finalCandidateCameraConfig(i,3);
        
        disp('Camera parameter')
        disp(cameraParams);

        
        
        
       
    end
end



sample_x = problem.sample_lbx:1:problem.sample_ubx;
sample_y = problem.sample_lby:1:problem.sample_uby;
[SX,SY] = meshgrid(sample_x,sample_y);
SX = reshape(SX,[],1);
SY = reshape(SY,[],1);
M1 = [SX SY];

coveragebb = myComputeOccupancyGrid1(1,problem);
finallcoerage=computearea1(cmaxcamera,cameraParams,problem,coveragebb);

probleb=myComputeOccupancyGrid1(1,problem);
sumaera=sum(probleb,1);
disp('Area coverage£º')
fugailv=finallcoerage/sumaera;
disp(fugailv)
shijianmidu1=computeshijianmidu(M1,coveragebb);
shijianresult=computeshijianarea1(cmaxcamera,cameraParams,problem,coveragebb,shijianmidu1);

totalshijian=shijianmidu1.*probleb;
totalshijian=sum(totalshijian,1);

disp('Target coverage£º')
shijianfugailv=shijianresult/totalshijian;
disp(shijianfugailv)





