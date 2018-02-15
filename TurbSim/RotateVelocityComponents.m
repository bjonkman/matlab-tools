function [velocity, alpha_h, alpha_v] = RotateVelocityComponents( velocity, alpha_h_in, alpha_v_in )
%
% Input:
%   velocity(time,component,iy,iz)
%       - aligned with geographical x-y-z coordinates
%   alpha_h_in(1:nz) (optional)
%       - horizontal angle, in degrees, specified at each height 
%   alpha_v (optional)
%       - vertical angle, in degrees
%
% Output:
%   velocity 
%       - rotated by calculated horizontal & vertical angles,
%         now aligned with the mean wind stream
%   alpha_h(1:nz)
%       - horizontal angle, in degrees, specified at each height 
%   alpha_v(1:nz)
%       - vertical angle, in degrees, specified at each height

% ---------------------------------------
% allocate variables & get default values
% ---------------------------------------
[nt, nc, ny, nz] = size(velocity);

alpha_h          = zeros(nz,1);
alpha_v          = zeros(nz,1);
horizontal_angle = zeros(ny,1);
vertical_angle   = zeros(ny,1);

% --------------------------
% get the angles of rotation
% --------------------------
if nargin > 1
    if length(alpha_h_in) == nz
        alpha_h = alpha_h_in;
    else
        alpha_h(:) = alpha_h_in;
    end
    if length(alpha_v_in) == nz
        alpha_v = alpha_v_in;
    else
        alpha_v(:) = alpha_v_in;
    end

    alpha_v = alpha_v*pi/180;
    alpha_h = alpha_h*pi/180;    
else
    
    for iz = 1:nz    
        for iy = 1:ny
            u  = velocity(:, 1, iy, iz);
            v  = velocity(:, 2, iy, iz);
            w  = velocity(:, 3, iy, iz);

%             uh = sqrt( u.^2 + v.^2 );
%             horizontal_angle(iy) = mean( atan2( v, u  ) );
%             vertical_angle(iy)   = mean( atan2( w, uh ) );

             horizontal_angle(iy) = atan2( mean(v), mean(u)  );
             vertical_angle(iy)   = atan2( mean(w), sqrt(mean(u)^2+mean(v)^2) );
            
        end 
        alpha_h( iz) = mean(horizontal_angle);  
        alpha_v( iz) = mean(vertical_angle);   %this works only for close angles (not through +/- pi)
%         alpha_v1(iz) = mean(vertical_angle);    
    end
%     alpha_v = mean(alpha_v1); 
    
end

% ------------------------------
% rotate the velocity components
% ------------------------------

for iz = 1:nz

        % the transformation matrix
        
    tf = [  cos(alpha_h(iz))*cos(alpha_v(iz))   sin(alpha_h(iz))*cos(alpha_v(iz))  sin(alpha_v(iz));
           -sin(alpha_h(iz))                    cos(alpha_h(iz))                   0;
           -cos(alpha_h(iz))*sin(alpha_v(iz))  -sin(alpha_h(iz))*sin(alpha_v(iz))  cos(alpha_v(iz)) ];
             
    for iy = 1:ny        
        for it = 1:nt
            velocity(it, :, iy, iz) = tf * squeeze(velocity(it, :, iy, iz))';            
        end
    end   
    
end

alpha_v = alpha_v*180/pi;
alpha_h = alpha_h*180/pi;
