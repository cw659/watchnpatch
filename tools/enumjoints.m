function id = enumjoints(jointname)
% Enumerate joint names with id
%
%   Input: 
%     jointname : joint name;
%   Output:
%     id: id of the joint.
%

switch jointname
    % Base of the spine.
    case 'SpineBase'
        id = 1;
    % Middle of the spine.
    case  'SpineMid'
        id = 2;
    %Neck.
    case  'Neck'
        id = 3;
    %Head.
    case  'Head' 
        id = 4;
    %Left shoulder.
    case  'ShoulderLeft'
        id = 5;
    %Left elbow.
    case  'ElbowLeft'
        id = 6;
    %Left wrist.
    case  'WristLeft'
        id = 7;
    %Left hand.
    case  'HandLeft'
        id = 8;
    %Right shoulder.
    case 'ShoulderRight'
        id = 9;
    %Right elbow.
    case  'ElbowRight'
        id = 10;
    %Right wrist.
    case  'WristRight'
        id = 11;
    %Right hand.
    case  'HandRight'
        id = 12;
    %Left hip.
    case  'HipLeft'
        id = 13;
    %Left knee.
    case  'KneeLeft'
        id = 14;
    %Left ankle.
    case  'AnkleLeft'
        id = 15;
    %Left foot.
    case  'FootLeft'
        id = 16;
    %Right hip.
    case  'HipRight'
        id = 17;
    %Right knee.
    case  'KneeRight'
        id = 18;
    %Right ankle.
    case  'AnkleRight'
        id = 19;
    %Right foot.
    case  'FootRight'
        id = 20;
    %Between the shoulders on the spine.
    case  'SpineShoulder'
        id = 21;
    %Tip of the left hand.
    case  'HandTipLeft'
        id = 22;
    %Left thumb.
    case  'ThumbLeft'
        id = 23;
    %Tip of the right hand.
    case  'HandTipRight'
        id = 24;
    %Right thumb.
    case  'ThumbRight'
        id = 25;
end