function Calculator
%% 全局变量
global GUI
% 计算器待运算的字符串
global strPendingEvaluation
% 上一次运算的结果
global previousCalculationResult

% 模式转换三状态
% displayPrecision 输出结果的时候用
% complexFormat 在输出值为复数的时候用
% angularUnit 极直互换的时候用
global displayPrecision complexFormat angularUnit

% 控制工程存储的用户输入
global upperG lowerG upperH lowerH parameterPID

% 画图类型选择
global plotLineOrFunctionChosed
%画折线图 数据与x的个数
global xDataLine yDataLine xCountLine
% 画函数图 表达式与坐标轴范围
global funcGraphExpression xLimFunc yLimFunc

% 积分
global intUpperLimit  intLowerLimit intKindChosed
% 求导
global derivativedExpression

% 定位多状态过程运行节点
% 模式转换进行到哪步了 max:(3)
global modeChoosingState
% 控制工程进行到哪一步了 max:(7)
global controlSystemsimulatingState
% 画图到哪一步了 max:(4/3)
global plottingState
% 求根到哪一步了 max:(2)
global findRootState
% 积分和求导进行到哪一步了 max:(4/3,4)
global intState diffState
% 极坐标和直角坐标的互换进行到哪一步了 max:(2)
global polState recState


% 初始化全局变量
strPendingEvaluation = '0'; previousCalculationResult = '0';

modeChoosingState = 0;
displayPrecision = 1; complexFormat = 1; angularUnit = 1;

controlSystemsimulatingState = 0;
upperG = 1;lowerG = [1 10];upperH = 1;lowerH = 1;
parameterPID  = [1 0 0];

plottingState = 0;
plotLineOrFunctionChosed = 2;% 画折线图
xDataLine = []; yDataLine = []; xCountLine = 0;
xLimFunc = []; yLimFunc = [];

findRootState = 0;

intState = 0;
intUpperLimit = inf; intLowerLimit = -inf;
intKindChosed = 1;% 定积分

diffState = 0;
derivativedExpression = '';

polState = 0; recState = 0;

%% 计算器figure界面参数
fhHeight = 1100;
fhWidth = 600;
fhLeft = 1200;
fhBottom = 90;
GUI.fh = figure('units','pixels',...
    'position',[fhLeft fhBottom fhWidth fhHeight],...
    'menubar','none',...
    'name','Calculator','NumberTitle','off');


% 计算器布局: 按钮9行5列，显示屏占3行5列的距离
% 大多数(最小)按钮大小 宽*高 = 108*88
% 各相对距离
btnWidth =  0.18; % 按钮宽度
btnHeight = 0.08; % 按钮高度
btnHorDis = (1 - 5*btnWidth)/6; % 两个按钮之间的水平距离
btnVerDis = (1 - 12*btnHeight)/11; % 两个按钮之间的竖直距离
btnInitLeft = btnHorDis;% 按钮离左边框的基准距离
btnInitBottom = btnVerDis;% 按钮离底边框的基准距离

%% 按钮布局
% Position 按钮位置 [left bottom width height]
% 数字按键 digit组
GUI.button0 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft btnInitBottom btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','0', ...
    'FontUnits','normalized', ...% 字体大小随窗口变化
    'FontSize',0.5,...
    'callback',{@processDigit,'0'},...
    'UserData', 'digit');
GUI.button1 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft btnInitBottom ...
    + (btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','1', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'1'},...
    'UserData', 'digit');
GUI.button2 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + (btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','2', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'2'},...
    'UserData', 'digit');
GUI.button3 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + (btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','3', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'3'},...
    'UserData', 'digit');
GUI.button4 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 2*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','4', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'4'},...
    'UserData', 'digit');
GUI.button5 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + 2*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','5', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'5'},...
    'UserData', 'digit');
GUI.button6 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + 2*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','6', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'6'},...
    'UserData', 'digit');
GUI.button7 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 3*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','7', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'7'},...
    'UserData', 'digit');
GUI.button8 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + 3*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','8', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'8'},...
    'UserData', 'digit');
GUI.button9 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + 3*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','9', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processDigit,'9'},...
    'UserData', 'digit');

% 小数点、倒数运算、等于号、加减乘除按键
% Equal 在求导与积分、画图、模式转换、求根、控制工程复用为"下一步"
% 除了选择模式情况之外都能用，属于 basic1 组
% 除了选择模式和输入数据的情况之外都能用，属于 basic2 组
% Equal(下一步)在任何情况下都能用，属于 essential 组
GUI.buttonDot = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','.', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@executeBasicOperation,'.'},...
    'UserData', 'basic1');
GUI.buttonReciprocal = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','1/x', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@performAdvancedCalculation,'Recip'},...
    'UserData', 'basic2');
GUI.buttonDiv = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','÷', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@executeBasicOperation,'/'},...
    'UserData', 'basic2');
GUI.buttonEqual = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','=', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@evalPendingStr},...
    'UserData', 'essential');
GUI.buttonSub = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + (btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','-', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@executeBasicOperation,'-'},...
    'UserData', 'basic2');
GUI.buttonMult= uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + (btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','*', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@executeBasicOperation,'*'},...
    'UserData', 'basic2');
GUI.buttonAdd = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + 2*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','+', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@executeBasicOperation,'+'},...
    'UserData', 'basic2');

% Ans、回退、清空按键
% 求导与积分、画图、模式转换、求根、控制工程复用为"退出"
% Ans(退出)在任何情况下都能用，属于 essential 组
% 回退和清空除了选择模式的情况之外一般都能用，属于 basic1 组
GUI.buttonAns = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + 2*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','Ans', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@recallPreviousCalculationResult},...
    'UserData', 'essential');
GUI.buttonBackspace = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + 3*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','回退', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@performBackspace},...
    'UserData', 'basic1');
GUI.buttonEmpty = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + 3*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','清空', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@performEmpty},...
    'UserData', 'basic1');

% 第五行: 画图、求根、控制工程、逗号按键
% 画图、求根、控制工程 属于 function 组
% 逗号 只能在输入数据的时候使用，分为 other 组
GUI.buttonPlot = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 4*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','画图', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@startPlotGraph},...
    'UserData', 'function');
GUI.buttonFindRoot = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + 4*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','求根', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@startFindRoot},...
    'UserData', 'function');
GUI.buttonControlSystem = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis) btnInitBottom ...
    + 4*(btnHeight + btnVerDis) 2*btnWidth + btnHorDis btnHeight], ...
    'Style','pushbutton',...
    'String','控制工程', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@simulateControlSystem},...
    'UserData', 'function');
GUI.buttonComma= uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis) btnInitBottom ...
    + 4*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String',',', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processComma},...
    'UserData', 'other');

% 第六行: 求导、i、Pol(将直角坐标转为极坐标)、Rec(将极坐标转为直角坐标)、x
% 求导、POL、REC 属于 function 组
% i 不能用于极直坐标转换、画图、模式转换、控制工程，分为 other 组
% x 只能用于输入表达式的情况，即画函数图、积分、求导，分为 other 组
GUI.buttonDerive = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 5*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','d□/dx', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@startCalculateDifferentiation},...
    'UserData', 'function');
GUI.buttoni = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + 5*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','i', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processImaginaryi},...
    'UserData', 'other');
GUI.buttonPol = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + 5*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','Pol', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@startConvertCoordinates,'cart2pol'},...
    'UserData', 'function');
GUI.buttonRec = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + 5*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','Rec', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@startConvertCoordinates,'pol2cart'},...
    'UserData', 'function');
GUI.buttonx = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + 5*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','x', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processUnknownx},...
    'UserData', 'other');

% 第七行: 左括号、右括号、sin-1、cos-1、tan-1
% 左括号、右括号 sin-1、cos-1、tan-1 属于 basic2 组
GUI.buttonLeftBracket = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 6*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','(', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processBracket,'('},...
    'UserData', 'basic2');
GUI.buttonRightBracket = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + 6*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String',')', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@processBracket,')'},...
    'UserData', 'basic2');
GUI.buttonarcsin= uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + 6*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','arcsin', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@performAdvancedCalculation,'asin'},...
    'UserData', 'basic2');
GUI.buttonarccos= uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + 6*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','arccos', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@performAdvancedCalculation,'acos'},...
    'UserData', 'basic2');
GUI.buttonarctan= uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + 6*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','arctan', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@performAdvancedCalculation,'atan'},...
    'UserData', 'basic2');

% 第八行: 模式转换、sin、cos、tan
% 模式转换 属于 function 组
% sin、cos、tan 属于 basic2 组
GUI.buttonMode = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 7*(btnHeight + btnVerDis) 2*btnWidth + btnHorDis btnHeight], ...
    'Style','pushbutton',...
    'String','模式转换', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@chooseCalculatorMode},...
    'UserData', 'function');
GUI.buttonsin = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + 7*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','sin', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@performAdvancedCalculation,'sin'},...
    'UserData', 'basic2');
GUI.buttoncos = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + 7*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','cos', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@performAdvancedCalculation,'cos'},...
    'UserData', 'basic2');
GUI.buttontan= uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + 7*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton',...
    'String','tan', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'callback',{@performAdvancedCalculation,'tan'},...
    'UserData', 'basic2');

% 第九行: 积分、e^x、a^x、log10x、lnx
% 积分 属于 function 组
% e^x、a^x、log10x、lnx 属于 basic2 组
GUI.buttonIntegral = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft  btnInitBottom ...
    + 8*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@startCalculateIntegration},...
    'UserData', 'function');
imgIntegralRaw = imread('积分.jpg');
imgIntegral = imresize(imgIntegralRaw,[88,108]);
set(GUI.buttonIntegral,'CData',imgIntegral);

GUI.buttonExp = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + (btnWidth + btnHorDis)  btnInitBottom ...
    + 8*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton', ...
    'String','e^□', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@performAdvancedCalculation,'exp'},...
    'UserData', 'basic2');
GUI.buttonPow = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 2*(btnWidth + btnHorDis)  btnInitBottom ...
    + 8*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton', ...
    'String','a^□', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@performAdvancedCalculation,'^'},...
    'UserData', 'basic2');
GUI.buttonlog10 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 3*(btnWidth + btnHorDis)  btnInitBottom ...
    + 8*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton', ...
    'String','log10□', ...
    'FontUnits','normalized', ...
    'FontSize',0.35,...
    'callback',{@performAdvancedCalculation,'log10'},...
    'UserData', 'basic2');
GUI.buttonln = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft + 4*(btnWidth + btnHorDis)  btnInitBottom ...
    + 8*(btnHeight + btnVerDis) btnWidth btnHeight], ...
    'Style','pushbutton', ...
    'String','ln□', ...
    'FontUnits','normalized', ...
    'FontSize',0.5,...
    'callback',{@performAdvancedCalculation,'log'},...
    'UserData', 'basic2');

% 显示屏两行文本
% 从上往下第一行
GUI.textDisplay1 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft btnInitBottom ...
    + 10.5*btnHeight + 10*btnVerDis 5*btnWidth + 4*btnHorDis 1.5*btnHeight], ...
    'Style','text', ...
    'String','0', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'HorizontalAlignment','right'); % HorizontalAlignment 文本对齐方式

% 从上往下第二行
GUI.textDisplay2 = uicontrol('Parent',GUI.fh, ...
    'Units','normalized',...
    'Position',[btnInitLeft btnInitBottom ...
    + 9*(btnHeight + btnVerDis) 5*btnWidth + 4*btnHorDis 1.5*btnHeight], ...
    'Style','text', ...
    'String','0', ...
    'FontUnits','normalized', ...
    'FontSize',0.4,...
    'HorizontalAlignment','right'); % HorizontalAlignment 文本对齐方式

initOrReset;
end

%% 回调函数
% 处理数字
function processDigit(~,~,strNum)
global GUI strPendingEvaluation modeChoosingState
global displayPrecision complexFormat angularUnit
global intState intKindChosed
global plottingState plotLineOrFunctionChosed
global controlSystemsimulatingState
% 模式转换 1~3
switch modeChoosingState
    % 设置显示精度
    case 1
        switch strNum
            case '1'
                displayPrecision = 1;
            case '2'
                displayPrecision = 2;
            case '3'
                displayPrecision = 3;
            case '4'
                displayPrecision = 4;
            otherwise
                return;
        end
        set(GUI.textDisplay1,'String','复数表示');
        set(GUI.textDisplay2,'String',{'1.a+bi ','2. A∠φ'},...
            'HorizontalAlignment','right');
        modeChoosingState = modeChoosingState + 1;
        return;
        % 设置复数表示
    case 2
        switch strNum
            case '1'
                complexFormat = 1; % a+bi
            case '2'
                complexFormat = 2; % A∠φ
            otherwise
                return;
        end

        set(GUI.textDisplay1,'String','角度单位');
        set(GUI.textDisplay2,'String',{'1.角度制','2. 弧度制'},...
            'HorizontalAlignment','right');
        modeChoosingState = modeChoosingState + 1;
        return;
    case 3
        switch strNum
            case '1'
                angularUnit = 1; % 角度制
            case '2'
                angularUnit = 2; % 弧度制
            otherwise
                return;
        end
        initOrReset; % 最后一个状态
        modeChoosingState = 0;
        return;
end

% 积分 1
if  intState == 1
    switch strNum
        case '1'
            intKindChosed = 1;
            initBtnForData;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String',...
                '输入积分上下限(下限,上限)(默认为：-inf,+inf): ');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        case '2'
            intKindChosed = 2;
            initBtnForExpression;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','输入表达式: ');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        otherwise
            return;
    end
    intState = intState + 1;
    return;
end

% 画图 1
if plottingState == 1
    switch strNum
        case '1'
            plotLineOrFunctionChosed = 1;
            initBtnForData;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','输入横坐标轴的范围(用逗号分隔)：');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        case '2'
            plotLineOrFunctionChosed = 2;
            initBtnForData;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String', ...
                '输入x(用逗号分隔):');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        otherwise
            return;
    end
    plottingState = plottingState + 1;
    return;
end

% 控制工程 6 7
switch controlSystemsimulatingState
    case 6
        controlSystemAnalysis(strNum)
        return;
    case 7 % 修改系统（回退步骤）
        switch strNum
            case '1' % 回退到设置pid参数
                controlSystemsimulatingState = 5;
                initBtnForData;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String',...
                    '请输入pid参数(kp,ki,kd): ');
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            case '2' % 回退到设置反馈通路传递函数分子
                controlSystemsimulatingState = 3;
                initBtnForData;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String',{'反馈通路传递函数(默认为1): ',...
                    '分子系数(逗号分隔降幂排列): '},'FontSize',0.3);
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            case '3' % 回退到设置前向通路传递函数分子
                controlSystemsimulatingState = 1;
                initBtnForData;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String',{'前向通路传递函数: ',...
                    '分子系数(逗号分隔降幂排列): '},'FontSize',0.3);
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            otherwise
                return;
        end
        set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
        return;
end

% 一般情况
if strPendingEvaluation == '0'
    strPendingEvaluation = strNum;
else
    if ~ismember(strPendingEvaluation(end),['i','x',')'])
        strPendingEvaluation = [strPendingEvaluation strNum];
    end
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% 处理加减乘除和小数点
function executeBasicOperation(~,~,operator)
global GUI strPendingEvaluation
if ~ismember(strPendingEvaluation(end),['.','(','+','-','*','/'])
    % 负号
    if operator == '-' && strcmp(strPendingEvaluation,'0')
        strPendingEvaluation = '-';
    else
        strPendingEvaluation = [strPendingEvaluation operator];
    end
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% 处理'i'
% 不能用于极直坐标转换、画图、模式转换、控制工程
function processImaginaryi(~,~)
global GUI strPendingEvaluation
if strcmp(strPendingEvaluation,'0')
    strPendingEvaluation = 'i';
elseif  ~ismember(strPendingEvaluation(end),['.','i','x',')'])
    strPendingEvaluation = [strPendingEvaluation 'i'];
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% 处理'括号'
function processBracket(~,~,bracket)
global GUI strPendingEvaluation
switch bracket
    case '('
        if strcmp(strPendingEvaluation,'0')
            strPendingEvaluation = '(';
        elseif  ~ismember(strPendingEvaluation(end),['.','i','x',')','0',...
                '1','2','3','4','5','6','7','8','9'])
            strPendingEvaluation = [strPendingEvaluation '('];
        end
    case ')'
        if strcmp(strPendingEvaluation,'0')
            strPendingEvaluation = '(';
        elseif  ~ismember(strPendingEvaluation(end),['.','(','+','-','*',...
                '/'])
            strPendingEvaluation = [strPendingEvaluation ')'];
        end
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% 处理等于号
% 极直互换、画图、模式转换、求根、控制工程、求导与积分中复用为'下一步'
function evalPendingStr(~,~)
global GUI strPendingEvaluation previousCalculationResult
global displayPrecision complexFormat angularUnit
global modeChoosingState polState recState findRootState
global intState intKindChosed
global intUpperLimit intLowerLimit
global diffState derivativedExpression
global plottingState plotLineOrFunctionChosed
global xDataLine yDataLine xCountLine
global funcGraphExpression  xLimFunc yLimFunc
global controlSystemsimulatingState
global upperG lowerG upperH lowerH parameterPID
global controlSystemOptionChosed
strDisplay = get(GUI.buttonEqual, 'String');
% 处理多状态过程
if ~strcmp(strDisplay, '退出') % 可以是'下一步'或'选择界面'
    % 模式转换
    switch modeChoosingState
        case 1
            set(GUI.textDisplay1,'String','复数表示');
            set(GUI.textDisplay2,'String',{'1.a+bi ','2. A∠φ'},...
                'HorizontalAlignment','right');
            modeChoosingState = modeChoosingState + 1;
            return;
        case 2
            set(GUI.textDisplay1,'String','角度单位');
            set(GUI.textDisplay2,'String',{'1.角度制','2. 弧度制'},...
                'HorizontalAlignment','right');
            modeChoosingState = modeChoosingState + 1;
            return;
        case 3
            modeChoosingState = 0;
            initOrReset;
            return;
    end

    % 处理极直互换
    % 直角坐标转为极坐标
    if polState >= 1
        if polState == 1
            [isMatch, numberCount] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch && numberCount == 2
                polState = polState + 1;
                initBtnForDisplay;
                set(GUI.textDisplay1,'String','结果');
                set(GUI.textDisplay2,'String',...
                    convertCoordinates(strPendingEvaluation));
            else
                polState = 0;
                initBtnForDisplay;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String','错误: 该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String', strPendingEvaluation);
            end
            clear isMatch numberCount
            return;
        else
            polState = 0;
            initOrReset;
            return;
        end
    end

    % 极坐标转为直角坐标
    if recState >= 1
        if recState == 1
            [isMatch, numberCount] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch && numberCount == 2
                recState = recState + 1;
                initBtnForDisplay;
                set(GUI.textDisplay1,'String','结果');
                set(GUI.textDisplay2,'String',...
                    convertCoordinates(strPendingEvaluation));
            else
                recState = 0;
                initBtnForDisplay;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String','错误: 该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String', strPendingEvaluation);
            end
            clear isMatch numberCount;
            return;
        else
            recState = 0;
            initOrReset;
            return;
        end
    end

    % 求根
    if findRootState
        try
            [numericRoot, exactRoot] = findRoots(strPendingEvaluation);
        catch
            findRootState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: 表达式不完整。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
            return;
        end
        if ~isnan(exactRoot)
            previousCalculationResult = allNum2Char(exactRoot);
            set(GUI.textDisplay1,'String','精确解: ');
            if displayPrecision ~= 4
                set(GUI.textDisplay2,'String',...
                    previousCalculationResult);
            end

        elseif ~isnan(numericRoot)
            previousCalculationResult = allNum2Char(numericRoot);
            set(GUI.textDisplay1,'String','解析解: ');
            if displayPrecision ~= 4
                set(GUI.textDisplay2,'String',...
                    previousCalculationResult);
            end

        else
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: 无法求解。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        end
        findRootState = 0;
        clear exactRoot numericRoot;
        return;
    end

    % 定积分 第一状态默认选项
    if intState == 1 && intKindChosed == 1 % 默认选项
        initBtnForData;
        strPendingEvaluation = '0';
        set(GUI.textDisplay1,'String',...
            '输入积分上下限(下限,上限)(默认为：-inf,+inf): ');
        set(GUI.textDisplay2,'String', strPendingEvaluation);
        intState = intState + 1;
        return;
    end

    % 定积分 第二状态
    if intState == 2 && intKindChosed == 1
        [isMatch, numberCount] = isCommaSeparatedNumbers(...
            strPendingEvaluation);

        if isMatch && numberCount == 2
            % 储存积分上下限
            intLimit = sscanf(strPendingEvaluation,'%f,%f');
            [intLowerLimit, intUpperLimit] = deal(min(intLimit),...
                max(intLimit));

            intState = intState + 1;
            initBtnForExpression;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','输入表达式: ');
            set(GUI.textDisplay2,'String',strPendingEvaluation);
            clear intLimit;
        else
            if strcmp(strPendingEvaluation,'0') % 取默认值 [-inf, inf]
                intLowerLimit = -inf;
                intUpperLimit = inf;
                intState = intState + 1;
                initBtnForExpression;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String','输入表达式: ');
                set(GUI.textDisplay2,'String',strPendingEvaluation);

            else % 输入有误
                intState = 0;
                initBtnForDisplay;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String','错误: 该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String', strPendingEvaluation);
            end
        end
        clear isMatch numberCount;
        return;
    end

    % 定积分 第三状态
    if intState == 3 && intKindChosed == 1
        integralValue = calculateDefiniteIntegral(intLowerLimit,...
            intUpperLimit,strPendingEvaluation);

        if ismember('错误',integralValue) % integralValue 为报错信息
            intState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String', integralValue);
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        else % integralValue 为积分结果
            intState = 0;
            previousCalculationResult = num2str(integralValue);
            initBtnForDisplay;
            set(GUI.textDisplay1,'String',{['积分上限: ',...
                num2str(intLowerLimit)],['积分下限: ',...
                num2str(intUpperLimit)]});
            set(GUI.textDisplay2,'String', {'积分结果: ',integralValue});
        end
        clear integralValue;
        return;
    end

    % 不定积分 第二状态
    if intState == 2 && intKindChosed == 2
        integralExpression = calculateIndefiniteIntegral(...
            strPendingEvaluation);

        if ismember('错误',integralExpression) % integralExpression 为报错信息
            intState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String', integralExpression);
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        else % integralValue 为积分结果
            intState = 0;
            initBtnForDisplay;
            set(GUI.textDisplay1,'String','积分结果: ');
            set(GUI.textDisplay2,'String', integralExpression);
        end
        clear integralExpression;
        return;
    end

    % 求导
    switch diffState
        case 1
            derivativedExpression = calculateDerivative(strPendingEvaluation);
            if ismember('错误',derivativedExpression) % derivativedExpression 为报错信息
                diffState = 0;
                initBtnForDisplay;
                strPendingEvaluation = '0';
                set(GUI.textDisplay1,'String', derivativedExpression);
                set(GUI.textDisplay2,'String', strPendingEvaluation);
            else % derivativedExpression 为求导结果
                diffState = diffState + 1;
                initBtnForDisplay;
                set(GUI.textDisplay1,'String', ...
                    {'已输入表达式: ',strPendingEvaluation});
                set(GUI.textDisplay2,'String', ...
                    {'求导结果: ',derivativedExpression});
            end
            return;
        case 2
            diffState = diffState + 1;
            initBtnForData;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String', ...
                '输入要代入表达式的x(用逗号分隔):');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
            return;
        case 3
            resultStr = evaluateExpressionForNumbers(...
                strPendingEvaluation, derivativedExpression);
            if ismember('错误',resultStr) % resultStr 为报错信息
                initBtnForDisplay;
                strPendingEvaluation = '0';
                derivativedExpression = '';
                set(GUI.textDisplay1,'String', resultStr);
                set(GUI.textDisplay2,'String', strPendingEvaluation);
            else % resultStr 为代入结果
                initBtnForDisplay;
                strPendingEvaluation = '0';
                derivativedExpression = '';
                set(GUI.textDisplay1,'String','代入结果: ');
                set(GUI.textDisplay2,'String', resultStr);
            end
            clear resultStr;
            return;
    end

    % 画折线图图 第一状态默认选项
    if plottingState == 1 && plotLineOrFunctionChosed == 2
        plottingState = plottingState + 1;
        initBtnForData;
        strPendingEvaluation = '0';
        set(GUI.textDisplay1,'String', ...
            '输入x(用逗号分隔):');
        set(GUI.textDisplay2,'String', strPendingEvaluation);
        return;
    end

    % 画折线图 第二状态
    if plottingState == 2 && plotLineOrFunctionChosed == 2
        [isMatch, xCountLine] = isCommaSeparatedNumbers(...
            strPendingEvaluation);

        if isMatch
            plottingState = plottingState + 1;
            xDataLine = str2num(strPendingEvaluation);
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String', ...
                {['已输入x个数：',num2str(xCountLine)],'输入y(用逗号分隔):'});
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        else
            xCountLine = 0;
            plottingState = 0;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: 该语句不完整(或误用减号)。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        end
        clear isMatch
        return;
    end

    % 画折线图 第三状态
    if plottingState == 3 && plotLineOrFunctionChosed == 2
        [isMatch, yCountLine] = isCommaSeparatedNumbers(...
            strPendingEvaluation);

        if isMatch && yCountLine == xCountLine
            plottingState = 0;
            xCountLine = 0;
            yDataLine = str2num(strPendingEvaluation);
            f = figure;
            f.CloseRequestFcn = @closeFigure;

            initBtnForDisplay;
            % 格式化输出数据
            xDataDisplay = strjoin(arrayfun(@(x) sprintf('%g', x),...
                xDataLine, 'UniformOutput', false), ',');
            yDataDisplay = strjoin(arrayfun(@(x) sprintf('%g', x),...
                yDataLine, 'UniformOutput', false), ',');

            set(GUI.textDisplay1,'String',...
                {['x数据: ', xDataDisplay],['y数据: ', yDataDisplay]});
            set(GUI.textDisplay2,'String', '绘制结果显示在新图窗。',...
                'FontSize',0.3);
            plotLineGraph(xDataLine, yDataLine);
            xDataLine = 0; yDataLine = 0;
            clear xDataDisplay yDataDisplay
        else
            xCountLine = 0;
            plottingState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: y数目与x不同。 ');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        end
        clear isMatch yCountLine
        return
    end

    % 画函数图 第二状态
    if plottingState == 2 && plotLineOrFunctionChosed == 1
        [isMatch, numberCount] = isCommaSeparatedNumbers(...
            strPendingEvaluation);
        if isMatch && numberCount == 2
            plottingState = plottingState + 1;
            xLimFunc = sort(str2double(strsplit(strPendingEvaluation, ',')));

            if xLimFunc(1) == xLimFunc(2)
                plottingState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: 上限与下限不能相等。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
            clear isMatch numberCount
            return;
            end

            initBtnForData;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','输入纵坐标轴的范围(用逗号分隔)：');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        else
            plottingState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: 该语句不完整(或误用减号)。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        end
        clear isMatch numberCount
        return;
    end

    % 画函数图 第三状态
    if plottingState == 3 && plotLineOrFunctionChosed == 1
        [isMatch, numberCount] = isCommaSeparatedNumbers(...
            strPendingEvaluation);
        if isMatch && numberCount == 2
            plottingState = plottingState + 1;
            yLimFunc = sort(str2double(strsplit(strPendingEvaluation, ',')));

            if yLimFunc(1) == yLimFunc(2)
                plottingState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','错误: 上限与下限不能相等。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
            clear isMatch numberCount
            return;
            end

            initBtnForExpression;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','输入表达式：');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        else
            plottingState = 0;
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String','该语句不完整(或误用减号)。');
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        end
        clear isMatch numberCount
        return;
    end

    % 画函数图 第四状态
    if plottingState == 4 && plotLineOrFunctionChosed == 1
        errorInfo = plotFunctionGraph(strPendingEvaluation,...
            xLimFunc,yLimFunc);

        if ~isempty(errorInfo) % 错误：表达式不完整
            initBtnForDisplay;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String', errorInfo);
            set(GUI.textDisplay2,'String', strPendingEvaluation);
        else % 画图
            f = figure;
            f.CloseRequestFcn = @closeFigure;

            initBtnForDisplay;
            xLimDisplay = strjoin(arrayfun(@(x) sprintf('%g', x),...
                xLimFunc, 'UniformOutput', false), ',');
            yLimDisplay = strjoin(arrayfun(@(x) sprintf('%g', x),...
                yLimFunc, 'UniformOutput', false), ',');

            set(GUI.textDisplay1,'String',...
                {['横轴范围: ', xLimDisplay],...
                ['纵轴范围: ', yLimDisplay]});
            set(GUI.textDisplay2,'String',...
                {['函数表达式: ',strPendingEvaluation],...
                '绘制结果显示在新图窗。'},'FontSize',0.3);
            plotFunctionGraph(strPendingEvaluation,xLimFunc,yLimFunc);
            xLimFunc = []; yLimFunc = [];
            clear xLimDisplay yLimDisplay
        end
        plottingState = 0;
        clear errorInfo;
        return;
    end

    % 处理控制工程
    switch controlSystemsimulatingState
        case 1
            [isMatch, ~] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch
                upperG = str2double(strsplit(strPendingEvaluation, ','));
                if sum(upperG,'all') == 0 % 输入不会影响输出，无意义
                    controlSystemsimulatingState = 0;
                    initBtnForDisplay;
                    strPendingEvaluation ='0';
                    set(GUI.textDisplay1,'String',...
                        '错误: 前向通道传递函数为0。');
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                else
                    controlSystemsimulatingState = ...
                        controlSystemsimulatingState + 1;
                    strPendingEvaluation = '0';
                    set(GUI.textDisplay1,'String',{'前向通路传递函数: ',...
                        '分母系数(逗号分隔降幂排列): '},'FontSize',0.3);
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                end
            else % 语句不完整(或误用减号)
                controlSystemsimulatingState = 0;
                initBtnForDisplay;
                strPendingEvaluation ='0';
                set(GUI.textDisplay1,'String',...
                    '该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            end
            clear isMatch
            return;
        case 2
            [isMatch, ~] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch
                lowerG = str2double(strsplit(strPendingEvaluation, ','));
                if sum(lowerG,'all') == 0 % 分母为0，无意义
                    controlSystemsimulatingState = 0;
                    initBtnForDisplay;
                    strPendingEvaluation ='0';
                    set(GUI.textDisplay1,'String',...
                        '错误: 前向通道传递函数分母为0。');
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                else
                    controlSystemsimulatingState = ...
                        controlSystemsimulatingState + 1;
                    strPendingEvaluation = '0';
                    set(GUI.textDisplay1,'String',{'反馈通路传递函数(默认为1): ',...
                        '分子系数(逗号分隔降幂排列): '},'FontSize',0.3);
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                end
            else % 语句不完整(或误用减号)
                controlSystemsimulatingState = 0;
                initBtnForDisplay;
                strPendingEvaluation ='0';
                set(GUI.textDisplay1,'String',...
                    '该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            end
            clear isMatch
            return;
        case 3
            [isMatch, ~] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch
                upperH = str2double(strsplit(strPendingEvaluation, ','));
                if strcmp(strPendingEvaluation,'0') % 默认单位反馈
                    controlSystemsimulatingState = ...
                        controlSystemsimulatingState + 2;
                    strPendingEvaluation = '0';
                    set(GUI.textDisplay1,'String',...
                        '请输入pid参数(kp,ki,kd): ');
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                    return;

                elseif sum(upperH,'all') == 0 % 输入不会影响输出，无意义
                    controlSystemsimulatingState = 0;
                    initBtnForDisplay;
                    strPendingEvaluation ='0';
                    set(GUI.textDisplay1,'String',...
                        '错误: 反馈通道传递函数为0。');
                    upperH = 1; % 还原默认值
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                else
                    controlSystemsimulatingState = ...
                        controlSystemsimulatingState + 1;
                    strPendingEvaluation = '0';
                    set(GUI.textDisplay1,'String',{'反馈通路传递函数',...
                        '分母系数(逗号分隔降幂排列): '},'FontSize',0.3);
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                end

            else % 语句不完整(或误用减号)
                controlSystemsimulatingState = 0;
                initBtnForDisplay;
                strPendingEvaluation ='0';
                set(GUI.textDisplay1,'String',...
                    '该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            end
            clear isMatch
            return;
        case 4
            [isMatch, ~] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch
                lowerH = str2double(strsplit(strPendingEvaluation, ','));
                if sum(lowerH,'all') == 0 % 分母为0，无意义
                    controlSystemsimulatingState = 0;
                    initBtnForDisplay;
                    strPendingEvaluation ='0';
                    set(GUI.textDisplay1,'String',...
                        '错误: 反馈通道传递函数分母为0。');
                    lowerH = 1;% 还原默认值
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                else
                    controlSystemsimulatingState = ...
                        controlSystemsimulatingState + 1;
                    strPendingEvaluation = '0';
                    set(GUI.textDisplay1,'String',...
                        '请输入pid参数(kp,ki,kd)(默认1,0,0): ');
                    set(GUI.textDisplay2,'String',strPendingEvaluation);
                end
            else % 语句不完整(或误用减号)
                controlSystemsimulatingState = 0;
                initBtnForDisplay;
                strPendingEvaluation ='0';
                set(GUI.textDisplay1,'String',...
                    '该语句不完整(或误用减号)。');
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            end
            clear isMatch
            return;
        case 5
            [isMatch, numberCount] = isCommaSeparatedNumbers(...
                strPendingEvaluation);
            if isMatch
                parameterPID = str2double(strsplit(...
                    strPendingEvaluation, ','));
                if strcmp(strPendingEvaluation,'0') % 默认不使用控制器
                    controlSystemsimulatingState = ...
                        controlSystemsimulatingState + 1;
                    parameterPID = [1 0 0];
                    initBtnForEnum;
                    strPendingEvaluation = '0';
                    set(GUI.textDisplay1,'String',...
                        {'1.step 2.impulse', '3.bode&margin 4.pzmap'});
                    set(GUI.textDisplay2,'String','5查看系统 6.修改系统',...
                        'FontSize',0.3);
                    % 按下则回到选择界面
                    set(GUI.buttonEqual,'String','选择界面','FontSize',0.3);
                    return;
                elseif numberCount < 3
                    controlSystemsimulatingState = 0;
                    initBtnForDisplay;
                    strPendingEvaluation ='0';
                    set(GUI.textDisplay1,'String',...
                        '错误: 输入参数数目不足。');
                    set(GUI.textDisplay2,'String',strPendingEvaluation);

                else
                    if parameterPID(1) == 0
                        controlSystemsimulatingState = 0;
                        initBtnForDisplay;
                        strPendingEvaluation ='0';
                        set(GUI.textDisplay1,'String',...
                            '错误: P控制器参数为0。');
                        set(GUI.textDisplay2,'String',strPendingEvaluation);

                    else
                        controlSystemsimulatingState = ...
                            controlSystemsimulatingState + 1;
                        initBtnForEnum;
                        strPendingEvaluation = '0';
                        set(GUI.textDisplay1,'String',...
                            {'1.step 2.impulse', '3.bode&margin 4.pzmap'});
                        set(GUI.textDisplay2,'String','5查看系统 6.修改系统');
                        % 按下则回到选择界面
                        set(GUI.buttonEqual,'String','选择界面','FontSize',0.3);
                    end
                end

            else % 该语句不完整(或误用减号)。
                controlSystemsimulatingState = 0;
                initBtnForDisplay;
                strPendingEvaluation ='0';
                set(GUI.textDisplay1,'String',...
                    '错误: 该语句不完整(或误用减号)。。');
                set(GUI.textDisplay2,'String',strPendingEvaluation);
            end
            clear isMatch numberCount
            return;
        case 6
            initBtnForEnum;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String',...
                {'1.step 2.impulse', '3.bode&margin 4.pzmap'});
            set(GUI.textDisplay2,'String','5查看系统 6.修改系统');
            return;
        case 7
            controlSystemsimulatingState = 6;
            initBtnForEnum;
            strPendingEvaluation = '0';
            set(GUI.textDisplay1,'String',...
                {'1.step 2.impulse', '3.bode&margin 4.pzmap'});
            set(GUI.textDisplay2,'String','5查看系统 6.修改系统');
            return;
    end
    % 所有State都为0，则处于报错或纯显示状态，需要重置
    initOrReset;
else
    % 函数运算
    try
        previousCalculationResult = eval(strPendingEvaluation);
        if previousCalculationResult == inf % 零除错误
            set(GUI.textDisplay1,'String','错误: 零除。');
            previousCalculationResult = '0';
        else
            % 将上一次运算结果转为字符并显示
            previousCalculationResult = allNum2Char(previousCalculationResult);
            if displayPrecision ~= 4
                set(GUI.textDisplay1,'String',previousCalculationResult);
            end
        end
    catch
        set(GUI.textDisplay1,'String','错误: 该语句不完整。');% 错误: 该语句不完整。
        previousCalculationResult = '0';
    end

    strPendingEvaluation = '0';
    set(GUI.textDisplay2,'String',strPendingEvaluation);
end
end

% 调用上一次计算的答案
% 多状态过程(极直互换、画图、模式转换、求根、控制工程、求导与积分)复用为'退出'(此功能)
function recallPreviousCalculationResult(~,~)
global GUI strPendingEvaluation previousCalculationResult
strDisplay = get(GUI.buttonAns, 'String');
if strcmp(strDisplay, '退出')
    initOrReset;
    resetAllState;
else
    if strcmp(strPendingEvaluation,'0')
        strPendingEvaluation = previousCalculationResult;
    elseif  ~ismember(strPendingEvaluation(end),['.','i','x',')','0','1','2',...
            '3','4','5','6','7','8','9'])
        strPendingEvaluation = [strPendingEvaluation ...
            '(',previousCalculationResult,')'];
    end
    set(GUI.textDisplay2,'String',strPendingEvaluation);
end
end

% 处理函数运算
function performAdvancedCalculation(~,~,functionName)
global GUI strPendingEvaluation
switch functionName
    case 'Recip'
        strPendingEvaluation = ['1/(',strPendingEvaluation,')'];
    case '^'
        if ~ismember(strPendingEvaluation(end),['.','(','+','-','*','/']) &&...
                ~strcmp(strPendingEvaluation,'0')
            strPendingEvaluation = [strPendingEvaluation functionName '('];
        end
    otherwise
        if strcmp(strPendingEvaluation,'0')
            strPendingEvaluation = [functionName '('];
        elseif  ~ismember(strPendingEvaluation(end),['.','i','x',')','0','1',...
                '2','3','4','5','6','7','8','9'])
            strPendingEvaluation = [strPendingEvaluation functionName '('];
        end
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% '回退'按钮回调函数
function performBackspace(~,~)
global GUI strPendingEvaluation
hadBackspace = false;
% 先检查 strPendingEvaluation 的末尾有没有函数块
functionBlockNames = {'exp(','^(','asin(','acos(','atan(','sin(','cos(',...
    'tan(','log10(','log('};
for i = 1:length(functionBlockNames)
    str = functionBlockNames{i};
    len = length(str);
    if length(strPendingEvaluation) >= len && ...
            strcmp(strPendingEvaluation(end-len+1:end), str)
        strPendingEvaluation = strPendingEvaluation(1:end-len);
        if isempty(strPendingEvaluation)
            strPendingEvaluation = '0';
        end
        hadBackspace = true;
        break;
    end
end
% 再检查其他情况
if hadBackspace == false
    if length(strPendingEvaluation) >= 2
        strPendingEvaluation = strPendingEvaluation(1:end-1);
    else
        if strPendingEvaluation ~= '0'

            strPendingEvaluation = '0';
        end
    end
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% '清空'按钮回调函数
function performEmpty(~,~)
global GUI strPendingEvaluation
strPendingEvaluation = '0';
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% 模式转换
function chooseCalculatorMode(~,~)
global GUI modeChoosingState
modeChoosingState = 1;
initBtnForEnum;
set(GUI.textDisplay1,'String','显示精度');
set(GUI.textDisplay2,'String',{'1.long 2.short','3.科学计数 4.分数(rat)'},...
    'HorizontalAlignment','right');
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
end

% 处理'x'
function processUnknownx(~,~)
global GUI strPendingEvaluation
if strPendingEvaluation == '0'
    strPendingEvaluation = 'x';
else
    if ~ismember(strPendingEvaluation(end),['.','i','x',')','0','1',...
            '2','3','4','5','6','7','8','9'])
        strPendingEvaluation = [strPendingEvaluation 'x'];
    end
end
set(GUI.textDisplay2,'String',strPendingEvaluation);
end

% 处理'逗号'
function processComma(~,~)
global GUI strPendingEvaluation
if length(strPendingEvaluation) >= 1 && strPendingEvaluation(end)~=','
    strPendingEvaluation = [strPendingEvaluation ','];
    set(GUI.textDisplay2,'String',strPendingEvaluation);
end
end

% 开始处理极坐标和直角坐标的互换
function startConvertCoordinates(~,~,kind)
global GUI strPendingEvaluation polState recState
initBtnForData;
strPendingEvaluation = '0';
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
switch kind
    case 'cart2pol'
        polState = 1;
        set(GUI.textDisplay1,'String','请输入直角坐标(x,y): ');
        set(GUI.textDisplay2,'String',strPendingEvaluation);
    case 'pol2cart'
        recState = 1;
        set(GUI.textDisplay1,'String','请输入极坐标(r,theta): ');
        set(GUI.textDisplay2,'String',strPendingEvaluation);
end
end

% 处理求导
function startCalculateDifferentiation(~,~)
global GUI strPendingEvaluation diffState
diffState = 1;
initBtnForExpression;
strPendingEvaluation = '0';
set(GUI.textDisplay1,'String','输入表达式: ');
set(GUI.textDisplay2,'String','');
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
end

% 处理积分
function startCalculateIntegration(~,~)
global GUI intState
intState = 1;
initBtnForEnum;
set(GUI.textDisplay1,'String','选择积分类型(默认为定积分): ');
set(GUI.textDisplay2,'String',{'1.定积分','2.不定积分'},...
    'HorizontalAlignment','right');
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
end

% '画图'按钮回调函数
function startPlotGraph(~,~)
global GUI strPendingEvaluation plottingState
plottingState = 1;
initBtnForEnum;
strPendingEvaluation = '0';
set(GUI.textDisplay1,'String','画图模式选择 ');
set(GUI.textDisplay2,'String',{'1.画函数图(仅f(x))','2.画折线图(默认)'});
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
end

% '求根'按钮回调函数
function startFindRoot(~,~)
global GUI strPendingEvaluation findRootState
findRootState = 1;
initBtnForExpression;
strPendingEvaluation = '0';
set(GUI.textDisplay1,'String','输入表达式: ');
set(GUI.textDisplay2,'String',strPendingEvaluation);
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
end

% '控制工程'按钮回调函数
function simulateControlSystem(~,~)
global GUI strPendingEvaluation controlSystemsimulatingState
controlSystemsimulatingState = 1;
initBtnForData;
strPendingEvaluation = '0';
set(GUI.textDisplay1,'String',{'前向通路传递函数: ',...
    '分子系数(逗号分隔降幂排列): '},'FontSize',0.3);
set(GUI.textDisplay2,'String',strPendingEvaluation);
set(GUI.buttonEqual,'String','下一步','FontSize',0.4);
set(GUI.buttonAns,'String','退出','FontSize',0.5);
end

%% 多状态过程使/失能按钮函数
% 按钮组别('UserData'属性): 'essential','digit','basic1','basic2' ,'function','other'
% 多状态过程等价于按下 function 组内按钮引发的过程
% function 组有: 极直互换、画图、模式转换、求根、控制工程、求导和积分对应的按钮
% 纯显示模式(只能按下一步或退出) essential
% 选择模式(枚举模式) essential digit(部分)
% 输入数据 essential digit basic1 ',' '-'
% 输入表达式 essential digit basic1 basic2
% 'i' 用于求根、求导、积分的表达式;
% 'x' 用于画图、求根、求导、积分的表达式;
% "模式转换"只用了"选择模式"; "极直互换"只用了"输入数据"。

% 选择模式(枚举模式)
% modeChoosingState 1~3 controlSystemsimulatingState 6
% intState 1 plottingState 1

% 输入数据
% controlSystemsimulatingState 1~5 intState 2/ plottingState 3~4/2~3
% polState 1 recState 1
%
% 输入表达式
% plottingState 2/ intState 3/2 diffState 1 3 findRootState 1

% 纯显示模式 (如果是该过程的最后一个State,则值置0)
% intState 4/3 diffState 2 4 findRootState 2 polState 2 recState 2

% 初始化选择模式(枚举模式)
function initBtnForEnum()
global GUI
enableButtonGroups(GUI.fh,{'essential','digit'});
disableButtonGroups(GUI.fh, {'basic1','basic2' ,'function','other'});
end

% 初始化输入数据
function initBtnForData()
global GUI
enableButtonGroups(GUI.fh,{'essential','digit','basic1'});
disableButtonGroups(GUI.fh, {'basic2' ,'function','other'});
set(GUI.buttonComma,'enable','on');
set(GUI.buttonSub,'enable','on'); % 输入负数
end

% 初始化输入表达式
function initBtnForExpression()
global GUI plottingState
enableButtonGroups(GUI.fh,{'essential','digit','basic1','basic2',...
    'other'});
set(GUI.buttonComma,'enable','off');
disableButtonGroups(GUI.fh, {'function'});
if plottingState == 2
    set(GUI.buttoni,'enable','off');
end
end

% 初始化纯显示模式
function initBtnForDisplay()
global GUI
enableButtonGroups(GUI.fh,{'essential'});
disableButtonGroups(GUI.fh, {'digit','basic1','basic2','function',...
    'other'});
end

% 初始化或离开多状态过程使能除'x'和','外按钮
% strPendingEvaluation 和 previousCalculationResult 置 '0'
function initOrReset()
global GUI strPendingEvaluation previousCalculationResult
enableButtonGroups(GUI.fh,{'essential','digit','basic1','basic2',...
    'function','other'});
set(GUI.buttonComma,'enable','off');
set(GUI.buttonx,'enable','off');
strPendingEvaluation = '0';
set(GUI.textDisplay1,'String',previousCalculationResult,'FontSize',0.4);
set(GUI.textDisplay2,'String',strPendingEvaluation,'FontSize',0.4);
set(GUI.buttonEqual,'String','=','FontSize',0.5);
set(GUI.buttonAns,'String','Ans');
end

% 关闭图窗回调函数(画图用)
function closeFigure(src, ~)
initOrReset;
delete(src);
end

%% 工具函数
% 使变量从 complex double 类型转为 char 类型
function str = complexToChar(z)
realPart = real(z);
imagPart = imag(z);

if imagPart < 0
    str = [num2str(realPart), num2str(imagPart), 'i'];
else
    str = [num2str(realPart), '+', num2str(imagPart), 'i'];
end
end

% 失能按钮组
function disableButtonGroups(figHandle, groupsToDisable)
allButtons = findall(figHandle, 'Style', 'pushbutton');
for i = 1:length(allButtons)
    userData = get(allButtons(i), 'UserData');
    if any(strcmp(userData, groupsToDisable))
        set(allButtons(i), 'Enable', 'off');
    end
end
end

% 使能按钮组
function enableButtonGroups(figHandle, groupsToDisable)
allButtons = findall(figHandle, 'Style', 'pushbutton');
for i = 1:length(allButtons)
    userData = get(allButtons(i), 'UserData');
    if any(strcmp(userData, groupsToDisable))
        set(allButtons(i), 'Enable', 'on');
    end
end
end

% 所有定位多状态过程的全局变量重置为 0
function resetAllState()
vars = who;
for i = 1:length(vars)
    % 检查变量名是否以 'State' 结尾
    if endsWith(vars{i}, 'State')
        eval(['global ', vars{i}]);
        eval([vars{i}, ' = 0;']);
    end
end
end

% 格式化输出
function result = allNum2Char(num)
global GUI complexFormat displayPrecision
if ~isreal(num)
    if complexFormat == 2
        result = [abs(num), '∠', angle(num) * (180/pi), '°'];
    else
        result =  complexToChar(num);
    end
else
    switch displayPrecision
        case 1 % long (默认)
            result = num2str(num, '%.15g'); % 保留 15 位有效数字的字符串表示
        case 2 % short
            result = num2str(num, '%.4g'); % 保留 4 位有效数字的字符串表示
        case 3 % short e
            result = num2str(num, '%.4e'); % 保留 4 位小数的科学计数法字符串表示
        case 4 % rat
            [N, D] = rat(num,'1e-4'); % 获取分数的分子和分母
            strDisplay = [num2str(N), '/', num2str(D)]; % 创建分数的字符串表示
            set(GUI.textDisplay1,'String', strDisplay);
            result = num2str(num);
    end
end
end

% 极直坐标互换
function result = convertCoordinates(str)
coordinates = str2num(str);
global recState angularUnit
if recState
    [x, y] = pol2cart(coordinates(1),coordinates(2));
else
    [theta, rho] = cart2pol(coordinates(1),coordinates(2));
    x = theta;
    y = rho;
    if angularUnit == 1 % 角度制
        x = x*180/pi;
    end
end
% 将结果转换为字符数组
if angularUnit == 1
    result = sprintf('%.2f°,%.2f', x, y);
else
    result = sprintf('%.2f,%.2f', x, y);
end
end

% 求根
function [numericRoot, exactRoot] = findRoots(expr)
% 将字符数组转换为函数
syms x;
f = str2func(['@(x)', expr]);
% 尝试求解精确根
try
    exactRoot = solve(expr == 0, x);
catch
    exactRoot = NaN; % 如果无法求解，返回 NaN
end
% 尝试求解数值根
try
    numericRoot = fzero(f, 0); % 以 0 为起始点
catch
    numericRoot = NaN; % 如果无法求解，返回 NaN
end

if isempty(numericRoot)
    numericRoot = NaN; % 如果无法求解，返回 NaN
end
if isempty(exactRoot)
    exactRoot = NaN;  % 如果无法求解，返回 NaN
end
end

% 求不定积分
function integralExpression = calculateIndefiniteIntegral(functionOfX)
try
    syms x;
    f = str2sym(functionOfX);
    result = int(f, x);
    integralExpression = char(result);
catch e
    if contains(e.message,'无效')
        integralExpression = '错误: 表达式不完整。';
    else
        integralExpression = '错误: 无法求解。';
    end
end
end

% 求定积分
function integralValue = calculateDefiniteIntegral(lowerLimit, ...
    upperLimit, functionOfX)
try
    % 将被积函数转换为匿名函数
    f = str2func(['@(x)', functionOfX]);
    result = integral(f, lowerLimit, upperLimit);
    integralValue = char(vpa(result, 6)); % 保留 6 位有效数字
catch e
    if strcmp(e.message, '错误: 该语句不完整。')
        integralValue = '错误: 表达式不完整。';
    else
        integralValue = '错误: 无法求解。';
    end
end
end

% 求导
function derivativedExpression = calculateDerivative(functionOfX)
try
    syms x;
    symbolicFunction = str2sym(functionOfX);
    derivative = diff(symbolicFunction, x);
    derivativedExpression = char(derivative);
catch e
    if contains(e.message,'无效')
        derivativedExpression = '错误: 表达式不完整。';
    else
        derivativedExpression = '错误: 无法求解。';
    end
end
end

% 正则表达式判断字符是否为'num,num,...,num'格式，并返回num的个数
function [isMatch, numberCount] = isCommaSeparatedNumbers(inputStr)
% 正则表达式匹配以逗号分隔的数字(允许空格，支持负数和小数)
pattern = '^(-?\d+(\.\d+)?)(,\s*-?\d+(\.\d+)?)*$';

% 检查输入是否匹配正则表达式
isMatch = ~isempty(regexp(inputStr, pattern, 'once'));

% 如果匹配，计算逗号的数量加1得到数字的个数
if isMatch
    numberCount = sum(inputStr == ',') + 1;
else
    numberCount = 0;
end
end

% 求导后表达式代入数值
function resultStr = evaluateExpressionForNumbers(datas, derivativedExpression)
% 使用之前定义的 isCommaSeparatedNumbers 函数检查 datas
[isMatch, ~] = isCommaSeparatedNumbers(datas);

% 如果 A 符合条件，处理表达式
if isMatch
    % 将 A 分割成数字数组
    numbers = str2double(strsplit(datas, ','));

    % 定义符号变量 x
    syms x;

    % 转换表达式为符号表达式
    symbolicExpression = str2sym(derivativedExpression);

    % 为每个数字计算表达式的值
    expressionValues = arrayfun(@(n) subs(symbolicExpression, x, n), ...
        numbers);

    % 将结果转换为字符串并以逗号分隔
    resultStr = strjoin(arrayfun(@char, expressionValues, ...
        'UniformOutput', false), ',');
else
    % 如果 A 不符合条件，返回错误消息
    resultStr = '错误: 该语句不完整(或误用减号)。';
end
end

% 画折线图
function plotLineGraph(x,y)
plot(x,y,'--gs',...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
xlabel('$x$','Interpreter','latex','FontSize', 20);
ylabel('$y$','Interpreter','latex','FontSize', 20);
xlim([min(x),max(x)]);
ylim([min(y),max(y)]);

% 只显示网格横线
grid on
ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'on';
end

% 画函数图
function errorInfo = plotFunctionGraph(expression, xRange, yRange)
try
    fplot(expression, xRange,'Linewidth',2,...
        'LineStyle','-','Marker','square','LineWidth',2,...
        'MarkerFaceColor','[0 0.4470 0.7410]','Color','[0 0.4470 0.7410]')
    ylim(yRange)

    xlabel('$x$','Interpreter','latex','FontSize', 20);
    ylabel('$f(x)$','Interpreter','latex','FontSize', 20);

    % 只显示网格横线
    grid on
    ax = gca;
    ax.XGrid = 'off';
    ax.YGrid = 'on';
    errorInfo = '';
catch e
    if strcmp(e.message, '错误: 该语句不完整。')
        errorInfo = '错误: 表达式不完整。';
    end
end
end

% 函数定义
function controlSystemAnalysis(strNum)
global GUI upperG lowerG upperH lowerH parameterPID
global controlSystemsimulatingState
% 构建前向和反馈传递函数
G = tf(upperG, lowerG);
H = tf(upperH, lowerH);

% 使用PID参数
Kp = parameterPID(1);
Ki = parameterPID(2);
Kd = parameterPID(3);
C = pid(Kp, Ki, Kd);

% 构建闭环系统
T = feedback(G*C, H);

% 根据strNum执行相应操作
switch strNum
    case '1'
        figure;
        step(T);
        title('阶跃响应');

    case '2'
        figure;
        impulse(T);
        title('冲激响应');

    case '3'
        figure;
        margin(T);
        title('伯德图和裕度');

    case '4'
        figure;
        pzmap(T);
        title('零极点图');

    case '5'
        % 查看当前系统
        simplifiedT = minreal(T); % 简化传递函数
        [num, den] = tfdata(simplifiedT, 'v'); % 提取分子和分母
        numStr = poly2str(num, 's'); % 分子多项式字符串
        denStr = poly2str(den, 's'); % 分母多项式字符串
        set(GUI.textDisplay1,'String','闭环传递函数: ');
        set(GUI.textDisplay2,'String',['(',numStr,' )/(',denStr,')']);

    case '6'
        controlSystemsimulatingState = controlSystemsimulatingState + 1;
        % 回退到之前的步骤
        set(GUI.textDisplay1,'String',{'选择修改项: ','1.PID参数'});
        set(GUI.textDisplay2,'String',{'2.PID参数和反馈通道传递函数',...
            '3.PID参数、反馈通道传递函数和前向通道传递函数'},'FontSize',0.3);
end
end