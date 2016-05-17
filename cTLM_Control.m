%% Takes controls set by user
% Creates choice struct with substructs according to choices made in main 
% Additionally, if variable is float - it is created and set to global in base
%%
function choice = cTLM_Control(varargin)
    choice = {};                                                           % Construct 'choice' struct
    for k=1:1:nargin
        if size(varargin{k},2) == 1                                        % parameter name with missing value 
            error(['Missing value for parameter ' varargin{k}{1} '.'])
            break;
        elseif size(varargin{k},2) == 2                                    % parameter and value pair               
            if (isfloat(varargin{k}{2}) == 1) || (iscell(varargin{k}{2}) == 1) || (ischar(varargin{k}{2}) == 1) % paramter's value is char, number or cell   
                choice = setfield(choice, varargin{k}{1}, varargin{k}{2}); % set field with variable's name and value as field's name and value
                handy1 = genvarname(varargin{k}{1});                       % http://stackoverflow.com/questions/2809635/how-to-concatenate-a-number-to-a-variable-name-in-matlab
                eval(['global ' handy1])                                   % parameter's value set for global (global must be also declared in main file)                
                eval([handy1 ' = varargin{k}{2};']); 
                evalin('base', ['global ' handy1])                         % Instead of making those variables global in main file                
            end 
        elseif size(varargin{k},2) > 2                                     % many parameter-value pairs    
            if mod(size(varargin{k},2),2) == 0                             % each parameter has value
                handy2 = {};
                handy2 = setfield(handy2, 'mode', varargin{k}{2});         % first field of handy2 is 'mode' 
                for n = 2:(size(varargin{k},2)/2)                          % generate handy2 to be appended later to choice
                    handy2 = setfield(handy2, varargin{k}{2*n-1}, varargin{k}{2*n}); % pick each and assign to struct handy
                    if n > 1                                               % ommit the description paramter
                        handy3 = genvarname(varargin{k}{2*n-1});           % create global variables
                        eval(['global ' handy3])                           % parameter's value set for global (global must be also declared in main file)                                
                        eval([handy3 ' = varargin{k}{2*n};']);   
                        evalin('base', ['global ' handy3])      
                        evalin('base', ['global ' handy3])                 % Instead of making those variables global in main file                                                
                    end
                end  
                choice = setfield(choice, varargin{k}{1}, handy2);         % append handy as value to the field varargin{k}{1} 
            else
                error(['One of many values for parameter ' varargin{k} ' is missing.'])            % something is missing
                break;
            end            
        end
    end
%     mk_save_struct_to_file(choice, 'csv')
%% Trash
%             if ischar(varargin{k}{2}) == 1                                 % paramter's value is char
%                 handy0 = {};                                               % choice will have varargin{k}{1} field with subfield 'mode' with varargin{k}{2} value
%                 handy0 = setfield(handy0, 'mode', varargin{k}{2});         % set field with 'mode' as field's name
%                 choice = setfield(choice, varargin{k}{1}, handy0);         % set field with variable's name and value as field's name and value
end    