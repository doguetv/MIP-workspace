%% Comments
%Function to rebuild data from Labchart Matlab Export

%Author: V. Doguet 24/05/2018
%% Function
function dataStruct = labchartRebuild(data, datastart, dataend, catMethod)

%Varargin
if nargin < 3
    catMethod = 'continue';
end

switch catMethod
    case 'continue'
        %Allocate
        dataStruct = cell(1, length(datastart(:,1)));
        %Concatenate when there's stops in file
        for i = 1:length(datastart(1, :))
            for j = 1:length(datastart(:, 1))
                dataStruct{j} = cat(1, dataStruct{j}, data(datastart(j,i):dataend(j,i))');
            end
        end
    case 'split'
        %Allocate
        dataStruct = cell(length(datastart(1,:)), length(datastart(:,1)));
        %Store in different cells when there's stops in file
        for i = 1:length(datastart(1, :))
            for j = 1:length(datastart(:, 1))
                dataStruct{i, j} = data(datastart(j,i):dataend(j,i))';
            end
        end
end

