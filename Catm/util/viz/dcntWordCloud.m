function dcntWordCloud(fid, nkw, words)
% Finds the top N words for each topic and stores them in a text file
% dcnt = structure file that contains the learned parameters
% words = cell array of vocabulary associated with dataset
% fname = savefile of the top words

% Grab number of topics
K = size(nkw,1);
% Initialize data structure
topic = cell(K,1);
% Number of Top words
W = 100;

% Grab matrix of word counts for each topic
fid3 = fopen(fid, 'w+');
nk = sum(nkw,2);
nkp = nk(1:K) ./ sum(nk(1:K));


fprintf(fid3, '%s\n', 'var topicid = [');
for k=1:K,
    if (k<K),
        fprintf( fid3, '%s', ['"topic',num2str(k),'",'] );
    else
        fprintf( fid3, '%s', ['"topic',num2str(k),'"];'] );
    end
end

fprintf(fid3, '%s\n', 'var topicmass = [{');
for k=1:K,
     if (k < K),
        fprintf(fid3, '%s', ['topic',num2str(k),':',num2str(round(nkp(k)*500)+1),' , ']);
     else
        fprintf(fid3, '%s', ['topic',num2str(k),':',num2str(round(nkp(k)*500)+1),' }]; ']);
    end
end

fprintf(fid3, '%s\n', 'var topw = [');
for k=1:K,
    [~, wInd]= sort(nkw(k,:),'descend');
    topw = wInd(1:W);
    topic{k} = words(topw);
    pw = nkw(k, topw) ./ repmat(nk(k), 1, length(topw));
    
    % Print top N words
    fprintf(fid3, '%s', '[');
    for w= 1: W,
       % fprintf(fid1, '%s\t', topic{k}{w});
        if ( w < W),
            fprintf(fid3, '%s', [ '["', topic{k}{w}, '",', num2str(pw(w)*500), ',', num2str(topw(w)), '],'] );
        else
            fprintf(fid3, '%s', [ '["', topic{k}{w}, '",', num2str(pw(w)*500), ',', num2str(topw(w)), ']'] );            
        end
    end
    
    if (k < K),
        fprintf(fid3, '%s\n','],');
    else
        fprintf(fid3, '%s\n', ']];');
    end
end

fclose('all');
