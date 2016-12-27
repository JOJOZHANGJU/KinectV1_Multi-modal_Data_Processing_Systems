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
% 全局变量：路径名称，文件流，图片的index，总共的图片数，总延迟
global pathname files index fileNum totalDelay
% 全局变量：音频起始时间，当前图片所在音频位置的标定线，音频，采样率，比特数
global t1 line y fs nbits 
% 全局变量：标定的开始与结束的图片帧数，3DData数据
global startSave endSave C
% 全局变量：深度数据文件流，输出音频文件的文件名
global depthDataFiles depthImageFiles outWaveFileName

% 从选中的路径中获取所有的图片
[filename,filepath] = ...
    uigetfile({'*.png','*.bmp'},'请选择文件夹中的第一张图片');
path_index = strfind(filepath, filesep);
pathname = filepath(1:path_index(length(path_index)-1));
disp(pathname)
index = 1;
files = dir(fullfile(filepath, '*.png')); %获取彩色图片文件流

% 深度信息文件流
depthDataFiles = dir(fullfile(pathname, 'AdjustedDepthData', '*.csv'));
depthImageFiles = dir(fullfile(pathname, 'AdjustedDepthImages', '*.png'));

% 在pics控件中显示读取到的第一张图片
str = [filepath filename];
im = imread(str);
axes(handles.pics);
imshow(im);
% 在图片下方的空格中显示相应的图片名称
set(handles.picName, 'String', files(index).name);

% 在右上方的displayer中显示相应的index
fileNum = length(files);
disLine = ['当前为第 ', num2str(index), ' 张图片'];
set(handles.displayer, 'String', disLine);

% 设置图片存储的起始位置与结束位置
startSave = 0;
endSave = 0;

% 获取3DData文件信息(一次性获取数据，方便保存时写入)
fi3D = fopen([pathname,'3Ddata.txt'],'rt','n','utf-8');
C = textscan(fi3D, '%s %s %s %s %s %s');

% 读取该文件夹中的wav文件，下方的waves中显示音频信号
wavFiles = dir(fullfile(pathname, '*.wav'));
wavFile = [pathname, wavFiles(1).name];
outWaveFileName = wavFiles(1).name;

% 获取音频开始的时间
totalDelay = 0.09;
t1 = datenum(wavFiles(1).name(12:23), 'HH-MM-SS-FFF');
[y, fs, nbits] = wavread(wavFile);  %读入音频
t = (0 : length(y)-1) / fs;         %默认横轴为数据点，比特数
x = 0;
z = -1 : 0.01 : 1;
axes(handles.waves);
% 在waves框下加进度条控制音频
xlim([0,20]);
uicontrol('units','normalized','Style','slider','userdata',handles.waves,'pos',[.1 .1 .8 .03],'min',0,'max', 300,'callback',@(obj,event)set(get(obj,'userdata'),'xlim',[0,20]+get(obj,'value')));

plot(t, y);                         %画出音频的波形
line = plot(x, z);                  %画出标定线

% 在获取文件信息结束之后，将选择路径隐身（通过reset可以重新开始）
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

% 可以跳回到上一张图片，以及对应的所有显示都更新
if index > 1
    if index < fileNum
        set(handles.next, 'Visible', 'on');
        set(handles.endFrame, 'Visible', 'on');
    end
    set(handles.previous, 'Visible', 'on');
    set(handles.startFrame, 'Visible', 'on');
    index = index - 1;
    set(handles.picName, 'String', files(index).name);
    
    % 更新图片
    str = [pathname files(index).name];
    im = imread(str);
    axes(handles.pics);
    imshow(im);
    
    % 更新标定线
    delete(line);
    t2 = datenum(files(index).name(12:23), 'HH-MM-SS-FFF');    
    delay = (t2 - t1) * 24 * 60 * 60 - totalDelay;
    z = -1 : 0.01 : 1;
    axes(handles.waves);
    line = plot(delay, z);
    
    % 更新slider的值及消息提醒
    set(handles.slider1, 'value', index/fileNum);
    disLine = ['当前为第 ', num2str(index), ' 张图片'];
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

% 可以跳向下一张图片，并更新所有的信息
if index < fileNum
    if index > 1
        set(handles.previous, 'Visible', 'on');
        set(handles.startFrame, 'Visible', 'on');
    end
    set(handles.next, 'Visible', 'on');
    set(handles.endFrame, 'Visible', 'on');
    index = index + 1;
    set(handles.picName, 'String', files(index).name);
    
    % 更新图片显示
    str = [pathname files(index).name];
    im = imread(str);
    axes(handles.pics);
    imshow(im);
    
    % 更新标定线
    delete(line);
    t2 = datenum(files(index).name(12:23), 'HH-MM-SS-FFF');
    delay = (t2 - t1) * 24 * 60 * 60 - totalDelay;
    z = -1 : 0.01 : 1;
    axes(handles.waves);
    line = plot(delay, z);
    
    %更新slider的值及消息提醒框
    set(handles.slider1, 'value', index/fileNum);
    disLine = ['当前为第 ', num2str(index), ' 张图片'];
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

% 获取slider1的数值
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

% 更新图片及名称信息
str = fullfile(pathname, 'RGBImages', files(index).name);
im = imread(str);
axes(handles.pics);
imshow(im);
set(handles.picName, 'String', files(index).name);

% 更新标定线
delete(line);
t2 = datenum(files(index).name(12:23), 'HH-MM-SS-FFF');
delay = (t2 - t1) * 24 * 60 * 60 - totalDelay;
z = -1 : 0.01 : 1;
axes(handles.waves);
line = plot(delay, z);

% 更新消息提醒框
disLine = ['当前为第 ', num2str(index), ' 张图片'];
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
% 此处实现开始帧的标定
global startPic startSave index files
%用来记录开始的图片名称、开始的图片帧数
startPic = files(index).name;
startSave = index;



% --- Executes on button press in endFrame.
function endFrame_Callback(hObject, eventdata, handles)
% hObject    handle to endFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 此处实现结束帧的标定
global endPic endSave index files startSave t1 y fs timeStart timeEnd totalDelay
%用来记录结束的图片名字、结束的图片帧数
endPic =  files(index).name ; 
endSave = index;
% 获取位于开始与结束帧间的音频，并播放
if(startSave < endSave && startSave > 5)    %以防图片开始时间早于音频
    % 分别为开始帧及结束帧对应的时间
    timeStart = (datenum(files(startSave).name(12:23), 'HH-MM-SS-FFF') - t1)*24*60*60 - totalDelay;
    timeEnd = (datenum(files(endSave).name(12:23), 'HH-MM-SS-FFF') - t1)*24*60*60 - totalDelay;
    % 此时文本框显示所截取音频的时长
    delay = ['音频时长为：', num2str(timeEnd-timeStart), 's'];
    set(handles.displayer, 'String', delay);
    % 获取音频并播放
    wavPlay = y(int32(timeStart*fs) : int32(timeEnd*fs));
    sound(wavPlay, fs);
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global index fileNum pathname timeStart timeEnd

% 此处将所有的数据都归零，然后重新开始
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
% 在此处实现在所有数据的保存
global startSave endSave files y fs nbits timeStart timeEnd pathname C
% 全局变量：深度数据文件流
global depthDataFiles depthImageFiles outWaveFileName
%选择保存路径：
[outPutFileName outPutPathName] = uiputfile('test.png','请选择要存储的文件夹');
% savedStr = outPutPathName;
% endIndex = length(savedStr) - 1;
% % 获取文件夹名，如“san3”
% startIndex = endIndex;
% while startIndex > 1
%     if savedStr(startIndex) == '\'
%         break;
%     end
%     startIndex = startIndex - 1;
% end
% % 获取说话人名，如“yueshuai”
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


%计算图片的截取时间、3D数据的截取个数
totalCount = endSave - startSave + 1;

%截取音频,并写入到新文件中
selectedWav = y(int32(timeStart*fs) : int32(timeEnd*fs), :);
% newWavName = [outPutFileName, '.wav'];
wavwrite(selectedWav, fs, nbits, [outPutPathName, outWaveFileName]);

%获取实时图片(彩色图像、深度图像、深度数据)：
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
% 循环将每张图片都写入到新路径下
while(startFrame <= endFrame)
    input = fullfile(pathname, 'RGBImages', files(startFrame).name);
    copyfile(input, colorOutputPath);
    
    input1 = fullfile(pathname, 'AdjustedDepthImages', depthImageFiles(startFrame).name);
    copyfile(input1, depthOutputPath);
    
    input2 = fullfile(pathname, 'AdjustedDepthData', depthDataFiles(startFrame).name);
    copyfile(input2, depthDataOutputPath);
    
    startFrame = startFrame + 1;
end

%获取3D数据
[p, tmp_name, ext] = fileparts(outWaveFileName);
new3DName = [tmp_name, '.txt'];
fiout= fopen([outPutPathName, new3DName],'wt','n','utf-8');
% 设定游标及前后界限
startLine = (startSave-1)*121 + 1;
endLine = (endSave)*121;
for i = startLine:endLine
    tmp = [char(C{1}(i)), ' ', char(C{2}(i)), ' ', char(C{3}(i)), ' ', char(C{4}(i)), ' ', char(C{5}(i)), ' ', char(C{6}(i))];
    fprintf(fiout,'%s\n',tmp);
end
%content = textscan(fidin);
%fclose(fidin);
fclose(fiout);

% 在消息提醒框中显示存储信息
saveStr = ['已成功保存', num2str(totalCount), '张图片,请继续'];
sound(selectedWav, fs);
set(handles.displayer, 'String', saveStr);
