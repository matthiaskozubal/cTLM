%% Calculate Statistics ==========================================================================================================
% x, y, y_err, fitted_coefficients, fun, precision_correction
% [1] http://www.originlab.com/doc/Origin-Help/NLFit-Algorithm
% [2] J. O. Rawlings, S. G. Pantula, and D. A. Dickey, Applied regression analysis: a research tool, 2. ed.,  2. printing. New York, NY: Springer, 2001.
%
function statistics = mk_statistics(x, y, y_err, fitted_coefficients, fun, precision_correction)
    %% Start
    residuals = y - fun(fitted_coefficients, x);
    weights = 1./y_err.^2; % one of many possible ways to choose weights
    %% Calculate statistics
    N = length(y);
    P = length(fitted_coefficients); % number of parameters
    DOF  = N - P;  
    SSR = sum(weights .* residuals.^2); % SSR - sum of squared residuals (RSS - residual sum of squares)
    chi_sq_reduced = SSR/DOF; % mean residual variance
    SST = sum(y.^2 .* weights); % total sum of squares uncorrected
    adjusted_R_sq = 1 - (SSR/DOF)/(SST/N); % SST - sum of squared totals (TSS - total sum of squares)
    %% Confidence Interval - http://www.mathworks.com/help/curvefit/confint.html
    RMSE = sqrt(SSR/DOF); % root mean squared error (SD - standard deviation); RMSE = sqrt(chi_sq_reduced)  
    % Derivatives due to fit parameters:
    theta_vec = sym('theta', [1, P]); % vector of symbolic parameter names for derivation       
    syms x_sym
    fun_for_derivation = fun(theta_vec, x_sym); % substitute parameter vector for differentation
    F = jacobian(fun_for_derivation, theta_vec); % jacobian due to fit-parameters, weighted later, [n x p] later; jacobian - [2, p. 496], weighting - [1, eq. 7]  
    for j=1:P
        F = subs(F, theta_vec(j), fitted_coefficients(j));
    end
    x_sym = x;
    F = [1./y_err, 1./y_err] .* eval(F); % convert from sym to doubles, weighted, [n x p]
    % Confidence intervals for parameters
    s_theta_vec = diag(sqrt(inv(F' * F) * chi_sq_reduced));    
    CI_param = tinv(0.95, DOF)*s_theta_vec;
    % Matlab function for confidence intervals for parameters
%     ci = coefCI(myFit, 0.95); 
%     CI = sqrt(F * inv(F' * F) * F' * chi_sq_reduced) % confidence interval for estimators of each response (y) (confidence band)
    %% Output
    statistics.N = N;
    statistics.DF = DOF;
    statistics.chi_sq_reduced = chi_sq_reduced;
    statistics.SSR = SSR;
    statistics.adjusted_R_sq  = adjusted_R_sq ;
    statistics.RMSE = RMSE;
    statistics.CI_param = CI_param;
%%=============================================================================================================================
end
