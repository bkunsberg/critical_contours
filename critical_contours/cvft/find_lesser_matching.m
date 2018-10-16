function Vkn_m = find_lesser_matching(m, Vkn, P)
% Ben Kunsberg
% 1/7/17

% Given the Vkn, output of the final matching in the topological sequence (the output of the
% "fundamental graph problem of CVT") and the cell array of augmenting
% paths P, we consecutively symmetric difference Vkn and the last path of P
% in order to remove the persistent simplifications.

% Note that we push the paths onto P, so we start at P{1}

% Need to convert the P{i} into a set of edges.
Vkn_m = Vkn;
for j = 1:m
    %convert P{1} into edge set.
    p = P{1};
    p_edges = zeros(length(p) - 1, 2);
    for i = 1:length(p)-1
        if p(i) < p(i + 1)
            p_edges(i, :) = [p(i), p(i + 1)];
        else
            p_edges(i, :) = [p(i+1), p(i)];
        end
    end
    
    Vkn_m = setxor(Vkn_m, p_edges,'rows');
    P = P(2:end);
end


end
