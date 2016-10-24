%% Beautifies the plot 
% Input:
%   title_mk
%   xlabel_mk
%   ylabel_mk
%   XTick_mk - [] ('auto') XOR vector
%   YTick_mk - [] ('auto') XOR vector
%   pause_mk
%   windows_placement - calls mk_windows_placement(vector);
%   Interpreter - [] ('none') XOR 'tex' XOR 'latex'
%  Sources
%    http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/
function mk_plot(title_mk, xlabel_mk, ylabel_mk, XTick_mk, YTick_mk, pause_mk, windows_placement, Interpreter)
%% Control
grid on;
font_name = 'Cambria';
font_size_title = 16;
font_size_labels = 14;
font_size_ticks = 12;
%% Interpreter for labels and legend
if (isempty(Interpreter) == 1)
    Interpreter = 'none';
end
%% Basics
title(title_mk, 'FontName', font_name, 'FontSize', font_size_title, 'FontWeight', 'normal', 'Interpreter', Interpreter)	
xlabel(xlabel_mk, 'FontName', font_name, 'FontSize', font_size_labels, 'Interpreter', Interpreter)
ylabel(ylabel_mk, 'FontName', font_name, 'FontSize', font_size_labels, 'Interpreter', Interpreter)
%% Ticks
if (isempty(XTick_mk) == 1) % empty means auto
    set(gca, 'XTickMode', 'auto', 'TickDir', 'out', 'FontName', font_name, 'FontSize', font_size_ticks); % Also from 2014b possible is: "ax.XTick = some_vector;"
elseif (isempty(XTick_mk) ~= 1) % not empty means that XTick is a vector
    set(gca, 'XTick', XTick_mk, 'TickDir', 'out', 'FontName', font_name, 'FontSize', font_size_ticks); % Also from 2014b possible is: "ax.XTick = some_vector;"
end
if (isempty(YTick_mk) == 1) % empty means auto
    set(gca, 'YTickMode', 'auto', 'TickDir', 'out', 'FontName', font_name, 'FontSize', font_size_ticks); % Also from 2014b possible is: "ax.XTick = some_vector;"
elseif (isempty(YTick_mk) ~= 1) % not empty means that XTick is a vector, empty would mean auto
    set(gca, 'YTick', YTick_mk, 'TickDir', 'out', 'FontName', font_name, 'FontSize', font_size_ticks); % Also from 2014b possible is: "ax.XTick = some_vector;"
end
%% Windows placement
mk_windows_placement(windows_placement); 
%% Pause - must be last
pause(pause_mk)
%%