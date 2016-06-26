%Camera parameters from calibration

% The maximum depth used, in meters.
maxDepth = 5000;

% RGB Intrinsic Parameters
fx_rgb = 1050.60702;  
fy_rgb = 1052.77088;
cx_rgb = 983.72076;
cy_rgb = 530.46047;

% RGB Distortion Parameters
k1_rgb =  0.02468;                   
k2_rgb = -0.02250;
p1_rgb = -0.00338;
p2_rgb = 0.00482;
k3_rgb = 0.00000;

% Depth Intrinsic Parameters
fx_d = 365.19599;   
fy_d = 365.61839;
cx_d = 266.84507;   
cy_d = 199.14226;

% RGB Distortion Parameters
k1_d = 0.11926;         
k2_d = -0.53343;
p1_d = -0.00021;
p2_d = 0.00730;
k3_d = 0.00000;

% Rotation
R = [0.999971346110444,-0.00756469826720314,0.000286876615262462;0.00756522677983534,0.999969600410407,-0.00188827932806725;-0.000272583630970059,0.00189039550817223,0.999998176049830;];
% R = reshape(R, [3 3]);
% R = inv(R');

% 3D Translation
T=[-56.7170118956704;-0.728510987903765;-3.87867708001932;];
% t_x = -161.204028532217;    
% t_y = -55.9718573944877;
% t_z = 340.728808148412;

