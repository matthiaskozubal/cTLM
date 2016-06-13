%% Imports files and structurizes them into data variable
% Output:
%   - resistances [(R delta R) x n-times]
function [data, cTLM_files, number_of_rings, existing_rings_without_excluded, resistances, excluded_structures_idx] = cTLM_CreateDataStructure(choice)
    %% List files to import    
    local_path = fileparts(mfilename('fullpath')); % current path-name for cTLM script
    cd(local_path);
    cTLM_files = dir(fullfile(local_path, 'datafiles', '*.txt')); % list all *.txt data files in subdirectory 'datafiles'
    format long;
    %% Initialize
    exclude = choice.exclude;
    if (strcmp(choice.exclude_mode, 'stop_excluding_in_IV') == 1)
        exclude(:,2) = {[]};  %http://stackoverflow.com/questions/1903191/how-do-i-assign-an-empty-matrix-to-elements-of-a-cell-array-in-matlab
    elseif (strcmp(choice.exclude_mode, 'first_ring') == 1)
        handy_f = exclude(:,2);
        for i_f = 1:length(exclude)
            handy_f{i_f}(handy_f{i_f} ~= 1) = [];
        end
        exclude = [exclude(:,1), handy_f];
    end
    number_of_rings = length(choice.ring_distances); % number of rings in a given structure
    global mk_pause
    colormap_vector = 1:floor(length(jet)/number_of_rings):length(jet);
    CM = jet;
    close(1); % automatically opened after above line
    %
    data = [];
    data.structure_name = []; % string
    data.rings = []; % struct, field for each ring's measurement
    data.resistances = []; % resistances for a given structure, for each ring, from I-V fit 
    data.cTLM_fit = [];
    existing_rings_without_excluded = {};
%%  Import files and structurise them =============================================================================================================
    for i_files = 1:1:length(cTLM_files)
        %% Current structure name and ring number
        handy = strsplit(cTLM_files(i_files).name,'_');
        current_structure_name = handy{1};
        current_ring_number = str2double(strrep(strrep(handy{2},'o',''),'.txt',''));
        clear handy
        %% Structurize data - checks if structure_name exists
        i_struct = find( cellfun(@(x) isequal(x,current_structure_name),{data.structure_name}) ); % index: where (if present) the current structre name is in data.structure_name
        % First iteration: data, data.structure_name and i - are empty
        if (i_files == 1) 
            data(1).structure_name = current_structure_name;
            i_struct = 1; % for futher indexing        
            data(1).resistances = zeros(number_of_rings,2); % resistances and their errors
            p_full = []; % vector of Plot Line Obejcts, for creating legend
        % Structure_name already is in data; i_struct is not changed
        elseif (i_files > 1) && (isempty(i_struct) ~= 1) 
%             % Check for duplicate ring_numbers        
%             if (current_ring_number <= numel(data(i_struct).rings)) && (isempty(data(i_struct).rings(current_ring_number).ring_name) == 0); % if this ;ring_name' already exists -> current file name is a duplicate
%                 error(['Duplicated file: ' num2str(cTLM_files(i_struct).name)]);
%             end    
        % New structure_name (not yet in data)
        elseif (i_files >= 1) && (isempty(i_struct) == 1) 
            if choice.figures(2) == 1
                close(22)
            end
            handy.structure_name    = current_structure_name;
            handy.rings             = [];
            handy.resistances       = zeros(number_of_rings,2);  
            handy.cTLM_fit          = [];          
            data = [data, handy]; %current structure_name is appended to data 
            clear handy;
            i_struct = numel(data); % for futher indexing     
            p_full = []; % for plot legend 
        end  
        %% Import data from files and put them to 'data' struct
        data(i_struct).rings(current_ring_number).ring_name = ['o' num2str(current_ring_number)];
        data(i_struct).rings(current_ring_number).ring_data = importdata(fullfile('datafiles', cTLM_files(i_files).name));  % struct - data, textdata, colheaders     
        [IV_I, IV_U, quantity_of_I_extrema] = cTLM_Cut_ring_data_after_I_max(data(i_struct).rings(current_ring_number).ring_data.data, current_structure_name, current_ring_number, choice.figures, choice.mk_pause); % Check and remove data for I that rached compliance level % [(A), (V), (/)]              % [IV_I, IV_U] = deal(data(i_struct).rings(current_ring_number).ring_data.data(:,2), data(i_struct).rings(current_ring_number).ring_data.data(:,1));
        data(i_struct).rings(current_ring_number).ring_data_without_extremum = [IV_U IV_I]; % (V), (A)
        data(i_struct).rings(current_ring_number).quantity_of_I_extrema = quantity_of_I_extrema; % (/)        
        %% Fit R to I-V, linear        
        tbl = table(IV_I, IV_U, 'VariableNames', {'Current', 'Voltage'});
        myFit = fitlm(tbl,'Voltage ~ Current-1'); % [5e3] % '-1' <=> (..., 'Intercept', false)
        data(i_struct).rings(current_ring_number).ring_fit = myFit;
        %% Append resistances to data, wihout excluded
        if isempty(exclude) == 1
            rings_to_exclude = [];
        else ~isempty(exclude) == 1
            rings_to_exclude = [exclude{find(strcmp(exclude(:,1), current_structure_name)), 2}]; % rings_to_exclude, empty or something                            
        end
        if (sum(rings_to_exclude == current_ring_number) == 0) % checks if for current structure, current ring is not to be excluded - thus its resistance is to be appended to the data
            data(i_struct).resistances(current_ring_number,1:2) = [data(i_struct).rings(current_ring_number).ring_fit.Coefficients{1,1}, data(i_struct).rings(current_ring_number).ring_fit.Coefficients{1,2}]; % matrix, for easier access to R and deltaR
        end
        %% Plot I-Vs
        if choice.figures(2) == 1
           R = data(i_struct).rings(current_ring_number).ring_fit.Coefficients{1,1}; % temporary variable
           deltaR = data(i_struct).rings(current_ring_number).ring_fit.Coefficients{1,2}; % temporary variable          
           IV_color = CM(colormap_vector(current_ring_number),:);
           if ishandle(21)
               close(21)
           end
           figure(21)
               p21 = plot(IV_I, IV_U, '.', 'color', IV_color);
               hold on
               plot(IV_I, IV_I*[R - deltaR, R, R + deltaR], '-', 'color', IV_color);
               mk_plot([strrep(cTLM_files(i_files).name,'_','\_') '; R = (' num2str(R,'%.2f') '+-' num2str(deltaR, '%.2f') ') (Ohm)'], 'I (A)', 'U (V)', [], [], 0, [1/3 1/2 2/3 1/2], 'tex')
           figure(22)
               hold on
               plot(IV_I, IV_U, '.', 'color', IV_color);
               p = plot(IV_I, IV_I*R, '-', 'color', IV_color); % plot(IV_I, IV_I*[R - deltaR, R, R + deltaR], '-', 'color', IV_color); p is Line Object
               plot(IV_I, IV_I*[R - deltaR, R + deltaR], '-', 'color', IV_color); % plot max and min plots
               p_full = [p_full, p]; % vector of Line Objects, for legend            
               ring_names = {data(i_struct).rings.ring_name};
               legend(p_full, ring_names(find(not(cellfun(@isempty, ring_names))))) % ring names without empty               
               mk_plot(['I-Vs for structure: ' num2str(current_structure_name)], 'I (A)', 'U (V)', [], [], mk_pause, [1/3 0 2/3 1/2], 'tex')
               hold off
           clear i tbl IV_U IV_I myFit R deltaR;
        end
        %
        %% Update existing_rings_without_excluded
            if (i_files < length(cTLM_files)) % there is no next structure for the last file
                next_structure = strsplit(cTLM_files(i_files+1).name,'_');
            elseif (i_files == length(cTLM_files))
                next_structure = {'last_file'};
            end            
            % next structure name is different than current structure name <-> last ring in current structure  ||  last file
            if (strcmp(next_structure{1}, current_structure_name) ~= 1) || (strcmp(next_structure{1}, 'last_file') == 1) 
                % Update existing_rings_without_excluded
                existing_rings_without_excluded = [existing_rings_without_excluded, find(not(data(i_struct).resistances(:,1) == 0))]; % find rings that exist and were not excluded
                % Plot resistances for all rings in current structure
                if choice.figures(3) == 1
                    figure(3) % plot R with errorbars for each ring (wihout excluded) in current structure  
                       errorbar(existing_rings_without_excluded{i_struct}, data(i_struct).resistances(existing_rings_without_excluded{i_struct},1), data(i_struct).resistances(existing_rings_without_excluded{i_struct},2),'-o'); 
                       mk_plot([ 'Resistivity from I-V measurements in ' num2str(current_structure_name) ' structure, rings excluded (not found): ' num2str([find(data(i_struct).resistances(:,1) == 0)]') ], ...
                               'Ring number', ...
                               'R_{ring} (\Omega)', ...
                               existing_rings_without_excluded{i_struct},  ...
                               [], ...
                               (10*mk_pause), ...
                               [0 0 1 1], ...
                               'tex' ...
                              )
                       close(3)   
                end
            end        
    end
    %% Creata resistances data ===========================================================================================================
    % Create resistances_all matrix without excluded structures
    excluded_structures_idx = zeros(numel(data),1); % create index of structures to exclude
    for i_excl = 1:1:numel(choice.exclude_structure)
        excluded_structures_idx = excluded_structures_idx + cellfun(@(x) isequal(x, choice.exclude_structure{i_excl}),{data.structure_name})';
    end        
    resistances = [data(not(excluded_structures_idx)).resistances]; % all ring resistances, without excluded structures, [(R deltaR)- for each ring]
    %
end    