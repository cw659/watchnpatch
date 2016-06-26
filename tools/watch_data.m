% read single frame from video and visualize it
% including:
%   convert depth to depth world pointcould;
%   map rgb world coordinates to depth world coordinates;
%   visualize human body in both rgb and depth image;
%   visualize colored 3d point cloud;
%   visualize human joints in 3d point cloud.

clear;clc;
close all
datapath='./data_sample/';

frameid = 20; 

rgb = imread([datapath 'rgbjpg/', num2str(frameid,'%04d') '.jpg']);
load([datapath 'depth/', num2str(frameid,'%04d') '.mat']);
load([datapath 'body.mat']);

%% get tracked body
for i = 1:6
    if body{frameid,i}.isBodyTracked == 1
        joints = body{frameid,i}.joints;
        break
    end
end

%% depth to depth world pointcloud
pcloud = depth_plane2depth_world(depth); 

%% get rgb in depth world by mapping rgb world coordinates to depth world coordinates
drgb = get_depth_world_rgb(rgb, depth, pcloud);


%% visualization
figure; imshow(rgb); title('RGB image');
figure; imshow(depth/max(depth(:))); title('Depth image');
figure; imshow(drgb); title('Mapped RGB image in Depth Space');
visualize_human_rgb(joints, rgb); title('Tracked Human Body in RGB image');
visualize_human_depth(joints, depth); title('Tracked Human Body in Depth image');

figure;
visualize_point_cloud(pcloud, reshape(drgb, [size(drgb,1)*size(drgb,2) 3])', 20); title('Colored 3D point cloud');

figure;
visualize_joints(pcloud, joints); title('Human joints in 3D point cloud');
