function [success] = doubleCheckBytes(src,dest)
% Planned out file comparison
% This function takes the src directory and dest directory and compares the
% contents bytes.  The backup function should already have been run.  What
% we want to achieve with this function is that nothing got missed
% Jamie

% Get all of the files in the dest and src
sourceFileList = dirPlus(src,'Struct', true);
destinationFileList = dirPlus(dest,'Struct', true);

% truncate the name for smooth comparison
beginSrcNum = length(src)+1;
beginDestNum = length(dest)+1;

for i = 1:length(sourceFileList)
    sourceFileList(i).folder =  sourceFileList(i).folder(beginSrcNum:end);
end
for i = 1:length(destinationFileList)
    destinationFileList(i).folder =  destinationFileList(i).folder(beginDestNum:end);
end

% loop through the src files and if a file from the src matches a file in
% the dest, then see if the bytes or size is equal.  If equal then
% everything is cool and we can move to the next file in src, if not equal
% then if the src is larger it should be moved over to dest, and if src
% size is less than the dest we ask what to do and give the option to cease
% and desist

for i = 1:length(sourceFileList)
    srcFile = [sourceFileList(i).folder filesep sourceFileList(i).name];
    needsMoving = 1;
    for j = 1:length(destinationFileList)
        destFile = [destinationFileList(j).folder filesep destinationFileList(j).name];
        if strcmp(srcFile,destFile)
            if isequal(sourceFileList(i).bytes,destinationFileList(j).bytes)
                % everything is equal
                needsMoving = 0;
            elseif lt(sourceFileList(i).bytes,destinationFileList(j).bytes)
                % dest is larger than src
                needsMoving = -1;
            else
                % src is larger than dest, move it to dest
                needsMoving = 1;
            end
            sourceFileList(i).dest = j;
            break % no longer need to evaluate remaining j's
            
        end
    end
    sourceFileList(i).moveIt = needsMoving;
end

% the comparison is complete so time to rock

for i = 1:length(sourceFileList)
    moveIndex = sourceFileList(i).dest;
    srcF = [src sourceFileList(i).folder filesep sourceFileList(i).name];
    destF = [dest destinationFileList(moveIndex).folder filesep destinationFileList(moveIndex).name];
    if isequal(sourceFileList(i).moveIt,1)
        [successfulCopy,msg] = copyfile(srcF,destF);
        if ~isequal(successfulCopy,1)
            resp = questdlg(msg,'Copy Error','Skip','Quit','Skip');
            if strcmp(resp,'Skip')
                continue
            else
                success = 'N';
                return
            end
            
        end
        
    elseif isequal(sourceFileList(i).moveIt,-1)
        str=sprintf('Saved file:\n%s\n\nIs larger than the source file:\n%s\n\nShould saved file be overwritten?\n',destF,...
            srcF);
        resp=questdlg(str,'Confirm','Yes','No','Stop Process','Yes');
        
        if(strcmpi(resp,'Yes'))
            [successfulCopy,msg] = copyfile(srcF,destF);
            if ~isequal(successfulCopy,1)
                resp = questdlg(msg,'Copy Error','Skip','Quit','Skip');
                if strcmp(resp,'Skip')
                    continue
                else
                    success = 'N';
                    return
                end
                
            end
            
        elseif strcmpi(resp,'No')
            continue
        else
            success = 'N';
            return
        end
    end
end

success = 'Y';



