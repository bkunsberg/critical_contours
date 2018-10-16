function vertex_locs = calc_graph_vertex_locs(S, DT)

DT_Points = DT.Points; %for speed

Xdata = zeros(length(S), 1);
Ydata = zeros(length(S), 1);
%Note that DT.Points already compiles it so it's first column is an X value
%(increasing from left to right)
%and second column is a Y-value (increasing from down to up)
for i = 1:length(S)
    if sum(S(i, :) == 0) == 2 %vertex is 0-cell
       Xdata(i) = DT_Points(S(i, 1), 1); %row
       Ydata(i) = DT_Points(S(i, 1), 2); %col
    end
    
    if sum(S(i, :) == 0) == 1 %vertex is 1-cell
        vertex1_loc = DT_Points(S(i, 1), :);
        vertex2_loc = DT_Points(S(i, 2), :);
        Xdata(i) = (vertex1_loc(1) + vertex2_loc(1))/2; %midpoint of rows
        Ydata(i) = (vertex1_loc(2) + vertex2_loc(2))/2; %midpoint of cols
    end
    
    if sum(S(i, :) == 0) == 0 %vertex is 2-cell
        vertex1_loc = DT_Points(S(i, 1), :);
        vertex2_loc = DT_Points(S(i, 2), :);
        vertex3_loc = DT_Points(S(i, 3), :);
        Xdata(i) = (vertex1_loc(1) + vertex2_loc(1) + vertex3_loc(1))/3; %midpoint of rows
        Ydata(i) = (vertex1_loc(2) + vertex2_loc(2) + vertex3_loc(2))/3; %midpoint of cols
    end    
end
vertex_locs = cell(2, 1);
vertex_locs{1} = Xdata-1;
vertex_locs{2} = Ydata-1;



end