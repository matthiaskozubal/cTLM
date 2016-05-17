Program for processing the data from cTLM measurements

 cTLM measuerements (circular Transfer Line Method):
   - metallization structure with several ring-pairs: set inner-ring-radius, varyin outer-ring-radius
   - IV measuerement on each ring-pair, fit to data to obtain ring resistance
   - ring resistances vs. ring distances - is fitted with special function to obtain R_SH and L_T (sheet resistivity and transfer length)
   - theory:
       J. G. Champlain, R. Magno, and J. B. Boos, “Low resistance, unannealed ohmic contacts to n-type InAs 0.66 Sb 0.34,” Electronics Letters, vol. 43, no. 23, 2007. (equation 1)
   - exemplary pattern with 6 rings:
       http://www.nature.com/ncomms/2016/160113/ncomms10302/fig_tab/ncomms10302_F2.html
   - for good statistics measurements should be performed on several structures across the sample

 Input:  files from I-V measurements in cTLM method put into the 'datafiles' folder:
           - naming of files: name of files with I-Vs measured for each ring for a given cTLM structure, one set for each structure
                              "<structure name>_o<ring name>.txt"
                              e.g. - B1_o1.txt, B1_o2.txt, ..., B1_o9.txt, B2_o1.txt, ...
 Output: R_SH (Ohm/sq.) and L_T (um) parameters ...

 ToDo:
   - http://www.mathworks.com/matlabcentral/answers/34234-how-to-obtain-std-of-coefficients-from-curve-fitting
     myFit = fitnlm(IV_U,IV_I, 'y ~ b0*x1 + b1', [0.005, -3e-06])
     myFit = fitlm(IV_U,IV_I) % fitlm(x,y)
   - save choice to file
   - mean_structure(R) - for each number of excluded structures -> for each permutation of excluded structures
   - check if deltaR are included in Fit!