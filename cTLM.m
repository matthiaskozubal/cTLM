%% Program for processing the data from cTLM measurements
%
%% CONTROLS =======================================================================================================
tic();
mk_Clear(); 
choice = cTLM_Control( ...
                       { 'mode', 'fit_IVs_only'}, ...                                        
                       { 'nonlinear_IV_data', 'yes', 'IV_graphs_mode', 'graphs_none', 'IV_min_points', 8, 'IV_max_points', 40}, ...                         
                       { 'mk_pause', .1 }, ...
                       { 'r0', 50e-6 }, ...                                                  
                       { 'ring_distances', 1e-6*[2, 5, 10, 15, 20, 25, 30, 35, 40]' }, ...                                                                         
                       { 'exclude_mode', 'normal' }, ...                                    
                       { 'exclude', {} }, ...     
                       { 'exclude_structure', {} }, ...              
                       { 'p0', [500, 0.5e-6] }, ...                            
                       { 'options', [] }, ...                                  
                       { 'Display', 'off' }, ...                               
                       { 'figures', [0, 0, 1, 1, 1] } ...                                    
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
cTLM_Save_resistances_data(length(data(not(excluded_structures_idx))), {data(not(excluded_structures_idx)).structure_name}, resistances, ring_distances, ring_mean, ring_mean_error);




disp('end of partial script')
break
pause(5)
close all











%% Fit resistances data ===========================================================================================================
% if strcmp(choice.mode, 'fit_IVs_only') == 1

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
output.data = [];
output.structures = [];
for i_structure = 1:1:size(resistances,2)/2   
    [myFit, myFit_statistics] = cTLM_fit(resistances(:,i_structure*2-1), resistances(:,i_structure*2), choice, data(i_structure).structure_name);
    if isempty(myFit) ~= 1
        output.data = [output.data; myFit.Coefficients{1,1:2} myFit.Coefficients{2,1:2}]; % append [R_SH delta_R_SH L_T delta_L_T] to output
        output.structures = [output.structures; data(i_structure).structure_name]; 
    end
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