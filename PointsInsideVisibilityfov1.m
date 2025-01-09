% @params poly is edge list
% @params sight is clear sight radius
% points here are 3 dimentional
function flags = PointsInsideVisibilityfov1(poly,camera,p,sight)
%poly:problem.EL
%camera:cameraParams
%p:cameraParams
%sight:cameraParams.sight

    pn = size(p,1);
    flags = zeros(pn,1);

    for i =1:pn
        % sight collide with obstacle
        if IntersectWithEL(poly,camera.pos,p(i,:))
            continue;
        
        end
        
        % stuff will be hard to distinguish
        if norm(camera.pos-p(i,:))>sight
           continue;
        end
        pos=camera.pos;
        x1=pos(1);
        y1=pos(2);
        x2=p(i,1);
        y2=p(i,2);
        angle = angleoutput(x1,y1,x2,y2);
        yawan=camera.yaw;
        fov=camera.fovy;
        anglelow=mod(yawan-fov/2,360); 
        anglehigh=yawan+fov/2;
        if yawan==0
            
            if angle>=anglelow && angle<=360
                flags(i) = 1;
            end
            if angle<=anglehigh && angle>0
                flags(i) = 1;
            end
            
        else
            
            if angle>=anglelow && angle<=anglehigh
                flags(i) = 1;
            end
            
        end
        
        
        % the coord of points inside view is within the cube of [-1,1]
        %t = CoordConvertion(camera,p(i,:));
        %if t(4) ~= 0
            %t = t/t(4);
        %end
        %if t(1)<=1 && t(1)>=-1 && t(2)<=1 && t(2)>=-1 && t(3)<=1 && t(3)>=-1
            %flags(i) = 1;
        %end
    end

end

function coord = CoordConvertion(cameraParams,p)
%        t = CoordConvertion(camera,p(i,:));
    p = [p 1];
    pos = cameraParams.pos;
    yaw = deg2rad(cameraParams.yaw);
    fovy = deg2rad(cameraParams.fovy);
    aspect_ratio = cameraParams.aspect_ratio;
    % Transformation
    T = eye(3);
    T(1,3) = -pos(1);
    T(2,3) = -pos(2);
   
    
    g = zeros(1,2);
    g(1) = cos(yaw);
    g(2) = sin(yaw);
    %
    R = eye(4);
    R(1,1:3) = g;
    R(2,1:3) = t;
    R(3,1:3) = -g;
    
    top = tan(fovy/2);
    right = top*aspect_ratio;
    
    % Projection
    M1 = eye(4);
    M1(1,1) = 1/right;
    M1(2,2) = 1/top;
    M1(3,3) = 1/1000;
    M2 = eye(4);
    M2(3,4) = 501;
    M_ortho = M1 * M2;
    M_persp_ortho = zeros(4);
    M_persp_ortho(1,1) = -1;
    M_persp_ortho(2,2) = -1;
    M_persp_ortho(4,3) = 1;
    M_persp_ortho(3,3) = -1002;
    M_persp_ortho(3,4) = -1*1001;
    M_persp = M_ortho * M_persp_ortho;
    
    coord = M_persp * R * T * transpose(p);
end

% judge intersection
function flag = IntersectWithEL(poly,origin,p)
%IntersectWithEL(poly,camera.pos,p(i,:))
%poly:
%origin:
%p:
    polyn = size(poly,1);
    A = origin(1:2);
    B = p(1:2);
    flag = 0;
    
    for j=1:polyn
        C = poly(j,1:2);
        D = poly(j,3:4);
        
        if lineIntersectSide(A,B,C,D) && lineIntersectSide(C,D,A,B)
            flag = 1;
            return;
        end
    end
    
end

% judge line intersect with line segment
function flag = lineIntersectSide(A,B,C,D)
    fC = (C(2) - A(2)) * (A(1) - B(1)) - (C(1) - A(1)) * (A(2) - B(2));
    fD = (D(2) - A(2)) * (A(1) - B(1)) - (D(1) - A(1)) * (A(2) - B(2));
    if fC * fD >0
        flag = 0;
    else
        flag = 1;
    end
end

function angle1 = angleoutput(x1,y1,x2,y2)
    x_1=0;
    y_1=0;
    x_2=x2-x1;
    y_2=y2-y1;
    if (x_2>0&y_2==0)
        angle1 =0;
    elseif (x_2==0&y_2>0)
        angle1=90;
    elseif (x_2<0&y_2==0)
        angle1=180;
    elseif (x_2==0&y_2<0)
        angle1=270;
    elseif (x_2>0&y_2>0)
        angle1 =atand(y_2/x_2);
    elseif (x_2<0&y_2>0)
        angle1 =180-atand(y_2/abs(x_2));
    elseif (x_2<0&y_2<0)
        angle1 =180+atand(abs(y_2)/abs(x_2));
    elseif (x_2>0&y_2<0)
        angle1 =360-atand(abs(y_2)/abs(x_2));
    else
        angle1 =  0; 
    end
end
