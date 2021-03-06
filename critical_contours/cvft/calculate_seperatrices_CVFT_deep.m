%From the matching, this computes the max-saddle slant separatrices and
%outputs a figure.
%This will output a mask of those separatrices
%6/14/18



function [saddle_pts, seperatrices, salience_mask, ms_full] = calculate_seperatrices_CVFT_deep(DT, G, M, S, fig, img, boundary_nodes, full_img_sz, type)
crit_pt_plot_size = 10;

vertex_locs = calc_graph_vertex_locs(S, DT);
xdata = (vertex_locs{1} + 1);
ydata = (vertex_locs{2} + 1);
G_edges = G.Edges.EndNodes; %turn to matrix for speed.
%% Find Saddle Points

start_1cells = find(S(:, 2) ~= 0, 1, 'first');
start_2cells = find(S(:, 3) ~= 0, 1, 'first');


cells = cell(3, 1);
cells{1} = 1:start_1cells-1; % 0cells
cells{2} = start_1cells:start_2cells - 1;%1cells
cells{3} = start_2cells:length(S); % 2cells

%find all critical points
nodes_w_matching = M(:);
tmp = unique(G_edges(:));
normal_pts = ismember(tmp, nodes_w_matching);
critical_pts = unique(tmp(~normal_pts));
saddle_pts = critical_pts(ismember(critical_pts, cells{2}));
max_pts = critical_pts(ismember(critical_pts, cells{3}));
min_pts = critical_pts(ismember(critical_pts, cells{1}));
if fig
    figure; H = plot(G,  'XData', vertex_locs{1}, 'YData', vertex_locs{2}); highlight(H,max_pts, 'NodeColor', 'r', 'MarkerSize', 20); highlight(H,min_pts, 'NodeColor', 'y', 'MarkerSize', 20); highlight(H,saddle_pts, 'NodeColor', 'g', 'MarkerSize', 20); title('Critical Points');
end
% saddle points are 1-dim critical points

asc_seperatrices = [];
chosen_seperatrices = [];
seperatrices = cell(length(saddle_pts), 1);
seps_posns = cell(length(saddle_pts), 1);

for i = 1:length(saddle_pts)
    %%
    curr_saddle = saddle_pts(i);
    n1 = G_edges(:, 1) == curr_saddle;
    n2 = G_edges(:, 2) == curr_saddle;
    
    crit_neighbors = [G_edges(n1, 2); G_edges(n2, 1)];
    crit_i_seperatrices = cell(length(crit_neighbors), 1);
    crit_i_seps_posns = cell(length(crit_neighbors), 1);
    
    for j = 1:length(crit_neighbors)
        curr_seed = crit_neighbors(j);
        
        % Calculate dimension of streamline
        if sum(curr_seed == cells{1}) == 1
            p = 0; % 1-0-1 streamline
        elseif sum(curr_seed == cells{3}) == 1
            p = 2; %1-2-1 streamline
        else
            disp('Immediate neighbor of saddle is not dim 0 or 2!');
        end
        
        % Find matched node to curr_seed
        tmp1 = curr_seed == M(:, 1); tmp2 = curr_seed == M(:, 2);
        match_node_to_seed = [M(tmp1, 2), M(tmp2, 1)];
        
        %% Elongate streamline
        if ~isempty(match_node_to_seed)
            streamline_j = [curr_saddle; curr_seed; match_node_to_seed]; %original
        else
            streamline_j = [curr_saddle; curr_seed];
        end
        queue = match_node_to_seed;
        counter = 0; %we are starting at just finished matching.  The next move will be a seeding.
        %When counter is even, seed. Look for cells with dim = seed_dim.  When counter is odd, match.
        
        nodes_already_added_queue1 = [];
        nodes_already_added_queue2 = [];
        while ~isempty(queue)
            curr_node = queue(1, 1);
            tmp1 = curr_node == M(:, 1); tmp2 = curr_node == M(:, 2);
            matched_node = [M(tmp1, 2), M(tmp2, 1)];
            
            if mod(counter, 2) == 0 %if even, seed single neighbor that is not in matching
                n1 = G_edges(:, 1) == curr_node;
                n2 = G_edges(:, 2) == curr_node;
                neighbors = [G_edges(n1, 2); G_edges(n2, 1)];
                correct_neighbor = intersect(setdiff(neighbors, matched_node), cells{p+1}); %this should be unique
                
                if length(correct_neighbor) ~= 1
                    disp('Finished separatrix');
                    disp(correct_neighbor);
                end
                %%
                streamline_j = [streamline_j; correct_neighbor]; %#ok<*AGROW>
                if sum(nodes_already_added_queue1 == correct_neighbor) == 0
                    queue = [queue; correct_neighbor];
                    nodes_already_added_queue1 = [nodes_already_added_queue1, correct_neighbor];
                end
                
            else %if odd, add the matched node to streamline and queue
                if ~isempty(matched_node)
                    streamline_j = [streamline_j; matched_node];
                    if sum(nodes_already_added_queue2 == matched_node) == 0
                        queue = [queue; matched_node];
                        nodes_already_added_queue2 = [nodes_already_added_queue2, matched_node];
                    end
                end
            end
            
            counter = counter + 1;
            queue = queue(2:end, :);
        end
        crit_i_seperatrices{j} = streamline_j;
        crit_i_seps_posns{j} = [xdata(streamline_j), ydata(streamline_j)];
    end
    seperatrices{i} = crit_i_seperatrices;
    seps_posns{i} = crit_i_seps_posns;
    
    
end

%% Compile all seperatrices, possibly ignoring ones that touch the boundary.
%Type lets us choose between max/saddle and min/saddle
%Chosen separatrices stores the (x, y) points for future processing
%(currently unused)
all_seperatrices = [];

%get only the seperatrices that go from maxs to saddles, BOUNDARY OF DESCENDING MANIFOLD

if strcmp(type, 'slant')
    chosen_seperatrices = seperatrices;
    for i = 1:length(seperatrices)
        for j = 1:length(seperatrices{i})
            if sum(ismember(seperatrices{i}{j}, min_pts)) == 1  && sum(ismember(seperatrices{i}{j}, saddle_pts)) == 1  %one max and one saddle (max/min are flipped)
                all_seperatrices = [all_seperatrices; seperatrices{i}{j}];
                chosen_seperatrices{i}{j} = [xdata(chosen_seperatrices{i}{j}), ydata(chosen_seperatrices{i}{j})];
            else
                chosen_seperatrices{i}{j} = [];
            end
        end
        chosen_seperatrices{i} = chosen_seperatrices{i}(~cellfun('isempty',chosen_seperatrices{i}));
    end
    
elseif strcmp(type, 'shaded')
    chosen_seperatrices = seperatrices;
    for i = 1:length(seperatrices)
        for j = 1:length(seperatrices{i})
            if sum(ismember(seperatrices{i}{j}, max_pts)) == 1  && sum(ismember(seperatrices{i}{j}, saddle_pts)) == 1  %one max and one saddle (max/min are flipped)
                all_seperatrices = [all_seperatrices; seperatrices{i}{j}];
                chosen_seperatrices{i}{j} = [xdata(chosen_seperatrices{i}{j}), ydata(chosen_seperatrices{i}{j})];
            else
                chosen_seperatrices{i}{j} = [];
            end
        end
        chosen_seperatrices{i} = chosen_seperatrices{i}(~cellfun('isempty',chosen_seperatrices{i}));
    end
    
else
    error('Type is not "slant" or "shaded"');
end



all_seperatrices = unique(all_seperatrices);
if fig %plots matching
    for i = 1:length(saddle_pts)
        figure;  H = plot(G, 'XData', vertex_locs{1}, 'YData', vertex_locs{2}); %vertex locs goes from [0, -20] rows to [0, 20] cols
        for j = 1:length(seperatrices{i})
            highlight(H, seperatrices{i}{j}, 'NodeColor', 'r');
        end
        highlight(H, M(2:end, 1), M(2:end, 2), 'EdgeColor', 'g', 'LineWidth', 1.5); title(['Streamline associated to critical point: ', num2str(i)]);
        highlight(H, critical_pts, 'NodeColor', 'b', 'MarkerSize', 4);
        highlight(H, saddle_pts(i), 'NodeColor', 'g', 'MarkerSize', 8);
    end
end
sz = size(img);

%image + all_seperatrices
fig = 1;
if fig
    figure(1); hold on;  imagesc(img); axis tight;  %contour(img, 20, 'r');
    set(gcf,'position',get(0,'Screensize')/1.5); axis equal; colormap(gray); axis ij; axis off;
    %set(gcf, 'Position', get(0,'Screensize'))
    H = plot(G, 'XData',xdata, 'YData', ydata, 'EdgeColor', 'none', 'MarkerSize', 0.1);
    highlight(H, all_seperatrices, 'NodeColor', 'b', 'MarkerSize', 2);
    scatter(boundary_nodes(:, 2), boundary_nodes(:, 1), 'b', 'filled'); %to plot boundary, using scatter is much simpler
    highlight(H,saddle_pts, 'NodeColor', 'g', 'MarkerSize', crit_pt_plot_size); title('Critical Points');    
    if strcmp(type, 'slant')
        highlight(H, min_pts, 'NodeColor', 'y', 'MarkerSize', crit_pt_plot_size);
    elseif strcmp(type, 'shaded')
        highlight(H, max_pts, 'NodeColor', 'r', 'MarkerSize', crit_pt_plot_size);
    end
    % Capture image
    set(gcf, 'Position', get(0, 'Screensize'))
    tmp = getframe(1);
    frame_img = tmp;
    ms_full = im2double(tmp.cdata);
    
    %Create salience mask
    if 1
        salience_mask = zeros(size(img));
        for i = 1:length(all_seperatrices)
            salience_mask(round(ydata(all_seperatrices(i))), round(xdata(all_seperatrices(i)))) = 1;
        end
    else
        salience_mask = clean_MS_mask(chosen_seperatrices, img); %the clean version (high slant seps)
    end
    
    salience_mask = imresize(salience_mask, full_img_sz);
    
    
    %% If desired, return the positions of the MS parts as a cell array
    if 0
        MS_complex = struct('seps', 0, 'all_seps', 0, 'mins', 0, 'sads', 0, 'maxs', 0);
        MS_complex.all_seps = [xdata(all_seperatrices), ydata(all_seperatrices)];
        MS_complex.mins = [xdata(min_pts), ydata(min_pts)];
        MS_complex.maxs = [xdata(max_pts), ydata(max_pts)];
        MS_complex.sads = [xdata(saddle_pts), ydata(saddle_pts)];
        MS_complex.seps = seps_posns;
        MS_complex.asc = asc_seperatrices;
        MS_complex.des = des_seperatrices;
    end
    
end
