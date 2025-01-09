function Area = myComputeOccupancyGrid1(varargin)
narginchk(1,3);

% resemble overloading
% scene occupied grid
if nargin == 2
    r=varargin{1};
    problem = varargin{2};
    
    sample_x = problem.sample_lbx:r:problem.sample_ubx;
    sample_y = problem.sample_lby:r:problem.sample_uby;
    [SX,SY] = meshgrid(sample_x,sample_y);
    SX = reshape(SX,[],1);
    SY = reshape(SY,[],1);
    M = [SX SY];
    Area = PointsInsidePolygon1(problem.EL,M);
    
% camera view grid
elseif nargin == 3
    r=varargin{1};
    problem = varargin{2};
    cameraParams = varargin{3};
    sight = cameraParams.sight;
    
    sample_x = problem.sample_lbx:r:problem.sample_ubx;
    sample_y = problem.sample_lby:r:problem.sample_uby;
    [SX,SY] = meshgrid(sample_x,sample_y);
    SX = reshape(SX,[],1);
    SY = reshape(SY,[],1);
    M = [SX SY];
    Area = PointsInsideVisibility1(problem.EL,cameraParams,M,sight);
end