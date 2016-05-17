%% Plot data in loop, includes colors and legend ===============================================================
% Input:
%  - plot_type:         'plot' XOR 'errorbar'
%  - base_colormap:     e.g. jet
%  - data:              [X Y] if plot_type = 'plot' XOR [X Y Yerror] if plot_type = 'errorbar'
%  - marker:            e.g. 'o'
%  - index:             index for a loop in which this function is called
%  - stop_index:        end of index for a loop in which this function is called
%  - current_legend:    legend element
%  - legend_location    [] (default) XOR user-defined
function mk_plot_in_color_loop(plot_type, base_colormap, data, line_style, marker, index, stop_index, current_legend, legend_location)
    % Count function call
    persistent calls_count
    global legend_line_objects_vector % to access it from the main file
    if isempty(calls_count)
        calls_count=1;
        legend_line_objects_vector = [];
    else
        calls_count = calls_count + 1;
    end
    % Create colormap vector and colormap
    colormap_vector = 1:floor(length(base_colormap)/stop_index):length(base_colormap);
    CM = base_colormap;
    index_color = CM(colormap_vector(index),:);
    % Plot
    switch plot_type
        case 'plot'
            p = plot(data(:,1), data(:,2), 'LineStyle', line_style, 'Marker', marker, 'Color', index_color); % p is Line Object
        case 'errorbar'
            p = errorbar(data(:,1), data(:,2), data(:,3), 'LineStyle', line_style, 'Marker', marker, 'Color', index_color); % p is Line Object
    end
    % Legend
    if isempty(legend_location) == 1
        legend(legend_line_objects_vector, current_legend)
    elseif isempty(legend_location) ~= 1
        legend(legend_line_objects_vector, current_legend, 'Location', legend_location)        
    end
    legend_line_objects_vector = [legend_line_objects_vector, p]; % vector of Line Objects, for legend            
    legend(legend_line_objects_vector, current_legend, 'Location', legend_location)
    % Clear calls_count if it is a last callout
    if (isempty(calls_count) ~= 1) && (calls_count == stop_index)
        clear calls_count
    end
%% =============================================================================================================