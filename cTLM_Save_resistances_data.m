%% Saves data into resistance.txt, ready to be imported into Origin, zeros converted to NaNs
function cTLM_Save_resistances_data(len, structures, resistances, ring_distances, ring_mean, ring_mean_error)
    save_name = 'resistances.txt';
    handy1 = repmat(  {char(9) 'R' char(9) 'R_err'}, 1, len+1); % create header
    handy2 = repmat({char(9) 'Ohm'}, 1, 2*len+2); % create header
    handy3([2*linspace(1,len,len)-1, 2*linspace(1,len,len)]) = repmat(structures, 1, 2); % create header
    % save_header = ['Distances' char(9) sprintf('%s\t', handy1{:}) sprintf('\n') ...
    %                'm'         char(9) sprintf('%s\t', handy2{:}) char(13) ...
    %                '-'         char(9) sprintf('%s\t', handy3{:}, 'ring_mean', 'ring_mean') char(13) ...
    %               ];
    save_header = char(['Distances' handy1{:}],  ... % handy{1} instead of sprintf... <- problem in importing in Origin if \t is left at the end of line of resistances.txt
                       ['m'         handy2{:}],  ...
                       ['-'         char(9) sprintf('%s\t', handy3{:}) 'ring_mean' char(9) 'ring_mean']   ...
                      );       

    resistances(resistances == 0) = NaN; % check if it will not cause problems later
    save_data = [ring_distances resistances ring_mean ring_mean_error];
    dlmwrite(save_name, save_header, '')
    dlmwrite(save_name, save_data, '-append', 'delimiter', '\t')
    clear handy1 handy2 handy3
end