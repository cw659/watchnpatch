function visualize_point_cloud(pcloud, rgb, sample_gap)
% Visualize colored point cloud
%
%   Input:
%     pcloud : point cloud in depth world, unit: cm;
%     rgb: rgb image;
%     sample_gap: sample gap for visualization.
%
    if ~exist('sample_gap','var')
        sample_gap = 50;
    end
    pcloud = pcloud';
    pcloud = pcloud(:,1:sample_gap:end);
    rgb = rgb(:,1:sample_gap:end);
    scatter3(pcloud(1,:), pcloud(2,:), pcloud(3,:), ones(1,size(pcloud,2)), double(rgb)'/255, 'filled');
    axis equal
    axis tight
end