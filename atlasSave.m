function varargout = atlasSave(varargin)
% ATLASSAVE MATLAB code for atlasSave.fig
%      ATLASSAVE, by itself, creates a new ATLASSAVE or raises the existing
%      singleton*.
%
%      H = ATLASSAVE returns the handle to a new ATLASSAVE or the handle to
%      the existing singleton*.
%
%      ATLASSAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ATLASSAVE.M with the given input arguments.
%
%      ATLASSAVE('Property','Value',...) creates a new ATLASSAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before atlasSave_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to atlasSave_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help atlasSave

% Last Modified by GUIDE v2.5 26-Jun-2018 09:53:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @atlasSave_OpeningFcn, ...
                   'gui_OutputFcn',  @atlasSave_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before atlasSave is made visible.
function atlasSave_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to atlasSave (see VARARGIN)

% Choose default command line output for atlasSave
handles.output = hObject;
handles.dest = 0;
handles.src = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes atlasSave wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = atlasSave_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in setSourceButton.
function setSourceButton_Callback(hObject, eventdata, handles)
% hObject    handle to setSourceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sourceDir = uigetdir;

if isequal(sourceDir,0) || isempty(sourceDir)
    handles.sourceDisplayBox.String = 'no source folder chosen yet';
    handles.src = 0;
    guidata(hObject,handles)
else
    handles.sourceDisplayBox.String = sourceDir;
    handles.src = sourceDir;
    guidata(hObject,handles)
end


% --- Executes on button press in setDestinationButton.
function setDestinationButton_Callback(hObject, eventdata, handles)
% hObject    handle to setDestinationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


initializeFolder = handles.firstRun.Value;
if initializeFolder
    newPtNum = inputdlg('Enter the new patient number/name',...
             'New Patient',1,{'Oslxx'});
         if isempty(newPtNum)
             handles.destinationDisplayBox.String = 'no destination folder chosen yet';
             handles.dest = 0;
             guidata(hObject,handles)
             return
         else
             uiwait(msgbox(['Now you must choose where to make the new folder called: ' newPtNum{1} '.'],'Parent Dir','modal'));
             destDir_t = uigetdir;
             if isequal(destDir_t,0) || isempty(destDir_t)
                 handles.destinationDisplayBox.String = 'no destination folder chosen yet';
                 handles.dest = 0;
                 guidata(hObject,handles)
                 return
             end
                 
         end
         destDir = [destDir_t filesep newPtNum{1} filesep 'Datafiles'];
         
else
    destDir = uigetdir;
end



if isequal(destDir,0) || isempty(destDir)
    handles.destinationDisplayBox.String = 'no destination folder chosen yet';
    handles.dest = 0;
    guidata(hObject,handles)
else
    handles.destinationDisplayBox.String = destDir;
    handles.dest = destDir;
    guidata(hObject,handles)
end


% --- Executes on button press in copySrcToDestButton.
function copySrcToDestButton_Callback(hObject, eventdata, handles)
% hObject    handle to copySrcToDestButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


flags = ' /F /E /Y /D';

if isequal(handles.dest,0) || isequal(handles.src,0)
    warndlg('Try resetting the source and destination paths')
    return
else
    % paths have been set, we need to check if they're valid
    if strcmpi(handles.dest,handles.src)
        warndlg('The paths cannot be the same')
        return
    elseif exist(handles.src,'dir') && exist(handles.dest,'dir')
        % both are directories and not the same
        
        str=sprintf('Backing-up data FROM:\n%s\nTO:\n%s',handles.src,handles.dest);
        resp=questdlg(str,'Confirm','Yes','No','Yes');

        if ~strcmpi(resp,'Yes')
            return
        end
        
        handles.copySrcToDestButton.Enable = 'off';
        handles.copySrcToDestButton.String = 'Running...';
        guidata(hObject,handles)
        
        b = gcf;
        set(b, 'pointer', 'watch')
        drawnow;
        
        
        [successfulMove,logFile] = backup(handles.src,handles.dest,0,flags,'xcopy');
        set(b, 'pointer', 'arrow')
        
        
        set(b, 'pointer', 'watch')
        drawnow;
        successfulCheck = doubleCheckBytes(handles.src,handles.dest);
        set(b, 'pointer', 'arrow')
        
        
        handles.copySrcToDestButton.Enable = 'on';
        handles.copySrcToDestButton.String = 'COPY!';
        guidata(hObject,handles)
        
        
    elseif exist(handles.src,'dir') && ~exist(handles.dest,'dir') && handles.firstRun.Value
        % Src is a directory and dest needs to be made
        
        str=sprintf('Backing-up data FROM:\n%s\nTO:\n%s',handles.src,handles.dest);
        resp=questdlg(str,'Confirm','Yes','No','Yes');

        if ~strcmpi(resp,'Yes')
            return
        end
        
        
        handles.copySrcToDestButton.Enable = 'off';
        handles.copySrcToDestButton.String = 'Running...';
        guidata(hObject,handles)
        
        b = gcf;
        set(b, 'pointer', 'watch')
        drawnow;
        
        
        [successfulMove,logFile] = backup(handles.src,handles.dest,0,flags,'xcopy');
        set(b, 'pointer', 'arrow')
        
        
        set(b, 'pointer', 'watch')
        drawnow;
        successfulCheck = doubleCheckBytes(handles.src,handles.dest);
        set(b, 'pointer', 'arrow')
        
        
        handles.copySrcToDestButton.Enable = 'on';
        handles.copySrcToDestButton.String = 'COPY!';
        guidata(hObject,handles)
        
    else
        warndlg('Try resetting the source and destination paths')
        return
    end
        
end



if isequal(successfulMove,1) && strcmp(successfulCheck,'Y')
    % offer to quit
    qANS = questdlg('All files moved! Quit?','Done','Quit','Stay','Save Log File','Quit');
    switch qANS
        case 'Quit'
            delete(handles.figure1);
        case 'Save Log File'
            logFileName = [handles.dest filesep date '_SaveLogFile.txt'];
            fileID = fopen(logFileName,'w+');
            logFile = splitlines(string(logFile));
            if strcmp(logFile(end,:),"")
                logFile(end,:)=[];
            end
            newLogFile = replace(logFile,filesep,'/');
                
                
            
            fprintf(fileID,'%s\r\n',newLogFile);
            fclose(fileID);
    end

    guidata(hObject,handles)
    
elseif isequal(successfulMove,1) && strcmp(successfulCheck,'N')
    qANS = questdlg('Files were moved, but there was an file size difference. Quit?','Done','Quit','Stay','Quit');
    switch qANS
        case 'Quit'
            delete(handles.figure1);
        otherwise
            handles.sourceDisplayBox.String = 'An error occurred please reset';
            handles.src = 0;
            handles.destinationDisplayBox.String = 'An error occurred please reset';
            handles.dest = 0;
            handles.firstRun.Value = 0;
            guidata(hObject,handles)
    end
else
    % trouble
    warndlg('Error! Unable to move new files. Try resetting paths or do it manually.')
end
    



function destinationDisplayBox_Callback(hObject, eventdata, handles)
% hObject    handle to destinationDisplayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinationDisplayBox as text
%        str2double(get(hObject,'String')) returns contents of destinationDisplayBox as a double


% --- Executes during object creation, after setting all properties.
function destinationDisplayBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinationDisplayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sourceDisplayBox_Callback(hObject, eventdata, handles)
% hObject    handle to sourceDisplayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sourceDisplayBox as text
%        str2double(get(hObject,'String')) returns contents of sourceDisplayBox as a double


% --- Executes during object creation, after setting all properties.
function sourceDisplayBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourceDisplayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in firstRun.
function firstRun_Callback(hObject, eventdata, handles)
% hObject    handle to firstRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of firstRun
