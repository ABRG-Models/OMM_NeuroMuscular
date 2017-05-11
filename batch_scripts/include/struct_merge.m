%%
%% Merge structures
%%
function s=struct_merge(varargin)
    for i=1:nargin
        a=varargin{i};
        for [v,n]=a
            s.(n)=v;
        end
    end
end
