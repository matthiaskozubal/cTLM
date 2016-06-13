%% Program for processing the data from cTLM measurements
%
%% CONTROLS =======================================================================================================
tic();
mk_Clear(); 
choice = cTLM_Control( ...
                       { 'mk_pause', 1 }, ...
                       { 'r0', 50e-6 }, ...                                                  % inner circle's radius
                       { 'ring_distances', 1e-6*[2, 5, 10, 15, 20, 25, 30, 35, 40]' }, ...   % (m)                                                                       
                       { 'exclude_mode', 'normal' }, ...                                     % 'normal' XOR 'stop_excluding_in_IV' - stops excluding in IV graphs XOR 'first_ring' - only first
                       { 'exclude', {} }, ... % bad ring measurements, to exclude
                       { 'exclude_structure', {} }, ...                % which whole structures to exclude
                       { 'p0', [1000, 2e-6] }, ...                                           % initial values for fit: [R_SH (Ohm/sq.), L_T (um)]
                       { 'options', [] }, ...                                                % for fitting
                       { 'Display', 'off' }, ...                                             % what for, indeed?
                       { 'figures', [1, 1, 1, 1, 1] } ...                                    % figures: [I-V data with and wihout extrema, I-Vs fit, R for each ring in structure, R for each ring and R_mean over structures, cTLM fits]
                      );
%                  
%% Create Data Structure ===========================================================================================================
[data, cTLM_files, number_of_rings, existing_rings_without_excluded, resistances, excluded_structures_idx] = cTLM_CreateDataStructure(choice);  
%



%% Ring mean
ring_mean = [];
ring_mean_error = [];
for i_ring = 1:1:number_of_rings
    ring_mean = [ring_mean; sum(resistances(i_ring,1:2:end),2) / numel(find(resistances(i_ring,1:2:end))) ]; % divide by quantity of non-zero elements for each ring
    ring_mean_error = [ring_mean_error; sqrt(sum(resistances(i_ring,2:2:end).^2,2)) / numel(find(resistances(i_ring,2:2:end))) ];
end


%% Save resistances data ===========================================================================================================
save_name = 'resistances.txt';
len = length(data(not(excluded_structures_idx)));
handy1([2*linspace(1,len,len)-1, 2*linspace(1,len,len)]) = repmat({data(not(excluded_structures_idx)).structure_name}, 1, 2); % create header
handy2 = repmat({'Ohm'}, 1, 2*len+2);
save_header = ['Distances' char(9) sprintf('%s\t', handy1{:}, 'ring_mean', 'ring_mean') char(13) ...
               'm'        char(9) sprintf('%s\t', handy2{:}) char(13) ...
              ];
save_data = [ring_distances resistances ring_mean ring_mean_error];
dlmwrite(save_name, save_header, '')
dlmwrite(save_name, save_data, '-append', 'delimiter', '\t')
clear handy1 handy2

%% Fit resistances data ===========================================================================================================
% Mean-Fit % first - from all measured structures calculate mean resistance for each ring , second - fit cTLM for one set of mean resistances 

% if figures(4) == 1
%     figure(4)
%     hold on
%     global legend_line_objects_vector
%     for i_structures = 1:1:(size(resistances,2)/2) % control plot
%         legend_full    = {data(not(excluded_structures_idx)).structure_name};
%         legend_current = legend_full(1:1:i_structures);        
%         mk_plot_in_color_loop('errorbar', jet, [existing_rings_without_excluded{i_structures}, resistances(existing_rings_without_excluded{i_structures},2*i_structures-1), resistances(existing_rings_without_excluded{i_structures},2*i_structures)], '--', 'o', i_structures, (size(resistances,2)/2), legend_current, 'SouthEast')
%         mk_plot(['Resistivities vs. ring number for structures without excluded: ' sprintf('%s, ', choice.exclude_structure{1:end-1}) sprintf('%s', choice.exclude_structure{end}) ], 'I (A)', 'U (V)', 1:1:number_of_rings, [], mk_pause, [], 'tex')
%     end
%     p_end = errorbar(1:1:number_of_rings, ring_mean, ring_mean_error,'-ob', 'LineWidth', 2, 'MarkerEdgeColor', 'b', 'MarkerSize', 10);
%     legend([legend_line_objects_vector p_end], [legend_current, 'mean\_structure(R), for each individual ring'], 'Location', 'southeast')
%     hold off
% end
% 
% 
% [mean_fit, mean_fit_statistics] = cTLM_fit(ring_mean, ring_mean_error, choice, 'Mean over structures');
% %



%% Fit for each structure; also Fit-Mean - averages R_SH and L_T parameters from cTLM fits ===========================================================================================================
fits = {};
% output = ;
for i_structure = 1:1:length(resistances)/2   
    [myFit, myFit_statistics] = cTLM_fit(resistances(:,i_structure*2-1), resistances(:,i_structure*2), choice, data(i_structure).structure_name);
    fits = {fits, myFit}; % cell of fit-results
%     output = 
    clear myFit;
end 


% for fit_i = 1:1:numel(fits)
    
% fit_mean = mean(fits);





%% Handy
data_origin   = []; % input to command line
if 1 == 0
    output_origin = [ data_origin(1:2:end,:) data_origin(2:2:end,:)];
end
%
%% Ende
toc();
%%