function visualize_joints(pcloud, joints)
% Visualize tracked skeleton in point cloud
%
%   Input:
%     pcloud : point cloud in depth world, unit: cm
%     body: tracked human joints
%

z=rand(50,3)*0.05;
jointcor = [];

for j = 1:length(joints)
    if sum(abs(joints{j}.pcloud))~=0
        jointcor = [jointcor;joints{j}.pcloud/1000];
    end
end


visualize_point_cloud(pcloud/1000,100*ones(size(pcloud))',20);
hold on;

for i = 1:size(jointcor,1)
    scatter3(jointcor(i,1),jointcor(i,2),jointcor(i,3),20,3);
end

end

