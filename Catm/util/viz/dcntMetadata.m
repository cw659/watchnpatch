%% Generate test document
function dcntMetadata(fid, nkw, pi, words, flabel)

%% Start generative process
W = 40; % number of words to view
K = size(nkw,1);
% save file
json = fopen(fid, 'w+');

fprintf( json, '%s', 'var labels=[');
for k=1:K,
    if (k<K),
        fprintf( json, '%s', ['"topic', num2str(k) , '", ']);
    else
        fprintf( json, '%s', ['"topic', num2str(k) , '"']);
    end
end
fprintf( json, '%s\n', '];');

F=size(pi,2);
% begin writing results / json file
fprintf(json, '%s\n', 'var ft = [');
for f=1:F,
    % Print out feature topic weights for test document
    fprintf( json, '%s', ['{date:"' , num2str(flabel(f)), '", ' ]);
    for k=1:K,
        if (k < K),
            fprintf( json, '%s', ['topic',num2str(k), ':', num2str(pi(k,f)), ', ']);
        else
            fprintf( json, '%s', ['topic',num2str(k), ':', num2str(pi(k,f)), '} ']);
        end
    end

    if (f < F),
        fprintf(json, '%s\n', ',');
    else
        fprintf(json, '%s\n', '];');
    end
end

topic = cell(1,K);
nk = sum(nkw,2);
fprintf( json, '%s\n', 'var topw = [');
for k=1:K,
    [~, wInd]= sort(nkw(k,:),'descend');
    topw = wInd(1:W);
    topic{k} = words(topw);
    pw = nkw(k, topw) ./ repmat(nk(k), 1, length(topw));
    % Print top N words
    fprintf(json, '%s', '[');
    for w= 1: W,
        if ( w < W),
            fprintf(json, '%s', [ '["', topic{k}{w}, '",', num2str(pw(w)*500), ',', num2str(topw(w)), '],'] );
        else
            fprintf(json, '%s', [ '["', topic{k}{w}, '",', num2str(pw(w)*500), ',', num2str(topw(w)), ']'] );            
        end
    end
    if (k < K),
        fprintf(json, '%s\n','],');
    else
        fprintf(json, '%s\n', ']];');
    end
end
fclose('all');

