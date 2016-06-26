function drgb = get_depth_world_rgb(rgb, depth, pcloud)
% Get rgb in depth world by mapping rgb coordinates to depth coordinates
%
%   Input: 
%     rgb : rgb image;
%     depth : depth image, unit: cm;
%     pcloud : point cloud in depth world, unit: cm;
%   Output:
%     drgb: rgb image in depth world.
%

    rp3d = depth_world2rgb_world(pcloud); %depth world pointcloud to rgb world
    [xProj, yProj] = rgb_world2rgb_plane(rp3d); %get mapped rgb coordinates of depth points

    %check valid mapped points
    xProj = round(xProj);
    yProj = round(yProj);

    [CH, CW] = size(rgb);
    goodDinds = find(xProj > 0 &  xProj <= CW & ...
                     yProj > 0 &  yProj <= CH & ...
                     depth(:)~=0);
    goodCinds = sub2ind([CH CW], yProj(goodDinds), xProj(goodDinds));


    R = rgb(:,:,1);
    G = rgb(:,:,2);
    B = rgb(:,:,3);
    dR = zeros(size(depth));
    dG = zeros(size(depth));
    dB = zeros(size(depth));
    dR(goodDinds) = R(goodCinds);
    dG(goodDinds) = G(goodCinds);
    dB(goodDinds) = B(goodCinds);
    drgb = zeros(size(depth,1),size(depth,2),3);
    drgb(:,:,1)=dR;
    drgb(:,:,2)=dG;
    drgb(:,:,3)=dB;
    drgb = uint8(drgb);

    

end

