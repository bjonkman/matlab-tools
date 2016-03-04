function [outData]=PlotLiftDragCurves(dataFiles,fileDesc,BlOutNd,ReferenceFile, CustomHdr, varargin )
%..........................................................................
% This routine produces plots of Cl, Cd, and/or Cm versus Alpha for AeroDyn
% outputs at various nodes.
%
% (c) 2016 National Renewable Energy Laboratory
%  Author: B. Jonkman, NREL/NWTC
%
%
%..........................................................................
% Required Inputs:
% dataFiles     - a cell array of strings, listing FAST/AeroDyn .out or  
%                 .outb file names, whose channels are to be plotted
% Optional Inputs:
% fileDesc      - a cell array of strings describing the FAST/AeroDyn files 
%                 listed in dataFiles, used in the plot legend. If omitted,  
%                 the routine will list them as File 1, File 2, etc.
% ReferenceFile - scalar (index into dataFiles) that denotes which file is 
%                 considered the reference. The channels from this file 
%                 will be plotted, and the channel names from this file 
%                 will be used. If omitted, ReferenceFile is the last file 
%                 in dataFiles. 
% NodeNumbers   - 
%                 
% CustomHdr     - cell array describing text file format. Default will use
%                 values appropriate for FAST text output files. 
%     CustomHdr{1} = delim: delimiter for channel columns; if
%                    empty ([]), columns are delimited by whitespace
%     CustomHdr{2} = HeaderRows: number of rows in the file header, before
%                    data is encountered
%     CustomHdr{3} = NameLine: scalar value denoting line containing
%                    channel names
%     CustomHdr{4} = UnitsLine: scalar value denoting line containing
%                    channel units
% OnePlot       - scalar logical that determines if each time series plot
%                 will be placed on the same or separate plots. Default
%                 is false (many plots).
%
% Note: the channels in the files need not be in the same order, but the
%  channel names must be the same [it does search for negatives]. 
%..........................................................................


numFiles = length(dataFiles);
if numFiles < 1 
    disp('PlotLiftDragCurves:No files to plot.')
    return
end


if nargin < 5 || isempty(CustomHdr)
    useCustomHdr=false;
else
    useCustomHdr=true;
end

if nargin < 4 || isempty(ReferenceFile) || (ReferenceFile < 1) || (ReferenceFile > numFiles)
    ReferenceFile = 1;
end

if nargin < 3
    BlOutNd = cell(numFiles,1);
    for i=1:numFiles
        BlOutNd{i} = 1:9;
    end
end


if nargin < 2 
    fileDesc = ''; %empty string
end


%% ------------------------------------------------------------------------
% Read the data file(s):
% -------------------------------------------------------------------------
data         = cell(numFiles,1);
columnTitles = cell(numFiles,1);
columnUnits  = cell(numFiles,1);
DescStr      = cell(numFiles,1);

for iFile=1:numFiles

    if length(dataFiles{iFile}) > 4 && strcmpi( dataFiles{iFile}((end-4):end),'.outb' )
        [data{iFile}, columnTitles{iFile}, columnUnits{iFile}, ~, DescStr{iFile}] = ReadFASTbinary(dataFiles{iFile});
    elseif ~useCustomHdr
        [data{iFile}, columnTitles{iFile}, columnUnits{iFile},    DescStr{iFile}] = ReadFASTtext(dataFiles{iFile});                        
    else % allow other files 
        delim     = CustomHdr{1};
        HeaderRows= CustomHdr{2};
        NameLine  = CustomHdr{3};
        UnitsLine = CustomHdr{4};
        DescStr{iFile} = '';
        
        [data{iFile}, columnTitles{iFile}, columnUnits{iFile} ] = ReadFASTtext(dataFiles{iFile}, delim, HeaderRows, NameLine, UnitsLine );    
    end
    
end

%% ------------------------------------------------------------------------
% Set some default values, if it wasn't input to this routine:
% ------------------------------------------------------------------------- 
if isempty(fileDesc)
    for i=1:numFiles
        fileDesc{i} = sprintf('File %i',i);
    end
end

%% ------------------------------------------------------------------------
% Set some default values for the plots:
% -------------------------------------------------------------------------
% LineColors{iFile}*0.75

LineColors     = {[0 0 0],[0 1 1],[1 0 1],[0 1 0],[0 0 1],[1 0 0]};
Markers        = {'o'    ,'s'    ,'d'    ,'v'    ,'^'    ,'.'    };

if numFiles > length(LineColors)
    tmp=jet(numFiles);
    for i=1:numFiles
        LineColors{i}=tmp(i,:);
    end
    n=length(Markers);
    for i=n+1:numFiles
        Markers{i}=Markers{n};
    end
end
    
titleFileText = char(DescStr{ReferenceFile});
FASTv8Text='Description from the FAST input file:';
indx=strfind(titleFileText,FASTv8Text);
if ~isempty(indx)
    titleFileText=titleFileText((indx+length(FASTv8Text)):end);
end

%% ------------------------------------------------------------------------
% initialize data to save for output

outData = getADOutData ( data, columnTitles, BlOutNd );

%%

for iNode = 1:length( outData{ReferenceFile}.node )
    
    f=figure;
    b = outData{ReferenceFile}.blade(iNode);
    n = outData{ReferenceFile}.node(iNode);
    
    titleText = {titleFileText,['Blade ', num2str(b), ', Node ', num2str(n)]};
    
    for iFile=1:numFiles
        
        indx = outData{iFile}.node == n & outData{iFile}.blade == b;
        
        if sum(indx) == 1
            
            OneGraph( outData{iFile}.alpha{indx}, outData{iFile}.cl{indx}, iFile, 1, fileDesc{iFile}, 'lift', titleText, LineColors, Markers );
            OneGraph( outData{iFile}.alpha{indx}, outData{iFile}.cd{indx}, iFile, 2, fileDesc{iFile}, 'drag', titleText, LineColors, Markers );
            OneGraph( outData{iFile}.alpha{indx}, outData{iFile}.cm{indx}, iFile, 3, fileDesc{iFile}, 'pitching-moment', titleText, LineColors, Markers );
                                     
        end                  
    end
    
    for i=1:3
        subplot(2,2,i)
        legend show
    end
    
end


end

%% ------------------------------------------------------------------------
function OneGraph( x, y, iFile, iPlot, fileDesc, ytxt, titleText, LineColors, Markers )

    FntSz          = 17;

    %note issue if iFile > 6!
    
    if ~isempty(y)
        subplot(2,2,iPlot)           
        plot(x, y ...
             ,'Marker',Markers{iFile} ...
             ,'MarkerSize',4 ...
             ,'LineStyle','none' ...
             ,'DisplayName',fileDesc ...
             ,'Color',LineColors{iFile} ); ...
        hold on;      
        ylabel([ ytxt ' coefficient (-)'],'FontSize',FntSz);                          
        xlabel('angle of attack (deg)','FontSize',FntSz);                         
        title( titleText,'FontSize',FntSz )    
        grid on;
        set(gca,'FontSize',FntSz-2,'gridlinestyle','-');
    end



return;
end
%% ------------------------------------------------------------------------
function [outData] = getADOutData ( data, columnTitles, BlOutNd )
    numFiles = length(columnTitles);
%%
    outData = cell(numFiles,1);
    % initialize data to save for output
    for iFile=1:numFiles
        outData{iFile}.blade = 0;
        outData{iFile}.node  = 0;
        outData{iFile}.alpha = {};
        outData{iFile}.cl    = {};
        outData{iFile}.cd    = {};
        outData{iFile}.cm    = {};
    end

% get indices of Alpha for any blade nodes specified, and get corresponding
% indices for Cl, Cd, and/or Cm
    for iFile=1:numFiles
        lc_titles = lower( columnTitles{iFile} ); %convert to lower case

        i_nodes = 1;    
        for i = 1:length( lc_titles )              
            alpha_ix = strfind(lc_titles{i},'alpha');
            foundIt = false;

            if ~isempty(alpha_ix)
                if alpha_ix == 5    % AD15 format                
                    AD15Node = lc_titles{i}(1:4) ;             
                    disp(['ad15 node ' AD15Node] )

                    % cl
                    ix = find(strcmp(lc_titles,[AD15Node 'cl']));
                    if ~isempty( ix )
                        outData{iFile}.cl{i_nodes} = data{iFile}(:,ix(1));
                        foundIt = true;
                    end

                    % cd
                    ix = find(strcmp(lc_titles,[AD15Node 'cd']));
                    if ~isempty( ix )
                        outData{iFile}.cd{i_nodes} = data{iFile}(:,ix(1));
                        foundIt = true;
                    end

                    % cm
                    ix = find(strcmp(lc_titles,[AD15Node 'cm']));
                    if ~isempty( ix )
                        outData{iFile}.cm{i_nodes} = data{iFile}(:,ix(1));
                        foundIt = true;
                    end

                    if foundIt
                        outData{iFile}.blade(i_nodes) = str2double( lc_titles{i}(2) );
                        outData{iFile}.node(i_nodes)  = BlOutNd{iFile}( str2double( lc_titles{i}(4) ));
                        outData{iFile}.alpha{i_nodes} = data{iFile}(:,i);
                        i_nodes = i_nodes + 1;
                    end         
                elseif alpha_ix == 1 % AD14 format 
                    
                    AD14node = lc_titles{i}(6:7);             
                    disp(['ad14 node ' AD14node])

                    % cl
                    ix = find(strcmp(lc_titles,['clift' AD14node]));
                    if ~isempty( ix )
                        outData{iFile}.cl{i_nodes} = data{iFile}(:,ix(1));
                        foundIt = true;
                    end

                    % cd
                    ix = find(strcmp(lc_titles,['cdrag' AD14node]));
                    if ~isempty( ix )
                        outData{iFile}.cd{i_nodes} = data{iFile}(:,ix(1));
                        foundIt = true;
                    end

                    % cm
                    ix = find(strcmp(lc_titles,['cmomt' AD14node]));
                    if ~isempty( ix )
                        outData{iFile}.cm{i_nodes} = data{iFile}(:,ix(1));
                        foundIt = true;
                    end

                    if foundIt
                        outData{iFile}.blade(i_nodes) = 1;
                        outData{iFile}.node(i_nodes)  = str2double( AD14node ) + 1;
                        outData{iFile}.alpha{i_nodes} = data{iFile}(:,i);
                        i_nodes = i_nodes + 1;
                    end                         

                end % AD15 format

            end
        end
    end
%%    
    return;
end

%%