function [I, U, quantity_of_I_extrema] = cTLM_cut_ring_data_after_I_max(ring_data, current_structure_name, current_ring_number, figures, mk_pause)
%% Data
I = ring_data(:,2);
U = ring_data(:,1);
%% Check how many extrema I possess
%  If more than e.g. 4 (two on each side) - then use Irounded instead of I
%  Problem was if I_neg_min = -0.099999 and values were -0.099998 and -0.099999
quantity_of_I_extrema = numel(I(I == max(I))) + numel(I(I == min(I)));
if quantity_of_I_extrema > 4
    I = round(I, 1, 'significant'); % round I to 1 significant digit, only for extrema finding
    quantity_of_I_extrema = numel(I(I == max(I))) + numel(I(I == min(I))) % recalculate number of extrema
end
% Non-negative and negative part 
I_neg = I(I <  0);
I_neg_min_vec = find(~(I_neg - min(I_neg))); % finds where I_neg reaches I_neg_max
I_pos = I(I >= 0);
I_pos_max_vec = length(I_neg) + find(~(I_pos - max(I_pos))); % finds where I_pos reaches I_pos_max, indexing as in original I
I_extremum_vector = [I_neg_min_vec(1:end-1); I_pos_max_vec(2:end)]; % wihout leftmost single values before the minimum and and rightmost single value before maximum
% Data cut
I(I_extremum_vector) = []; 
U(I_extremum_vector) = [];
%% Figures for tests
if figures(1) == 1
    figure(11)
        plot(ring_data(:,1), ring_data(:,2), '-ob') % original I
        mk_plot(['Original I-V data for ' current_structure_name '\_o' num2str(current_ring_number)],        'U (V)', 'I (A)', [], [], 0, [0 1/2 1/3 1/2], 'tex')
    figure(12)
        plot(U, I, '-ob') % new I
        xlim([min(ring_data(:,1)) max(ring_data(:,1))]) % stretch axis to match the original U
        mk_plot(['I-V data without extrema for ' current_structure_name '\_o' num2str(current_ring_number)], 'U (V)', 'I (A)', [], [], 0, [0 0 1/3 1/2], 'tex')        
end
%%