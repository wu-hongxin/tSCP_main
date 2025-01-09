function Area = ComputeOccupancyGridfov1(varargin)
narginchk(1,2);

% resemble overloading
% scene occupied grid
if nargin == 1
    problem = varargin{1};
    
    sample_x = problem.sample_lbx:3:problem.sample_ubx;
    sample_y = problem.sample_lby:3:problem.sample_uby;
    [SX,SY] = meshgrid(sample_x,sample_y);
    SX = reshape(SX,[],1);
    SY = reshape(SY,[],1);
    M = [SX SY];
    Area = PointsInsidePolygon1(problem.EL,M);
    
% camera view grid
elseif nargin == 2
    problem = varargin{1};
    cameraParams = varargin{2};
    sight = cameraParams.sight;
    
    sample_x = problem.sample_lbx:3:problem.sample_ubx;
    sample_y = problem.sample_lby:3:problem.sample_uby;
    [SX,SY] = meshgrid(sample_x,sample_y);
    SX = reshape(SX,[],1);
    SY = reshape(SY,[],1);
    M = [SX SY];
    Area = PointsInsideVisibility1(problem.EL,cameraParams,M,sight);
end