# Program for processing the data from cTLM measurements #
- - -

## cTLM measuerements (circular Transfer Line Method): ##
Metallization structure with several ring-pairs: set inner-ring-radius, varyin outer-ring-radius
* IV measuerement on each ring-pair, fit to data to obtain ring resistance
    * ring resistances vs. ring distances - is fitted with special function to obtain R_SH and L_T (sheet resistivity and transfer length)
    * theory:
        J. G. Champlain, R. Magno, and J. B. Boos, “Low resistance, unannealed ohmic contacts to n-type InAs 0.66 Sb 0.34,” Electronics Letters, vol. 43, no. 23, 2007. (equation 1)
    * exemplary pattern with 6 rings:
    http://www.nature.com/ncomms/2016/160113/ncomms10302/fig_tab/ncomms10302_F2.html
    * for good statistics measurements should be performed on several structures across the sample

### Input: ###
* files from I-V measurements in cTLM method put into the 'datafiles' folder:
* naming of files: name of files with I-Vs measured for each ring for a given cTLM structure, one set for each structure
    * "<structure name>_o<ring name>.txt"
    * e.g. - B1_o1.txt, B1_o2.txt, ..., B1_o9.txt, B2_o1.txt, ...


### Controls: ###
* 'mode'
    * 'fit_IVs_only'
    * 'fit_cTLM'
* 'nonlinear_IV_data'
    * 'no' - linear fit
    * 'yes' - evokes IV_linear_fit_to_nonlinear_data function to find best linear fit
* 'mk_pause'
    * time for displaying graphs
* 'r0'
    * inner circle's radius
* 'ring_distances'
    * set of ring distances for cTLM metallization structure (m)
* 'exclude_mode':
    * 'normal'
    * 'stop_excluding_in_IV' - stops excluding in IV graphs
    * 'first_ring' - exclude only first ring, because often they're shorted due to bad lift-off process
* 'exclude'
    * array of bad ring measurements to be excluded from fitting
    * e.g.: {'B6', [1 8]; 'C3', [4 5 9]; 'F3', [1]}
* 'exclude_structure'
    * which whole structures to exclude from fitting
    * e.g.: {'D3', 'C5'}
* 'p0'
    * initial values for fit: [R_SH (Ohm/sq.), L_T (um)]
    * e.g.: [500, 0.5e-6] 
* 'options'
    * options for cTLM fitting
    * default: []
* 'Display'
    * WTF?
    * default: 'off'
* 'figures'
    * plots to show:
        * [I-V data with and wihout extrema, I-Vs fit, R for each ring in structure, R for each ring and R_mean over structures, cTLM fits]
    * default: [0, 0, 0, 0, 0]


### Output: ###
* R_SH (Ohm/sq.) and L_T (um) parameters ...

- - -

## ToDo: ##
* http://www.mathworks.com/matlabcentral/answers/34234-how-to-obtain-std-of-coefficients-from-curve-fitting
    * myFit = fitnlm(IV_U,IV_I, 'y ~ b0*x1 + b1', [0.005, -3e-06])
    * myFit = fitlm(IV_U,IV_I) % fitlm(x,y)
* save choice to file
* mean_structure(R) - for each number of excluded structures -> for each permutation of excluded structures
* check if deltaR are included in Fit!