%% Fitting R_SH vs ring-distance with Bessel special functions ==========================================================================================================
% J. G. Champlain, R. Magno, and J. B. Boos, “Low resistance, unannealed ohmic contacts to n-type InAs 0.66 Sb 0.34,” Electronics Letters, vol. 43, no. 23, 2007.
%
function myFit = cTLM_fit(R, deltaR, choice, structure_name)
    %% Data to fit
    present_R_index = find(R);
    R       = R(present_R_index);
    deltaR  = deltaR(present_R_index);
    d       = choice.ring_distances(present_R_index);
    r0      = choice.r0;
    %% Fit 
    tbl = table(d, R, 'VariableNames', {'Distance', 'Resistivity'});    
    fun = @(p,x) (p(1)/(2*pi))*( log((r0+d)/r0) + (p(2)/r0)*(besseli(0,r0/p(2))/besseli(1,r0/p(2))) + (p(2)./(r0+d)).*(besselk(0,(r0+d)/p(2))./besselk(1,(r0+d)/p(2))) ); % p - parameters' vector, [R_SH, L_T]
    try 
        myFit = fitnlm(d, R, fun, choice.p0, 'CoefficientNames', {'R_SH', 'L_T'}, 'ErrorModel', 'combined', 'Exclude', [], 'Options', choice.options);   
    catch
        warning(['Problem with fitting for ' num2str(structure_name) 'structure.'])
        myFit = {};
    end
%     %% append data
%     data(i).cTLM_fit = myFit;
%     data(h).R_SH = data(h).cTLM_fit.Coefficients{1,1};
%     data(h).delta_R_SH = data(h).cTLM_fit.Coefficients{1,2};    
%     data(h).L_T = data(h).cTLM_fit.Coefficients{2,1};
%     data(h).delta_L_T = data(h).cTLM_fit.Coefficients{2,2};        
    %% Plot
    if (choice.figures(5) == 1) && (isempty(myFit) ~= 1)
        figure(5)
            plot(d*1e6, R, 'ob', 'MarkerEdgeColor', 'b', 'MarkerSize', 12, 'LineWidth', 2) % Distances in um
            hold on
            plot(d*1e6, fun(myFit.Coefficients{1:2,1},d), '-r', 'LineWidth', 2); % Distances in um
            hold off
            legend({'Data', ...
                    ['Fit: '  'R_{SH} = (' num2str(myFit.Coefficients{1,1}/1e3,'%.2f') '\pm' num2str(myFit.Coefficients{1,2}/1e3, '%.2f') ') (k\Omega/sq.); '   ... % sprintf('\n') for newline character
                     'L_{T}   = (' num2str(myFit.Coefficients{2,1}*1e+6,'%.2f') '\pm' num2str(myFit.Coefficients{2,2}*1e+6, '%.2f') ') (\mum)'], ...
                   }, ...
                   'Location', 'SouthEast'  ...
                   );
            mk_plot(['cTLM fit for structure: ' num2str(structure_name)], 'Distance ($\mu$m)', '$\textnormal{R}_{\textnormal{SH}}$ ($\Omega$/sq.)', choice.ring_distances(present_R_index)*1e6, [], choice.mk_pause, [], 'latex') % Distances in um            
    end
end
%%=============================================================================================================================