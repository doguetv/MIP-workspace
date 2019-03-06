function dataStruct = delsys2mat(path, delimiter, outputTime)
% Function that read text files from Delsys EMGWorks and restructure data
% has a Matlab structure
%Input :
%path = path and filename of file to restructure
%delimiter = delimiter in the file to read (e.g., comma, tab)
%outputTime = wheter file contains time colons or not (see EMGWorks export
%options)


% File ID
fid = fopen(path);
%Initialize index
k = 1;
%get the first line
output = fgets(fid);
%Loop while header prefix
while ischar(output)
    %Data started ||break the loop
    if ~isempty(output) && ~isnan(str2double(output(1)))
        lineToAdd = output;
        break;
    end
    % Store chanel infos
    if strfind(output, 'Label')
        header{k} = output;
        k = k+1;
    end
    %get a new line
    output = fgets(fid);
end
% Define chanel number and relevant formatSpec
formatSpec = '';
if outputTime == true
    if ~isempty(header)
        for i = 1:length(header)*2
            formatSpec = [formatSpec, '%f '];
        end
        formatSpec(end) = [];
    end
else
    for i = 1:length(header)
        formatSpec = [formatSpec, '%f '];
    end
    formatSpec(end) = [];
end
% Scan data at the good line and add already read line
d = textscan(lineToAdd, formatSpec, 'Delimiter', delimiter);
data = textscan(fid, formatSpec, 'Delimiter', delimiter);
for i = 1:length(d)
    data{i} = cat(1, d{i}, data{i});
end
% close file
fclose(fid);
%Correction for not repeated time column
isTime = ones(1, length(data));
t = 0;
for i = 1:length(data)
    if isnan(data{i}(1))
        isTime(i:end) = [];
    else
        for k = 1:length(data{i}) - 1
            if data{i}(k+1) < data{i}(k)
                isTime(i) = 0;
                break;
            end
        end
        if k == length(data{i}) - 1
            t = t+1;
            timeStruct{t} = data{i};
            timeStep(t) = i;
        end
    end
end
data(timeStep) = [];
% Restructure Header with Data
dataStruct = cell(length(header), 3);
for i = 1:length(header)
    out = find(header{i} == 'S');
    for k = 1:length(out)
        if strcmp(header{i}(out(k):out(k) + 17), 'Sampling frequency')
            %Label
            dataStruct{i, 1} = header{i}(1:out(k)-2);
            %Samle Rate
            stop = find(header{i}(out(k):end) == 'N', 1, 'first');
            stop = out(k) + stop - 3;
            dataStruct{i, 2} = str2double(header{i}(out(k) + 20:stop));
            %Data
            if outputTime == true
                if length(timeStruct) == length(data) 
                    dataStruct{i, 3}(:,1) = timeStruct{i}(~isnan(timeStruct{i}));
                    dataStruct{i, 3}(:,2) = data{i}(1:length(dataStruct{i, 3}(:,1)));
                else
                    for l = 1:length(timeStruct)
                        if length(timeStruct{l}) == length(data{i})
                            dataStruct{i, 3}(:,1) = timeStruct{l}(~isnan(timeStruct{l}));
                            dataStruct{i, 3}(:,2) =data{i}(1:length(dataStruct{i, 3}(:,1)));
                            break;
                        end 
                    end
                end
            else
                dataStruct{i, 3}(:,1) = data{i}(~isnan(data{i}));
            end
        end
    end
end
