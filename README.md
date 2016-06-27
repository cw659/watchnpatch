# watchnpatch

Catm: Causal topic model.

Run the training.

catm = CatmRun(savefid, dataobj, K, W, N, J, T, S)

K: number of topics

W: the number of unique words

N: number of sample rounds

J: number of LDA initializations

T: number of times V is sampled

S: random seed

dataobj.data.doc: a cell of docs, each of which is a word index vector

dataobj.data.rtime: a cell of doc's relative time, each of which is nword*nword matrix

Tools: kinect v2 data read and visiualization tool.

watch_data.m - read single frame from video and visualize it, contains all functions in the tool

depth_plane2depth_world.m - convert depth to depth world pointcould;

get_depth_world_rgb.m - map rgb world coordinates to depth world coordinates;

visualize_human_rgb.m - visualize human body in rgb image;

visualize_human_depth.m - visualize human body in depth image;

visualize_point_cloud.m - visualize colored 3d point cloud;

visualize_joints.m - visualize human joints in 3d point cloud.
