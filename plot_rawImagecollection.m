% Define the date range in the format yymmdd
startDate = '231212';
endDate = '231222';

startDateNum = str2double(startDate);
endDateNum = str2double(endDate);

% Get a list of all folders
folderList = dir(['/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo' '*' 'xray']);


% Define the number of rows per figure
rowsPerFigure = 4;

% Initialize counters
figureCounter = 1;
rowCounter = 1;

% Loop through all folders
for folderIdx = 1:numel(folderList)
    folderName = folderList(folderIdx).name;
    
    % Extract the date from the folder name
    folderDate = folderName(6:11);
    folderDateNum=str2double(folderDate);
    % Check if the folder date is within the specified range
    if (folderDateNum >= startDateNum) && (folderDateNum <= endDateNum)
        subfolders = dir(fullfile(folderName, '**', 'D1.tif')); % Get all D1.tif files
        
        % Loop through subfolders
        for subfolderIdx = 1:numel(subfolders)
            subfolderName = subfolders(subfolderIdx).folder;
            D1File = fullfile(subfolderName, 'D1.tif');
            D2File = fullfile(subfolderName, 'D2.tif');
            [~, subfolderNameShort] = fileparts(subfolderName);
            % Check if both D1.tif and D2.tif files exist
            if exist(D1File, 'file') && exist(D2File, 'file')
                % Load images
                I1 = double(imread(D1File));
                I2 = double(imread(D2File));
                

                I1(:,[255 256 257 767 768 769])=median(I1(:));
                I2(:,[255 256 257 767 768 769])=median(I2(:));

                %I1(I1>=0.9*max(I1(:)))=median(I1(:));
                %I2(I2>=0.9*max(I2(:)))=median(I2(:));

                vertical_filter = ones(6, 1) / 6;  % Filter size: 6 vertical, 1 horizontal

                % Apply vertical filtering using convolution
                I1 = conv2(I1, vertical_filter, 'same');
                I2 = conv2(I2, vertical_filter, 'same');
                
                
                % 
                % I1=uint8(I1);
                % I2=uint8(I2);

                %I1 = imadjust(uint8(I1));
                %I2 = imadjust(I2);



                % Display images side by side with subfolder name as title
                if rowCounter == 1
                    h=figure(figureCounter);
                    clf; % Clear figure if it's not the first row
                end
                
                subplot(rowsPerFigure, 2, 2 * (rowCounter - 1) + 1);
                imagesc(I1); colormap('gray')
                title(subfolderNameShort(7:end), 'Interpreter', 'none');
               % axis tight
                subplot(rowsPerFigure, 2, 2 * rowCounter);
                imagesc(I2);  colormap('gray')
               % axis tight

                % % Define the position for the D1 subplot
                % position_D1 = [(2 * (rowCounter - 1) + 1) / (2 * rowsPerFigure), 0.1, 0.45, 0.8 / rowsPerFigure];
                % subplot('Position', position_D1);
                % imshow(D1);
                % title(subfolderNameShort(7:end), 'Interpreter', 'none'); % Use folder name as title
                % 
                % % Define the position for the D2 subplot
                % position_D2 = [(2 * rowCounter) / (2 * rowsPerFigure), 0.1, 0.45, 0.8 / rowsPerFigure];
                % subplot('Position', position_D2);
                % imshow(D2);


                % Increment counters
                rowCounter = rowCounter + 1;
                
                % If the maximum rows per figure is reached, open a new figure
                if rowCounter > rowsPerFigure
                    % Make the figure full monitor size
                    %set(h, 'Position', get(0, 'ScreenSize'));

                    % Convert the figure to PDF
                    pdfFileName = sprintf('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/figure_%d.pdf', figureCounter);
                    print(h, pdfFileName, '-dpdf', '-bestfit');

                    % Close the figure
                    close(h);
                    
                    rowCounter = 1;
                    figureCounter = figureCounter + 1;


                

                end

   
            end
        end
    end
end
