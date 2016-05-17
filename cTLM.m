%% Program for processing the data from cTLM measurements
%
%% CONTROLS =======================================================================================================
tic();
mk_Clear(); 
choice = cTLM_Control( ...
                       { 'mk_pause', 3 }, ...
                       { 'r0', 50e-6 }, ...                                                 % inner circle's radius
                       { 'ring_distances', 1e-6*[2, 5, 10, 15, 20, 25, 30, 35, 40]' }, ...  % (m)                                                                       
                       { 'exclude_mode', 'normal' }, ...                                    % 'normal' XOR 'stop_excluding_in_IV' - stops excluding in IV graphs XOR 'first_ring' - only first
                       { 'exclude', {'B1', [1 9]; 'B2', [1 3 5 7 8 9]; 'B3', [1 5 8 9]; 'B4', 1; 'B5', 3; 'C1', [1 4 7 8 9]; 'C2', [1 3 6 7 8]} }, ... % bada ring measurements, to exclude
                       { 'exclude_structure', {'C1', 'C2', 'D3', 'E4'} }, ...               % which whole structures to exclude
                       { 'p0', [4000, 2e-6]}, ...                                           % initial values for fit: [R_SH (Ohm/sq.), L_T (um)]
                       { 'options', []}, ...                                                % for fitting
                       { 'Display', 'off'}, ...                                             % what for, indeed?
                       { 'figures', [0, 0, 0, 0, 1, 1]} ...                                 % figures: [I-V data with and wihout extrema, I-Vs fit, R for each ring in structure, R for each ring and R_mean over structures, mean_fit, fit_mean]
                      );
%                  
%% Create Data ===========================================================================================================
[data, cTLM_files, number_of_rings, existing_rings_without_excluded] = cTLM_CreateDataStructure(choice);  
%
%% Fit Data ===========================================================================================================
% Create resistances_all matrix without excluded structures
excluded_structures_idx = zeros(numel(data),1); % create index of structures to exclude
for i_excl = 1:1:numel(choice.exclude_structure)
    excluded_structures_idx = excluded_structures_idx + cellfun(@(x) isequal(x, choice.exclude_structure{i_excl}),{data.structure_name})';
end        
resistances = [data(not(excluded_structures_idx)).resistances]; % all ring resistances, without excluded structures, [(R deltaR)- for each ring]
%
% Mean-Fit % first - from all measured structures calculate mean resistance for each ring , second - fit cTLM for one set of mean resistances 
ring_mean = [];
ring_mean_error = [];
for i_ring = 1:1:number_of_rings
    ring_mean = [ring_mean; sum(resistances(i_ring,1:2:end),2) / numel(find(resistances(i_ring,1:2:end))) ]; % divide by quantity of non-zero elements for each ring
    ring_mean_error = [ring_mean_error; sqrt(sum(resistances(i_ring,2:2:end).^2,2)) / numel(find(resistances(i_ring,2:2:end))) ];
end
if figures(4) == 1
    figure(4)
    hold on
    global legend_line_objects_vector
    for i_structures = 1:1:(size(resistances,2)/2) % control plot
        legend_full    = {data(not(excluded_structures_idx)).structure_name};
        legend_current = legend_full(1:1:i_structures);        
        mk_plot_in_color_loop('errorbar', jet, [existing_rings_without_excluded{i_structures}, resistances(existing_rings_without_excluded{i_structures},2*i_structures-1), resistances(existing_rings_without_excluded{i_structures},2*i_structures)], '--', 'o', i_structures, (size(resistances,2)/2), legend_current, 'SouthEast')
        mk_plot(['Resistivities vs. ring number for structures without excluded: ' sprintf('%s, ', choice.exclude_structure{1:end-1}) sprintf('%s', choice.exclude_structure{end}) ], 'I (A)', 'U (V)', 1:1:number_of_rings, [], mk_pause, [], 'tex')
    end
    p_end = errorbar(1:1:number_of_rings, ring_mean, ring_mean_error,'-ob', 'LineWidth', 2, 'MarkerEdgeColor', 'b', 'MarkerSize', 10);
    legend([legend_line_objects_vector p_end], [legend_current, 'mean\_structure(R), for each individual ring'], 'Location', 'southeast')
    hold off
end
mean_fit = cTLM_fit(ring_mean, ring_mean_error, choice, 'Mean over structures');
% %



% % Fit-Mean % first - for each structure fit cTLM for set of resistances, second - average parameters from cTLM fits 
fits = {};
for i_structure = 1:1:length(resistances)/2   
    myFit = cTLM_fit(resistances(:,i_structure*2-1), resistances(:,i_structure*2), choice, data(i_structure).structure_name);
    fits = {fits, myFit}; % cell of fit-results
    clear myFit;
end 


% for fit_i = 1:1:numel(fits)
    
% fit_mean = mean(fits);





%
%% Ende
toc();
%%