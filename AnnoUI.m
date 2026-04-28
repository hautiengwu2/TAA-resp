close all ; clear


global MARKERSIZE ;
MARKERSIZE = 40 ;%28 ;

global BACKUP ;
BACKUP = [] ;

global CurrentSeg ;
global JUMPSTEP ;
global Hz ;
global signal ;
global ViewLen ;
global annotations ;
global filename ;
global Jidx;

% this is the index of recording you want to label
Jidx = 1 ;


DATABASE = 'YOURDB' ;
ggg = dir([DATABASE '/*.mat']) ;
filename = ggg(Jidx).name(1:end-4) ;




% load raw data
load([DATABASE '/' ggg(Jidx).name]);



genIMUresp ;






%% start to run annotation

annotations = nan(SegNO, 1) ;


% Create a figure and axes
scrsz = get(0,'ScreenSize') ;
fig = uifigure('Name', 'Signal Annotation Interface') ;
fig.Position = [1 scrsz(4) scrsz(3) scrsz(4)/2] ;
ax = uiaxes(fig, 'Position', [50, 150, scrsz(3)-100, scrsz(4)/2-200]);




% which segment are we plotting now.
CurrentSeg = 1 ;

% jump step
JUMPSTEP = 3 ;

plot(ax, t, 5*ones(size(signal)), '.', 'color', [.5 .5 .5], 'LineWidth', 2) ;
hold(ax, 'on');
plot(ax, t, -5*ones(size(signal)), '.', 'color', [.5 .5 .5], 'LineWidth', 2) ;
plot(ax, t, 10*ones(size(signal)), 'color', [.5 .5 .5], 'LineWidth', 2) ;
plot(ax, t, -10*ones(size(signal)), 'color', [.5 .5 .5], 'LineWidth', 2) ;
plot(ax, t, signal, 'b', 'LineWidth', 3) ;
xlabel(ax, 'Time (m)') ; ylabel(ax, 'Amplitude') ; set(ax, 'fontsize', 24)
xlim(ax, [t((CurrentSeg-1)*SegLEN+1) t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))]) ;
tmpidx = (CurrentSeg-1)*SegLEN+1: min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz) ;
mmm = max(-100, min([signal(tmpidx)' -50])) ;
MMM = min(100, max([signal(tmpidx)' 50])) ;
ylim(ax, [mmm MMM])
title(ax, [num2str(CurrentSeg) '/ ' num2str(round(length(t)/Hz/60))])
 

% setup bottoms

btnLeft = uibutton(fig, 'Text', 'Left', 'fontsize', 24, ...
    'Position', [50, 50, 70, 50], ...
    'ButtonPushedFcn', @(~, ~) moveLeft(ax, t, SegLEN));

btnRight = uibutton(fig, 'Text', 'Right', 'fontsize', 24,  ...
    'Position', [150, 50, 70, 50], ...
    'ButtonPushedFcn', @(~, ~) moveRight(ax, t, SegNO, SegLEN));

btnGood = uibutton(fig, 'Text', 'Good', 'fontsize', 24, ...
    'Position', [350, 50, 70, 50], ...
    'ButtonPushedFcn', @(~, ~) addGood(ax, t, SegNO, SegLEN));

btnBad = uibutton(fig, 'Text', 'Mid', 'fontsize', 24, ...
    'Position', [450, 50, 70, 50], ...
    'ButtonPushedFcn', @(~, ~) addUnknown(ax, t, SegNO, SegLEN));

btnBad = uibutton(fig, 'Text', 'Bad', 'fontsize', 24, ...
    'Position', [550, 50, 70, 50], ...
    'ButtonPushedFcn', @(~, ~) addBad(ax, t, SegNO, SegLEN));

btnSave = uibutton(fig, 'Text', 'SAVE', 'fontsize', 24,  ...
    'Position', [1250, 50, 70, 50], ...
    'ButtonPushedFcn', @(~, ~) SAVErslt());




% Callback for clicking on the plot
set(fig, 'WindowButtonDownFcn', @(~, ~) clickCallback(fig, ax, t));



%% different functions for bottoms
 

function SAVErslt()
global signal ; global annotations; global Jidx; global filename ;
fprintf('!!! Save current results!! \n')
save(['Annotations-' filename '-' num2str(Jidx)], 'signal', 'annotations') ;
end


function addGood(ax, t, SegNO, SegLEN)
global annotations; global CurrentSeg ; global Hz ; global signal ;
global ViewLen ; global JUMPSTEP ;

fprintf('--> Add annotation \n')
annotations(CurrentSeg) = 2 ;

if CurrentSeg >= SegNO
    fprintf('Final segment !!\n')
else
    CurrentSeg = CurrentSeg+JUMPSTEP ;
end

xlim(ax, [t((CurrentSeg-1)*SegLEN+1) t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))]) ;
tmpidx = (CurrentSeg-1)*SegLEN+1: min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz) ;
mmm = max(-100, min([signal(tmpidx)' -50])) ;
MMM = min(100, max([signal(tmpidx)' 50])) ;
ylim(ax, [mmm MMM])
title(ax, [num2str(CurrentSeg) '/ ' num2str(round(length(t)/Hz/60))])
 
end


function addBad(ax, t, SegNO, SegLEN)
global annotations; global CurrentSeg ; global Hz ; global signal ;
global ViewLen ; global JUMPSTEP ;

fprintf('--> Add annotation \n')
annotations(CurrentSeg) = 0 ;

if CurrentSeg >= SegNO
    fprintf('Final segment !!\n')
    return;
else
    CurrentSeg = CurrentSeg+JUMPSTEP ;
end

if t(min(length(t), (CurrentSeg-1)*SegLEN+1)) < t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))
    xlim(ax, [t(min(length(t), (CurrentSeg-1)*SegLEN+1)) t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))]) ;
    tmpidx = (CurrentSeg-1)*SegLEN+1: min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz) ;
else
    xlim(ax, [-10 10]) ;
    tmpidx = length(t) ;
end

mmm = max(-100, min([signal(tmpidx)' -50])) ;
MMM = min(100, max([signal(tmpidx)' 50])) ;
ylim(ax, [mmm MMM])
title(ax, [num2str(CurrentSeg) '/ ' num2str(round(length(t)/Hz/60))])
 
end


function addUnknown(ax, t, SegNO, SegLEN)
global annotations; global CurrentSeg ; global Hz ; global signal ;
global ViewLen ; global JUMPSTEP ;

fprintf('--> Add annotation \n')
annotations(CurrentSeg) = 1 ;

if CurrentSeg >= SegNO
    fprintf('Final segment !!\n')
else
    CurrentSeg = CurrentSeg+JUMPSTEP ;
end

if t(min(length(t), (CurrentSeg-1)*SegLEN+1)) < t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))
    xlim(ax, [t(min(length(t), (CurrentSeg-1)*SegLEN+1)) t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))]) ;
    tmpidx = (CurrentSeg-1)*SegLEN+1: min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz) ;
else
    xlim(ax, [-10 10]) ;
    tmpidx = length(t) ;
end
mmm = max(-100, min([signal(tmpidx)' -50])) ;
MMM = min(100, max([signal(tmpidx)' 50])) ;
ylim(ax, [mmm MMM])
title(ax, [num2str(CurrentSeg) '/ ' num2str(round(length(t)/Hz/60))])
 
end



function moveLeft(ax, t, SegLEN)
global CurrentSeg ; global Hz ; global signal ; global ViewLen ;
global JUMPSTEP ;

if CurrentSeg == 1
    fprintf('Left most, cannot move left\n')
else
    CurrentSeg = CurrentSeg-JUMPSTEP ;
    fprintf('Move left\n')
end

if t(min(length(t), (CurrentSeg-1)*SegLEN+1)) < t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))
    xlim(ax, [t(min(length(t), (CurrentSeg-1)*SegLEN+1)) t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))]) ;
    tmpidx = (CurrentSeg-1)*SegLEN+1: min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz) ;
else
    xlim(ax, [-10 10]) ;
    tmpidx = length(t) ;
end
mmm = max(-100, min([signal(tmpidx)' -50])) ;
MMM = min(100, max([signal(tmpidx)' 50])) ;
ylim(ax, [mmm MMM])
title(ax, [num2str(CurrentSeg) '/ ' num2str(round(length(t)/Hz/60))])

end



function moveRight(ax, t, SegNO, SegLEN)
global CurrentSeg ; global Hz ; global signal ; global ViewLen ;
global JUMPSTEP ;

if CurrentSeg >= SegNO
    fprintf('Right most, cannot move right\n')
else
    CurrentSeg = CurrentSeg+JUMPSTEP ;
    fprintf('Move right\n')
end

xlim(ax, [t(min(length(t), (CurrentSeg-1)*SegLEN+1)) t(min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz))]) ;
tmpidx = (CurrentSeg-1)*SegLEN+1: min(length(t), (CurrentSeg-1)*SegLEN+ViewLen*60*Hz) ;
mmm = max(-100, min([signal(tmpidx)' -30])) ;
MMM = min(100, max([signal(tmpidx)' 30])) ;
ylim(ax, [mmm MMM])
title(ax, [num2str(CurrentSeg) '/ ' num2str(round(length(t)/Hz/60))])

end


% Function to handle mouse clicks
function clickCallback(fig, ax, t)

% get the click location
cp = ax.CurrentPoint ; % Get click location
xClick = cp(1, 1); % X-coordinate of click
yClick = cp(1, 2);

% get the click type
clickType = fig.SelectionType; % Options: 'normal', 'alt', 'extend', 'open'

end

