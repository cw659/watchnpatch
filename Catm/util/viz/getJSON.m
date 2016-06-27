%% Create visualizations from output of DCNT
clear all; close all; clc;

%% Load files and vocabulary
% load a cell array of vocabulary words in your model
load('./data/nips-words.mat','words'); 
% load the learned results from a recent experiment
load('./data/nips-results.mat','dcnt'); 
% nkw is a TOPIC x WORD matrix of learned frequency counts of a given word.
nkw = dcnt.var.nkw; 

%% Generate the JSON data file for the topic-word cloud browser
% savepath for the JSON file
fid1 = './dcnt-viz/tw.js';
% the script that generates the data in the requisite JSON format
dcntWordCloud(fid1, nkw, words)

%% Create the JSON data file for the hinton diagram 
% load the correlation matrix between topics
load('./data/nips-results.mat','corrK'); 

% savepath for the JSON file
fid2 = './dcnt-viz/hinton.js';
% Set the number of topics you wish to view the correlations for
K = 20;
% the script that generates the data in the requisite JSON format
dcntHinton(fid2, nkw, corrK, words, K);

%% Create metadata histogram for topics that change over the years
% For the DCNT model, the stacked histogram view represents the weight of
% each topic conditioned on certain features being turned on.

% Load nips training data conditioned on years
load('./data/nips-results-y.mat','dcnt');

% This part is only necessary if you are using the DCNT model and wish to
% generate topics that are conditioned on specific features. 
find = cell(1,12);
for f=1:12,
   find{f} = [1,f+1];
end
pi = genPI(dcnt, find);

% savepath for the JSON file
fid3 = './dcnt-viz/metadata.js';

% labels for the tick mark on the x-axis
flabel = (1988:1999);

% the script that generates the data in the requisite JSON format
dcntMetadata(fid3, nkw, pi, words, flabel);


