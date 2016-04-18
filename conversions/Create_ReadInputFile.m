RegistryXLSFile = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\FAST_conversion\DataFromInputFile.xlsx';

% [~,~, rawData] = xlsread(RegistryXLSFile, 'ED InputFile');
% [~,~, rawData] = xlsread(RegistryXLSFile, 'SrvD_InputFile');
% [~,~, rawData] = xlsread(RegistryXLSFile, 'FAST_InputFile');
[~,~, rawData] = xlsread(RegistryXLSFile, 'AD_InputFile');
%%
% fid=fopen('C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\FAST_conversion\ED_ReadInput.f90','wt');
% fid=fopen('C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\FAST_conversion\FAST_ReadInput.f90','wt');
% fid=fopen('C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\FAST_conversion\DLL_ReadInput.f90','wt');
fid=fopen('AD_ReadInput.f90','wt');
newline = '\n';
indent  = '   ';


for i=1:size(rawData,1)  %let's go through all the rows of this sheet
   
        % is this a comment line?
    if isnumeric( rawData{i,1} )            % the line is empty
        continue;            
    elseif strcmp( rawData{i,1}(1), '#' )   % this is a comment line
        continue;
    else

        datatype = rawData{i,4};
        varname  = rawData{i,5};
        units    = rawData{i,10};
        cnvrt   = 0;
        if strcmpi(datatype,'LOGICAL')
            units = 'flag';
        elseif strcmpi(units,'radians')
            units = 'deg';
            cnvrt = 1;
        elseif strcmpi(units,'rad/s')
            units = 'rpm';
            cnvrt = 2;
        end
               
        descr = [ rawData{i,9} ' (' units ')' ]; % use the description
        descr = strrep( descr, '"', ''); %remove the quote marks from the description field        
        
        fprintf(fid,[indent indent '! %s - %s'], varname, descr);
        if cnvrt == 1
            fprintf(fid, ' (read from file in degrees and converted to radians here)');
        elseif cnvrt == 2
            fprintf(fid, ' (read from file in rpm and converted to rad/s here)');
        end
        fprintf(fid,[':' newline]);
        
%let's figure out where column 132 is going to hit
        fprintf(fid,[indent 'CALL ReadVar( UnIn, InputFile, InputFileData%%%s, "%s", '], varname, varname );
%         numCharsPrinted = 45 + (length(varname)+2)*2;
%         numChars = numCharsPrinted + length(descr) + 4;
%         if numChars < 130
%             fprintf(fid,['"%s", '], descr);
%             numCharsPrinted = numChars + 1;
%         else %print one character at a time...
%             fprintf(fid,['"']
%             %s", '], descr);
%         end
                        
        fprintf(fid,['"%s", ErrStat2, ErrMsg2, UnEc)' newline],descr);
        fprintf(fid,[indent indent 'CALL SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )' newline]);
        fprintf(fid,[indent indent 'IF ( ErrStat >= AbortErrLev ) RETURN' newline]);
        
        if cnvrt == 1
            fprintf(fid,[indent 'InputFileData%%%s = InputFileData%%%s*D2R' newline], varname, varname );
        elseif cnvrt == 2
            fprintf(fid,[indent 'InputFileData%%%s = InputFileData%%%s*RPM2RPS' newline], varname, varname );
        end                   
        fprintf(fid,newline);
        
    end
    
    
end

fclose all;
