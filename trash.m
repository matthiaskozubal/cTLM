%% Exclude as ugly cell
exclude = {{'B1', 1}, {'B2', [1 2 5]}, {'B3', 1}, {'B4', 1}, {'C1', 1}, {'C2', 1}};
for i_excl = 1:1:length(exclude)
    if strcmp(exclude{i_excl}{1}, data(i).structure_name) == 1 % % checks if current structure's name is in the exclude struct
        exclude_current = exclude{i_excl}{2}; % numbers of rings to exclude for given structure-name
    end
end
%% Exclude as pretty cell
exclude = {'B1', 1; 'B2', [1 2 5]; 'B3', 1; 'B4', 1; 'C1', 1; 'C2', 1};
tic; find(not(cellfun('isempty', strfind(exclude(:,1), 'B3')))); toc();
tic; find(ismember(exclude(:,1), 'B3')); toc;
tic; find(strcmp(exclude(:,1), 'B3')); toc; % best
%% Finding indices of rings to exclude
% problem was when there was a data file missing for import
if choice.figures(3) == 1
    if (i_files < length(cTLM_files)) % don't do this for the last file
        next_structure = strsplit(cTLM_files(i_files+1).name,'_');
    elseif (i_files == length(cTLM_files))
        next_structure = {'last_file'};
    end

    if (strcmp(next_structure{1}, current_structure_name) ~= 1) || (strcmp(next_structure{1}, 'last_file') == 1) % next structure name is different than current structure name <-> last ring in current structure  ||  last file
        if (isempty(find(strcmp(exclude(:,1), current_structure_name))) ~= 1) % there is something to exclude     
            rings_to_exclude = exclude{find(strcmp(exclude(:,1), current_structure_name)), 2}; % rings_to_exclude                            
        elseif (isempty(find(strcmp(exclude(:,1), current_structure_name))) == 1) % there is nothing to exclude     
            rings_to_exclude = [];
        end
        existing_rings_without_excluded = find(data(i_struct).resistances(:,1)); % numbers of rings; below, from it rings_to_be_excluded will be removed 
        existing_rings_without_excluded(rings_to_exclude) = [];% 
        figure(3) % plot R with errorbars for each ring (wihout excluded) in current structure  
           errorbar(existing_rings_without_excluded, data(i_struct).resistances(existing_rings_without_excluded,1), data(i_struct).resistances(existing_rings_without_excluded,2),'-o'); 
           mk_plot(['Resistivity from I-V measurements in ' num2str(current_structure_name) ' structure, excluded: ' num2str(rings_to_exclude)], ...
                   'Ring number', ...
                   'R_{ring} (\Omega)', ...
                   existing_rings_without_excluded,  ...
                   [], ...
                   (2*mk_pause), ...
                   [0 0 1 1], ...
                   'tex' ...
                  )
           close(3)   
    end
end 
%% Use excluded_structures_idx for creating resistances_all matrix without excluded structures
excluded_structures_idx = zeros(numel(data),1); % create index of structures to exclude
for i_excl = 1:1:numel(choice.exclude_structure)
    excluded_structures_idx = excluded_structures_idx + cellfun(@(x) isequal(x,choice.exclude_structure{i_excl}),{data.structure_name})'; % find i-th exclude_structure element in data.structure_name
end        
resistances = [data(not(excluded_structures_idx)).resistances]; % all ring resistances, without excluded structures, [(R deltaR)- for each ring]
%%






