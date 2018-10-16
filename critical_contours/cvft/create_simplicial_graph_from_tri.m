function [G, lookup] = create_simplicial_graph_from_tri(V, E, DT, orient_field)
%Using nomenclature as in Fast CVFT by Reininghaus, 2010

%Input: vertices and edges describing triangulation and a vector field on
%those vertices (from image)

% Total outputs:
%1.  G, with an edgeTable and three fields for Node attributes: locs, U, W
%2.  A lookup table, called lookup, that will be a vector such that
%[lookup(i)+1, lookup(i + 1)] contains the indices in G.Edges.EndNodes
%that are the edges of the graph containing node i.


%Written on 10/7/16 by Ben Kunsberg


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Past Changes:

%Version 5 is a speedup of about 3x of version 4, by only using the find
%command in a third of the matrix (in the 1-cells section) when trying to
%find the 1cell boundaries of a 2cell.

%Version 4 does not calculate the adjacency matrix L, but just outputs
%with the sparse representation edgeData, also outputs graph G, with Node
%Attributes.

%Version 3 outputs S as a structure so that it is modified to work with
%fast CVFT.

%Version 2 differs from Version 1 by working with an orient field that is
%two components rather than an angle.

%%
% The vertices in V are named as 1:n and the edges and triangles reference
% those rows.  Only use V to get positions.
cells0 = V;
cells1 = E; %based on the rows of V
cells2 = DT.ConnectivityList;  %based on the rows of V

%Create S, vertices in simplicial graph
num_rows = length(cells0) + length(cells1) + length(cells2);
S = zeros(num_rows, 3);
S(1:length(cells0), 1) = 1:length(cells0); %store all the vertices (0-cells) and pad with 0s
S(length(cells0) + 1:length(cells0) + length(cells1), 1:2) = cells1; %store all the vertices (1-cells) and pad with 0s
S(length(cells0) + length(cells1) + 1:end, 1:3) = cells2;

%Create L, links of simplicial graph.  It will be represented as an adjacency matrix indexed according to the
%vertex described by that row of S.
%Step 1: every 0cell is linked to several 1cells; list these links first
%do this by looping through all 1-cells and adding the appropriate
sz = size(orient_field{1});
edgeData = zeros(sz(1)*sz(2)*10, 3);
counter = 1;
%

% flip V's columns, because DT expects (X, Y)

tmp = V;
tmp(:, 2) = V(:, 1);
tmp(:, 1) = V(:, 2);
V = tmp;


for i = 1:length(cells1)
    %
    %for each 1cell (edge in triangulation), we will input two links in L
    %with weights dependent on the orientation Field.
    link_posn = V(cells1(i, 2), :) - V(cells1(i, 1), :);
    
    average_orient_1 = (orient_field{1}(V(cells1(i, 1), 1), V(cells1(i, 1), 2), 1) ...
        + orient_field{1}(V(cells1(i, 2), 1), V(cells1(i, 2), 2), 1))/2;
    average_orient_2 = (orient_field{2}(V(cells1(i, 1), 1), V(cells1(i, 1), 2), 1) ...
        + orient_field{2}(V(cells1(i, 2), 1), V(cells1(i, 2), 2), 1))/2;
    
    average_grad = [average_orient_2, average_orient_1]; %taking into account the axes x (left to right) and y (up to down) that link_posn is in. link_posn(1) is rows, link_posn(2) is cols
    weight = average_grad(1)*link_posn(1) +  average_grad(2)*link_posn(2); %this weight is the proportion of the gradient in the dir defined by moving from vertex A to the link A -- B
    
  
    %since S's first portion is just the 0cells, I can directly map into
    %the adjacency matrix for the component
    
    tmp = i;
    index_1cell = length(cells0) + tmp;
    
    edgeData(counter, :) = [cells1(i, 1), index_1cell, weight];
    counter = counter +1;
    edgeData(counter, :) = [cells1(i, 2), index_1cell, -weight];
    counter = counter +1;
end


%Step 2: every 2cell is linked to several 1cells; loop through the 2cells

%Speedup: Store a third of S (just the 1-cells), so that we can search it
%faster.

just_S_1_cells = S(length(cells0):(length(cells0) + length(cells1)), :);


for i = 1:length(cells2)
    %Each 2 cell is linked with 3 1cells
    %First find the indexes into S of all these guys
    curr_tri = cells2(i, :);
    index_tri = i + length(cells0) + length(cells1); %2cell index into S
    curr_tri_o = sort(curr_tri);
    
    
    tmp = just_S_1_cells == [curr_tri_o(1), curr_tri_o(2), 0];
    first_1cell = find(sum(tmp, 2) == 3);
    first_1cell = first_1cell + length(cells0)-1;
    tmp = just_S_1_cells == [curr_tri_o(2), curr_tri_o(3), 0];
    sec_1cell = find(sum(tmp, 2) == 3);
    sec_1cell = sec_1cell + length(cells0)-1;
    tmp = just_S_1_cells == [curr_tri_o(1), curr_tri_o(3), 0];
    third_1cell = find(sum(tmp, 2) == 3);
    third_1cell = third_1cell + length(cells0)-1;
    %now need to do weight.  Take midpoint of triangle and calculate it's
    %distance to midpoint of each edge and dot that with orientation.
    
    
    v1_posn = V(curr_tri(1), :);
    v2_posn = V(curr_tri(2), :);
    v3_posn = V(curr_tri(3), :);
    tri_center = (v1_posn + v2_posn + v3_posn)/3;
    
    tmp1 = S(first_1cell, :);
    midpoint1 = (V(tmp1(1), :) + V(tmp1(2), :))/2;
    tmp2 = S(sec_1cell, :);
    midpoint2 = (V(tmp2(1), :) + V(tmp2(2), :))/2;
    tmp3 = S(third_1cell, :);
    midpoint3 = (V(tmp3(1), :) + V(tmp3(2), :))/2;
    
    % these link positions are 2x1 vectors with first component is row
    % difference, second component is col difference
    link1_posn = tri_center - midpoint1;
    link2_posn = tri_center - midpoint2;
    link3_posn = tri_center - midpoint3;
    
    tri_center_orient_1 = (orient_field{1}(v1_posn(1), v1_posn(2), 1) ...
        + orient_field{1}(v2_posn(1), v2_posn(2), 1) ...
        + orient_field{1}(v3_posn(1), v3_posn(2), 1))/3;
    tri_center_orient_2 = (orient_field{2}(v1_posn(1), v1_posn(2), 1) ...
        + orient_field{2}(v2_posn(1), v2_posn(2), 1) ...
        + orient_field{2}(v3_posn(1), v3_posn(2), 1))/3;
    
    average_grad = [tri_center_orient_2, tri_center_orient_1]; %because these axis must match link_posn
    weight1 = average_grad(1)*link1_posn(1) +  average_grad(2)*link1_posn(2);
    weight2 = average_grad(1)*link2_posn(1) +  average_grad(2)*link2_posn(2);
    weight3 = average_grad(1)*link3_posn(1) +  average_grad(2)*link3_posn(2);
    
    edgeData(counter, :) = [first_1cell, index_tri, weight1];
    counter = counter +1;
    edgeData(counter, :) = [sec_1cell, index_tri, weight2];
    counter = counter +1;
    edgeData(counter, :) = [third_1cell, index_tri, weight3];
    counter = counter +1;
end

edgeData = edgeData(1:counter - 1, :); %only grab nonzero elements

%   Define U and W
start_1cells = find(S(:, 2) ~= 0, 1, 'first');
start_2cells = find(S(:, 3) ~= 0, 1, 'first');

U = zeros(length(S), 1);
U(start_1cells:start_2cells-1) = 1;
W = 1 - U;

if 1
    % Sort the edgeData first, before creating the graph.  This will save time
    % later on.
    % Sorted as A(i, 1) < A(i, 2) and A(i, 1) <= A(i + 1, 1)
    
    
    % *% Q: What do we do with the weights?  At this point, I believe it's an
    % undirected graph, so we don't flip their signs.*
    
    %If you get a "flipped order" warning, then you know that some of the
    %edges are not going from lower order cells to higher order cells.
    
    tmp = zeros(length(edgeData), 2);
    tmp_weight = zeros(length(edgeData), 1);
    for i = 1:length(edgeData)
        if edgeData(i, 1) < edgeData(i, 2)
            tmp(i, :) = [edgeData(i, 1), edgeData(i, 2)];
            tmp_weight(i) = edgeData(i, 3);
        else
            disp('flipped order');
            tmp(i, :) = [edgeData(i, 2), edgeData(i, 1)];
            tmp_weight(i) = -edgeData(i, 3); %not postive this is correct, but it never gets to this condition
        end
    end
    [~, I] = sort(tmp(:, 1), 'ascend');
    edgeData = [tmp(I, :), tmp_weight(I)];
end
%   Create graph G
EdgeTable = table(edgeData(:, 1:2),'VariableNames',{'EndNodes'});
G = graph(EdgeTable);
num_G_nodes = size(G.Nodes, 1);
U = U.* (1:num_G_nodes)'; %sets of indices
W = W.* (1:num_G_nodes)';

G.Edges.Weight = edgeData(:, 3) + rand(length(edgeData), 1)*10^(-10); %add small random number to fix ties
G.Nodes.locs = S;

G.Nodes.U = U;
G.Nodes.W = W;
G.Nodes.U_SM = U;
G.Nodes.W_SM = W;
G.Edges.U_edges = ismember(G.Edges.EndNodes(:, 1),U');  %these edges run from U to W
G.Edges.W_edges = ismember(G.Edges.EndNodes(:, 1),W');   %these edges run from W to U


%Plot G if small
if 0
    if size(G.Nodes, 1) < 3700
        dG = digraph(edgeData(:, 1), edgeData(:, 2), edgeData(:, 3));
        vertex_locs = calc_graph_vertex_locs(S, DT);
        
        LWidths =  abs(5*G.Edges.Weight/max(G.Edges.Weight));
        tmp = G.Edges.Weight < 0;
        neg_edges = G.Edges.EndNodes(tmp, :);
        
        figure; H = plot(dG, 'XData', vertex_locs{1}, 'YData', vertex_locs{2}, 'LineWidth',LWidths);
        highlight(H, neg_edges(:, 1), neg_edges(:, 2), 'EdgeColor', 'r');
    end
end

%Build lookup table
edgeData = G.Edges.EndNodes;
stop_pts = find(diff(edgeData(:, 1)));
%to calculate the neighbors of i, go from stop_pt(i - 1) to stop_pt(i);
lookup = [0; stop_pts; length(edgeData)];


end