%% Convert data form table "Parameters" from FitNL sheet in Origin
% data = [] (copy from Origin)
function cTLM_convert_Origin_output(data, sample_name)
    k = size(data,1);
    R_SH  = data(1:4:k,:);
    L_T   = data(2:4:k,:);
    rho_c = data(3:4:k,:);
    R_c   = data(4:4:k,:);
    save_data = [flipud(rot90(1:1:k/4)) R_SH L_T rho_c R_c];
    %% Save
    save_name = ['output_' sample_name '.txt'];
    handy1 = {'R_SH' char(9) 'R_SH_err' char(9) 'L_T' char(9) 'L_T_err' char(9) 'rho_c' char(9) 'rho_c_err' char(9) 'R_c' char(9) 'R_c_err'};
    handy2 = {'Ohm/sq.' char(9) 'Ohm/sq.' char(9) 'm' char(9) 'm' char(9) 'Ohm*cm^2' char(9) 'Ohm*cm^2' char(9) 'Ohm*mm' char(9) 'Ohm*mm'}; 
    save_header = char(['Structure' char(9) handy1{:}],  ... % handy{1} instead of sprintf... <- problem in importing in Origin if \t is left at the end of line of resistances.txt
                       [''          char(9) handy2{:}],  ...
                       [''          repmat([sprintf('\t') sample_name], 1, 8)]   ...
                      );                              
    dlmwrite(save_name, save_header, '')
    dlmwrite(save_name, save_data, '-append', 'delimiter', '\t')
    clear handy1 handy2
end