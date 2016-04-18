RegistryXLSFile = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\FAST_conversion\DataFromInputFile.xlsx';
InputFile       = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\SVNdirectory\branches\BJonkman\CertTest\TemplateFiles\V8.00.x\5MW_Monopile\FAST_Primary.dat';
InputFile       = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\SVNdirectory\branches\BJonkman\Utilities\SimulationToolbox\ConvertFASTversions\TemplateFiles\ServoDyn_v1.01.x\BladedInputs.txt';
InputFile       = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\SVNdirectory\branches\BJonkman\Utilities\SimulationToolbox\ConvertFASTversions\TemplateFiles\AD_v15.00.x.dat';

ModuleName = 'AeroDyn';
ModName =    'AD';
headerlines = 2;

cols.keyword   = 1;
cols.ModName   = 2;
cols.TypeName  = 3;
cols.FieldType = 4;
cols.FieldName = 5;
cols.Dims      = 6;
cols.IO        = 7;
cols.DNAME     = 8;
cols.descr     = 9;
cols.units     = 10;

%%
fid=fopen(InputFile,'rt');


for i=1:headerlines
    line = fgetl(fid); %header line 1
end

i = 0;
allXLSdata = cell(1,cols.units);

while true
    line = fgetl(fid);
    if ~ischar(line)
        break
    end
    
    [~, label, isComment, descr, lineType] = ParseFASTInputLine(line);
    if ~isComment        
        
            % is it an array?
        indx = strfind(label,'(');
        if isempty( indx ) %no, it's not
            num = '-';
        else
            num   = sscanf(label((indx(1)+1):end),'%f');
            label = label(1:indx(1)-1);
                % let's see if the previous label was the same
            if i > 0 
                if strcmpi(label,allXLSdata{i,cols.FieldName}) %this is the same as the previous one
                    allXLSdata{i,cols.Dims} = max(num,allXLSdata{i,cols.Dims});
                    continue; %go to the next line
                end
            end
        end
        i = i + 1;

        FieldType = 'ReKi';       
        if strcmpi(lineType,'Logical')
            FieldType = 'LOGICAL';                
        elseif strcmpi(lineType,'Character')
             FieldType = 'CHARACTER(1024)';                
        end

        descr = strtrim(descr);
        while length(descr) > 1 && strcmpi(descr(1),'-')
            descr = strtrim( descr(2:end) );
        end
        
        quotes = strfind(descr,'(');
        if ~isempty(quotes)
            tmpline = strtrim( descr((quotes(end)+1):end) );
            endquotes = strfind(tmpline,')');
            if ~isempty(endquotes)
                units = tmpline(1:(endquotes(1)-1));
                if endquotes(1)+1 < length(tmpline)
                    tmpline = tmpline((endquotes(1)+1):end);
                else
                    tmpline = '';
                end
            else
                units = '-';
                tmpline = descr((quotes(end)+1):end);
            end

            if strcmpi(units,'switch')
                FieldType = 'IntKi';
                units = '-';
            else
                if any(strcmpi(units,{'s','sec','seconds'}))
                    FieldType = 'DbKi';
                end
            end
            descr = [strtrim(descr(1:(quotes(end)-1))) ' ' strtrim(tmpline)];
        else
            units = '-';            
        end
            
        allXLSdata{i,cols.keyword}   = 'typedef';
        allXLSdata{i,cols.ModName}   = [ModuleName '/' ModName];
        allXLSdata{i,cols.TypeName}  = [ModName '_InputFile'];
        allXLSdata{i,cols.IO}        = '-';
        allXLSdata{i,cols.DNAME}     = '-';
        allXLSdata{i,cols.FieldName} = label;
        allXLSdata{i,cols.Dims}      = num;
        
        allXLSdata{i,cols.FieldType} = FieldType;
        allXLSdata{i,cols.descr}     = ['"' strtrim(descr) '"'];
        allXLSdata{i,cols.units}     = units;
        
     end % not a comment       
    
end
     
xlswrite(RegistryXLSFile,allXLSdata,[ModName '_InputFile']);

fclose all;
