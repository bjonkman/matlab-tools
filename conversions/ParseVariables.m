fileName    = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\SVNdirectory\trunk\Source\FAST_Mods.f90';
outFileName = 'C:\Users\bjonkman\Documents\DATA\DesignCodes\simulators\FAST\ConversionData.txt';

fid = fopen(fileName);
fout = fopen(outFileName,'wt');

ColHeadings = {'Feature','Data Category','Module','Sub Used In','Type',...
               'VarName','Parameter','Dimension','Initial Value','Description','Other Attributes'};
           
fprintf(fout,'%s',ColHeadings{1});
fprintf(fout,[ char(9) '%s'],ColHeadings{2:end});
fprintf(fout,'\n');

nlines = 0;
%%
line = fgetl(fid);    
while ischar(line)
    
    nlines = nlines + 1;
    line = strtrim(line);
    paramLine = '';
    allocLine = '';
    initVal   = '';
    
    if length(line) > 1
        if strncmpi(line, 'MODULE', 6)  % start of a new module
            ModuleName = strtok(line(7:end));
        elseif strncmpi(line, '!', 1)    % comment line, so just ignore for now
        elseif strncmpi(line, 'END', 3)  % end of module or subroutine
        elseif strncmpi(line, 'USE', 3)  % USE module 
        elseif strncmpi(line,'CONTAINS',8) % subroutines contained in the file
            while ischar(line) && ( ...
                  isempty(strfind( upper(line),'END' )) || isempty(strfind( upper(line),'MODULE' )) ) %go to the end of the module
                line = fgetl(fid);
                nlines = nlines + 1;               
            end
        else
            parseThisLine = true;
            if strncmpi(line,'TYPE',4) % this could be a type definition (or not)
                
                tmpLine = strtrim(line(5:end));
                if strcmp(tmpLine(1),'(') %this is not defining the type
                    parseThisLine = true;
                else
                    parseThisLine = false;
                    while ischar(line) && ( ...
                            isempty(strfind( upper(line),'END')) || ...
                            isempty(strfind( upper(line),'TYPE')) )
                        
                        line = fgetl(fid);
                        nlines = nlines + 1;               
                        
                    end
                end
                
            end
            
            
            if parseThisLine
            
                [varLine, Comment] = strtok(line,'!');
                Comment = strtrim(Comment(2:end));

                    % look for continuation lines
                tmpLine = strtrim(varLine);
                while ischar(line) && strcmp(tmpLine(end),'&') %this is a continuation line
                    line = fgetl(fid);
                    nlines = nlines+1;

                    [varLine2, Comment2] = strtok(line,'!');
                    Comment = strtrim( [Comment ' ' strtrim(Comment2(2:end))] );
                    tmpLine = strtrim(varLine2);
                end

                    % parse the line for variable name, type
                [varLine, varName] = strtok(varLine,'::');
                varName = strtrim(varName(3:end));
                attributes = textscan( varLine,'%s','delimiter',',');
                attributes = strtrim(attributes{1});
                
               
                keepAttr = true(size(attributes));
                varType = attributes{1};
                keepAttr(1) = false;
                
                for iAtt = 1:length(attributes)
                    if strcmpi(attributes{iAtt},'PARAMETER')
                        [varName, paramLine] = strtok(varName,'=');
                        varName = strtrim(varName);
                        paramLine = strtrim(paramLine(2:end));
                        keepAttr(iAtt) = false;
                    elseif strcmpi(attributes{iAtt},'ALLOCATABLE')
                        [varName, allocLine] = strtok(varName,'(');
                        varName = strtrim(varName);
                        keepAttr(iAtt) = false;
                    end
                end
                
                
                [varName, initVal] = strtok(varName,'=');
                varName = strtrim(varName);
                initVal = strtrim(initVal(2:end));
                
                if length(allocLine) < 1
                    [varName, allocLine] = strtok(varName,'(');
                    varName = strtrim(varName);
                end
                

                

                fprintf(fout, '%s','');
                fprintf(fout,[ char(9) '%s'],'', ModuleName,'',varType, ...
                    varName, paramLine, allocLine, initVal, Comment, attributes{keepAttr});
                
                fprintf(fout,'\n');
                                
                                                
            end
        end
    end    
    line = fgetl(fid);    

end

fclose(fid);
fclose(fout);



