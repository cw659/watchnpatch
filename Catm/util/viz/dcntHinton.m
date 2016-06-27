%% Generate test document
function dcntHinton(fid, nkw, picorr, words, K, W)

%% Start generative process
W = 20; %number of words to view 
topic = cell(K,1);
nk = sum(nkw,2);
nk = nk ./ sum(nk);
% save file
json = fopen(fid, 'w+');
% print nodes
fprintf( json, '%s', 'var graph={nodes:[');
for k=1:K,
    if ( k < K),
        fprintf( json, '%s\n', ['{nodeName:',num2str(k), ', size:' ,num2str(nk(k) * 1000), '},']);
    else
        fprintf( json, '%s\n', ['{nodeName:',num2str(k), ', size:' ,num2str(nk(k) * 1000), '}],']);
    end
end
fprintf( json, '%s\n', 'links:[');
offset = 10;
for k=1:K,
    for j = k+1:K,
        if (picorr(j,k) >= 0),
            lnkvalue = picorr(j,k) * 10 + offset;
        else
            lnkvalue = offset - abs(picorr(j,k) * 10); 
        end
        
        if ((k + j) == (K + K-1)),
            fprintf( json, '%s\n', ['{source:',num2str(k-1), ', target:' , num2str(j-1), ', value:', num2str(lnkvalue), '}]};']);            
        else
            fprintf( json, '%s\n', ['{source:',num2str(k-1), ', target:' , num2str(j-1), ', value:', num2str(lnkvalue), '},']);
        end
    end
end

% choose k topics
fprintf( json, '%s\n', 'var topw = [');
nk = sum(nkw,2);
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

