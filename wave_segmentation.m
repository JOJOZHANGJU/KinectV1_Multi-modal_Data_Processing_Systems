function varargout = wave_segmentation(varargin)
% WAVE_SEGMENTATION MATLAB code for wave_segmentation.fig
%      WAVE_SEGMENTATION, by itself, creates a new WAVE_SEGMENTATION or raises the existing
%      singleton*.
%
%      H = WAVE_SEGMENTATION returns the handle to a new WAVE_SEGMENTATION or the handle to
%      the existing singleton*.
%
%      WAVE_SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAVE_SEGMENTATION.M with the given input arguments.
%
%      WAVE_SEGMENTATION('Property','Value',...) creates a new WAVE_SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wave_segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wave_segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wave_segmentation

% Last Modified by GUIDE v2.5 20-Dec-2013 15:53:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wave_segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @wave_segmentation_OutputFcn, ...
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


% --- Executes just before wave_segmentation is made visible.
function wave_segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wave_segmentation (see VARARGIN)

% Choose default command line output for wave_segmentation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wave_segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wave_segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectPath.
function selectPath_Callback(hObject, eventdata, handles)
% hObject    handle to selectPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ȫ�ֱ�����·�����ƣ��ļ�����ͼƬ��index���ܹ���ͼƬ�������ӳ�
global pathname files index fileNum totalDelay
% ȫ�ֱ�������Ƶ��ʼʱ�䣬��ǰͼƬ������Ƶλ�õı궨�ߣ���Ƶ�������ʣ�������
global t1 line y fs nbits 
% ȫ�ֱ������궨�Ŀ�ʼ�������ͼƬ֡����3DData����
global startSave endSave C
% ȫ�ֱ�������������ļ����������Ƶ�ļ����ļ���
global depthDataFiles depthImageFiles outWaveFileName

% ��ѡ�е�·���л�ȡ���е�ͼƬ
[filename,filepath] = ...
    uigetfile({'*.png','*.bmp'},'��ѡ���ļ����еĵ�һ��ͼƬ');
path_index = strfind(filepath, filesep);
pathname = filepath(1:path_index(length(path_index)-1));
disp(pathname)
index = 1;
files = dir(fullfile(filepath, '*.png')); %��ȡ��ɫͼƬ�ļ���

% �����Ϣ�ļ���
depthDataFiles = dir(fullfile(pathname, 'AdjustedDepthData', '*.csv'));
depthImageFiles = dir(fullfile(pathname, 'AdjustedDepthImages', '*.png'));

% ��pics�ؼ�����ʾ��ȡ���ĵ�һ��ͼƬ
str = [filepath filename];
im = imread(str);
axes(handles.pics);
imshow(im);
% ��ͼƬ�·��Ŀո�����ʾ��Ӧ��ͼƬ����
set(handles.picName, 'String', files(index).name);

% �����Ϸ���displayer����ʾ��Ӧ��index
fileNum = length(files);
disLine = ['��ǰΪ�� ', num2str(index), ' ��ͼƬ'];
set(handles.displayer, 'String', disLine);

% ����ͼƬ�洢����ʼλ�������λ��
startSave = 0;
endSave = 0;

% ��ȡ3DData�ļ���Ϣ(һ���Ի�ȡ���ݣ����㱣��ʱд��)
fi3D = fopen([pathname,'3Ddata.txt'],'rt','n','utf-8');
C = textscan(fi3D, '%s %s %s %s %s %s');

% ��ȡ���ļ����е�wav�ļ����·���waves����ʾ��Ƶ�ź�
wavFiles = dir(fullfile(pathname, '*.wav'));
wavFile = [pathname, wavFiles(1).name];
outWaveFileName = wavFiles(1).name;

% ��ȡ��Ƶ��ʼ��ʱ��
totalDelay = 0.09;
t1 = datenum(wavFiles(1).name(12:23), 'HH-MM-SS-FFF');
[y, fs, nbits] = wavread(wavFile);  %������Ƶ
t = (0 : length(y)-1) / fs;         %Ĭ�Ϻ���Ϊ���ݵ㣬������
x = 0;
z = -1 : 0.01 : 1;
axes(handles.waves);
% ��waves���¼ӽ�����������Ƶ
xlim([0,20]);
uicontrol('units','normalized','Style','slider','userdata',handles.waves,'pos',[.1 .1 .8 .03],'min',0,'max', 300,'callback',@(obj,event)set(get(obj,'userdata'),'xlim',[0,20]+get(obj,'value')));

plot(t, y);                         %������Ƶ�Ĳ���
line = plot(x, z);                  %�����궨��

% �ڻ�ȡ�ļ���Ϣ����֮�󣬽�ѡ��·������ͨ��reset�������¿�ʼ��
set(handles.selectPath, 'Visible', 'off');
set(handles.previous, 'Visible', 'off');
set(handles.startFrame, 'Visible', 'off');



% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathname index files fileNum line t1 totalDelay
if index <= 1
    set(handles.previous, 'Visible', 'off');
    set(handles.next, 'Visible', 'on');
    set(handles.startFrame, 'Visible', 'off');
    set(handles.endFrame, 'Visible', 'on');
end

% �������ص���һ��ͼƬ���Լ���Ӧ��������ʾ������
if index > 1
    if index < fileNum
        set(handles.next, 'Visible', 'on');
        set(handles.endFrame, 'Visible', 'on');
    end
    set(handles.previous, 'Visible', 'on');
    set(handles.startFrame, 'Visible', 'on');
    index = index - 1;
    set(handles.picName, 'String', files(index).name);
    
    % ����ͼƬ
    str = [pathname files(index).name];
    im = imread(str);
    axes(handles.pics);
    imshow(im);
    
    % ���±궨��
    delete(line);
    t2 = datenum(files(index).name(12:23), 'HH-MM-SS-FFF');    
    delay = (t2 - t1) * 24 * 60 * 60 - totalDelay;
    z = -1 : 0.01 : 1;
    axes(handles.waves);
    line = plot(delay, z);
    
    % ����slider��ֵ����Ϣ����
    set(handles.slider1, 'value', index/fileNum);
    disLine = ['��ǰΪ�� ', num2str(index), ' ��ͼƬ'];
    set(handles.displayer, 'String', disLine);
end


% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathname index files fileNum line t1 totalDelay

if index == fileNum
    set(handles.next, 'Visible', 'off');
    set(handles.previous, 'Visible', 'on');
    set(handles.endFrame, 'Visible', 'off');
end

% ����������һ��ͼƬ�����������е���Ϣ
if index < fileNum
    if index > 1
        set(handles.previous, 'Visible', 'on');
        set(handles.startFrame, 'Visible', 'on');
    end
    set(handles.next, 'Visible', 'on');
    set(handles.endFrame, 'Visible', 'on');
    index = index + 1;
    set(handles.picName, 'String', files(index).name);
    
    % ����ͼƬ��ʾ
    str = [pathname files(index).name];
    im = imread(str);
    axes(handles.pics);
    imshow(im);
    
    % ���±궨��
    delete(line);
    t2 = datenum(files(index).name(12:23), 'HH-MM-SS-FFF');
    delay = (t2 - t1) * 24 * 60 * 60 - totalDelay;
    z = -1 : 0.01 : 1;
    axes(handles.waves);
    line = plot(delay, z);
    
    %����slider��ֵ����Ϣ���ѿ�
    set(handles.slider1, 'value', index/fileNum);
    disLine = ['��ǰΪ�� ', num2str(index), ' ��ͼƬ'];
    set(handles.displayer, 'String', disLine);
end

    
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global pathname index fileNum files line t1 totalDelay

% ��ȡslider1����ֵ
index = fix(fileNum * get(handles.slider1, 'value'));
if index <= 1
    index = 1;
    set(handles.previous, 'Visible', 'off');
    set(handles.next, 'Visible', 'on');
    set(handles.startFrame, 'Visible', 'off');
end
if index >= fileNum
    index = fileNum;
    set(handles.previous, 'Visible', 'on');
    set(handles.next, 'Visible', 'off');
    set(handles.endFrame, 'Visible', 'off');
end
if index > 1 && index < fileNum
    set(handles.previous, 'Visible', 'on');
    set(handles.next, 'Visible', 'on');
    set(handles.startFrame, 'Visible', 'on');
    set(handles.endFrame, 'Visible', 'on');
end

% ����ͼƬ��������Ϣ
str = fullfile(pathname, 'RGBImages', files(index).name);
im = imread(str);
axes(handles.pics);
imshow(im);
set(handles.picName, 'String', files(index).name);

% ���±궨��
delete(line);
t2 = datenum(files(index).name(12:23), 'HH-MM-SS-FFF');
delay = (t2 - t1) * 24 * 60 * 60 - totalDelay;
z = -1 : 0.01 : 1;
axes(handles.waves);
line = plot(delay, z);

% ������Ϣ���ѿ�
disLine = ['��ǰΪ�� ', num2str(index), ' ��ͼƬ'];
set(handles.displayer, 'String', disLine);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function displayer_Callback(hObject, eventdata, handles)
% hObject    handle to displayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayer as text
%        str2double(get(hObject,'String')) returns contents of displayer as a double


% --- Executes during object creation, after setting all properties.
function displayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function picName_Callback(hObject, eventdata, handles)
% hObject    handle to picName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of picName as text
%        str2double(get(hObject,'String')) returns contents of picName as a double


% --- Executes during object creation, after setting all properties.
function picName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to picName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startFrame.
function startFrame_Callback(hObject, eventdata, handles)
% hObject    handle to startFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% �˴�ʵ�ֿ�ʼ֡�ı궨
global startPic startSave index files
%������¼��ʼ��ͼƬ���ơ���ʼ��ͼƬ֡��
startPic = files(index).name;
startSave = index;



% --- Executes on button press in endFrame.
function endFrame_Callback(hObject, eventdata, handles)
% hObject    handle to endFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% �˴�ʵ�ֽ���֡�ı궨
global endPic endSave index files startSave t1 y fs timeStart timeEnd totalDelay
%������¼������ͼƬ���֡�������ͼƬ֡��
endPic =  files(index).name ; 
endSave = index;
% ��ȡλ�ڿ�ʼ�����֡�����Ƶ��������
if(startSave < endSave && startSave > 5)    %�Է�ͼƬ��ʼʱ��������Ƶ
    % �ֱ�Ϊ��ʼ֡������֡��Ӧ��ʱ��
    timeStart = (datenum(files(startSave).name(12:23), 'HH-MM-SS-FFF') - t1)*24*60*60 - totalDelay;
    timeEnd = (datenum(files(endSave).name(12:23), 'HH-MM-SS-FFF') - t1)*24*60*60 - totalDelay;
    % ��ʱ�ı�����ʾ����ȡ��Ƶ��ʱ��
    delay = ['��Ƶʱ��Ϊ��', num2str(timeEnd-timeStart), 's'];
    set(handles.displayer, 'String', delay);
    % ��ȡ��Ƶ������
    wavPlay = y(int32(timeStart*fs) : int32(timeEnd*fs));
    sound(wavPlay, fs);
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global index fileNum pathname timeStart timeEnd

% �˴������е����ݶ����㣬Ȼ�����¿�ʼ
index = 0;
fileNum = 0;
pathname = ' ';
timeStart = 0.0;
timeEnd = 0.0;
set(handles.picName, 'String', ' ');
set(handles.displayer, 'String', ' ');
set(handles.selectPath, 'Visible', 'on');
set(handles.previous, 'Visible', 'on');
set(handles.next, 'Visible', 'on');
set(handles.startFrame, 'Visible', 'on');
set(handles.endFrame, 'Visible', 'on');
set(handles.slider1, 'value', 0);
cla(handles.pics);
cla(handles.waves);


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% �ڴ˴�ʵ�����������ݵı���
global startSave endSave files y fs nbits timeStart timeEnd pathname C
% ȫ�ֱ�������������ļ���
global depthDataFiles depthImageFiles outWaveFileName
%ѡ�񱣴�·����
[outPutFileName outPutPathName] = uiputfile('test.png','��ѡ��Ҫ�洢���ļ���');
% savedStr = outPutPathName;
% endIndex = length(savedStr) - 1;
% % ��ȡ�ļ��������硰san3��
% startIndex = endIndex;
% while startIndex > 1
%     if savedStr(startIndex) == '\'
%         break;
%     end
%     startIndex = startIndex - 1;
% end
% % ��ȡ˵���������硰yueshuai��
% secondIndex = startIndex - 1;
% while secondIndex > 1
%     if savedStr(secondIndex) == '\'
%         break;
%     end
%     secondIndex = secondIndex - 1;
% end
% thirdIndex = secondIndex - 1;
% while thirdIndex > 1
%     if savedStr(thirdIndex) == '\'
%         break;
%     end
%     thirdIndex = thirdIndex - 1;
% end
% outPutFileName = [savedStr(secondIndex + 1: startIndex - 1),'_',savedStr(startIndex + 1: endIndex)];
set(handles.displayer, 'String', outWaveFileName);


%����ͼƬ�Ľ�ȡʱ�䡢3D���ݵĽ�ȡ����
totalCount = endSave - startSave + 1;

%��ȡ��Ƶ,��д�뵽���ļ���
selectedWav = y(int32(timeStart*fs) : int32(timeEnd*fs), :);
% newWavName = [outPutFileName, '.wav'];
wavwrite(selectedWav, fs, nbits, [outPutPathName, outWaveFileName]);

%��ȡʵʱͼƬ(��ɫͼ�����ͼ���������)��
startFrame = startSave;
endFrame = endSave;
colorOutputPath = fullfile(outPutPathName, 'RGBImages');
depthOutputPath = fullfile(outPutPathName, 'adjustedDepthImages');
depthDataOutputPath = fullfile(outPutPathName, 'adjustedDepthData');
if ~exist(colorOutputPath, 'dir')
    mkdir(colorOutputPath);
    mkdir(depthOutputPath);
    mkdir(depthDataOutputPath);
end
% ѭ����ÿ��ͼƬ��д�뵽��·����
while(startFrame <= endFrame)
    input = fullfile(pathname, 'RGBImages', files(startFrame).name);
    copyfile(input, colorOutputPath);
    
    input1 = fullfile(pathname, 'AdjustedDepthImages', depthImageFiles(startFrame).name);
    copyfile(input1, depthOutputPath);
    
    input2 = fullfile(pathname, 'AdjustedDepthData', depthDataFiles(startFrame).name);
    copyfile(input2, depthDataOutputPath);
    
    startFrame = startFrame + 1;
end

%��ȡ3D����
[p, tmp_name, ext] = fileparts(outWaveFileName);
new3DName = [tmp_name, '.txt'];
fiout= fopen([outPutPathName, new3DName],'wt','n','utf-8');
% �趨�α꼰ǰ�����
startLine = (startSave-1)*121 + 1;
endLine = (endSave)*121;
for i = startLine:endLine
    tmp = [char(C{1}(i)), ' ', char(C{2}(i)), ' ', char(C{3}(i)), ' ', char(C{4}(i)), ' ', char(C{5}(i)), ' ', char(C{6}(i))];
    fprintf(fiout,'%s\n',tmp);
end
%content = textscan(fidin);
%fclose(fidin);
fclose(fiout);

% ����Ϣ���ѿ�����ʾ�洢��Ϣ
saveStr = ['�ѳɹ�����', num2str(totalCount), '��ͼƬ,�����'];
sound(selectedWav, fs);
set(handles.displayer, 'String', saveStr);
