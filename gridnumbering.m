% points='Dropbox\points.mat' ;
%wp_path='C:\Users\Jessica\Dropbox\Lab\whitepoint.mat';
function [right_top_neighbors] = gridnumbering(b_centers, w_centers)
grid.b_centers=b_centers;
wp_points.w_centers=w_centers;
%% plot the point out to check 

figure;
scatter(grid.b_centers(:,1),grid.b_centers(:,2));
hold on;
scatter(wp_points.w_centers(:,1),wp_points.w_centers(:,2),'filled','o','MarkerFaceColor','g');
% Annotate each point with its index
for i = 1:size(grid.b_centers(:,1), 1)
    text(grid.b_centers(i, 1), grid.b_centers(i, 2), num2str(i), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
%% Label out white points find its global index

specific_points = wp_points.w_centers;
% Initialize an array to hold the indices
wp_indices = zeros(size(specific_points, 1), 1);
% Tolerance for floating point comparison
tolerance = 5;
for i = 1:size(specific_points, 1)
    % Check each point against all points in grid.b_centers
    diff = abs(grid.b_centers - specific_points(i, :));
    % Find rows where both coordinates match within the specified tolerance
    index = find(all(diff < tolerance, 2));
    % If found, store the index
    if ~isempty(index)
        wp_indices(i) = index;
    else
        wp_indices(i) = NaN; % Assign NaN if no match is found
    end
end
%% Find Nearest Neighbor

fields = {'id1', 'id2', 'id3', 'id4', 'id5', 'id6', 'id7', 'id8'};
num_points = size(grid.b_centers, 1);
nearest_neighbors = repmat(struct(fields{:}), num_points, 1);

for i = 1:length(grid.b_centers)
    current_point = grid.b_centers(i, :);
    distances = sqrt(sum((grid.b_centers - current_point).^2, 2));
    [~, sorted_indices] = sort(distances);
    % Calculate unit step distances
    unit_distance=sqrt(sum((grid.b_centers(sorted_indices(2), :) - current_point).^2, 2));
    for j = 1:8
        neighbor_index = sorted_indices(j + 1);
        localdis = sqrt(sum((grid.b_centers(neighbor_index, :) - current_point).^2, 2));
        % Check if dx or dy exceeds the threshold based on unit distance
        if localdis>1.85 * unit_distance
            nearest_neighbors(i).(fields{j}) = NaN; % Assign NaN if outside threshold
        else
            nearest_neighbors(i).(fields{j}) = neighbor_index; % Assign neighbor index normally
        end
    end
end

%% Find x and y (longer side) the basis vectors

% Calculate vectors from each point to the other two
v12 = wp_points.w_centers(2,:) - wp_points.w_centers(1,:);
v13 = wp_points.w_centers(3,:) - wp_points.w_centers(1,:);
v21 = -v12;
v23 = wp_points.w_centers(3,:) - wp_points.w_centers(2,:);
v31 = -v13;
v32 = -v23;

% Compute dot products for each pair sharing a common point
dot1 = abs(dot(v12, v13));
dot2 = abs(dot(v21, v23));
dot3 = abs(dot(v31, v32));

% Find the point with the minimum dot product (closest to orthogonal)
[minDot, origin_idx] = min([dot1, dot2, dot3]);

% Assign the origin point
origin_point = wp_points.w_centers(origin_idx, :);

% Determine the endpoint indices for x and y vectors
if origin_idx == 1    %% V3
    x_vector_endpoint_idx = 2; % Endpoint of v12
    y_vector_endpoint_idx = 3; % Endpoint of v13
    x_vector=v12;
    y_vector=v13;
elseif origin_idx == 2
    x_vector_endpoint_idx = 1; % Endpoint of v21
    y_vector_endpoint_idx = 3; % Endpoint of v23
    x_vector=v21;
    y_vector=v23;
elseif origin_idx == 3
    x_vector_endpoint_idx = 1; % Endpoint of v31
    y_vector_endpoint_idx = 2; % Endpoint of v32
    x_vector=v31;
    y_vector=v32;
end

% Swap if necessary to ensure x_vector is the shorter side
if norm(x_vector) > norm(y_vector)
    [x_vector, y_vector] = deal(y_vector, x_vector);
    [x_vector_endpoint_idx, y_vector_endpoint_idx] = deal(y_vector_endpoint_idx, x_vector_endpoint_idx);
end

% Convert local indices to global indices
origin_global = wp_indices(origin_idx);
x_vector_global_endpoint = wp_indices(x_vector_endpoint_idx);
y_vector_global_endpoint = wp_indices(y_vector_endpoint_idx);

% Output results with global indices
% fprintf('Origin Index (Global): %d\n', origin_global);
% fprintf('X-vector Endpoint Index (Global): %d\n', x_vector_global_endpoint);
% fprintf('Y-vector Endpoint Index (Global): %d\n', y_vector_global_endpoint);
% fprintf('Origin: (%f, %f)\n', wp_points.w_centers(origin_idx, :));
% fprintf('X-vector: [%f, %f], Endpoint: (%f, %f)\n', x_vector, wp_points.w_centers(x_vector_endpoint_idx, :));
% fprintf('Y-vector: [%f, %f], Endpoint: (%f, %f)\n', y_vector, wp_points.w_centers(y_vector_endpoint_idx, :));
%% Perform coordinate transformation 

% Normalize vectors
unit_x_vector = x_vector / norm(x_vector);
unit_y_vector = y_vector / norm(y_vector);
% Loop through all points to identify right and top neighbors
R = [unit_x_vector; unit_y_vector];  %%% v2
% Compute the transpose of the rotation matrix
R_transpose = R';
grid.b_centers = (grid.b_centers-wp_points.w_centers(origin_idx, :)) * R_transpose;
wp_points.w_centers = (wp_points.w_centers-wp_points.w_centers(origin_idx, :)) * R_transpose;

%% Find starting point
% Convert local indices to global indices
origin_global = wp_indices(origin_idx);
origin_coordinates= grid.b_centers(origin_global, :);
% Initialize variables to store the starting point information
start_index = [];
min_distance = Inf;
% Initialize variables to store points with 5 NaN values in neighbor indices
nan_count_5_indices = [];

% Iterate over all points
for i = 1:num_points
    current_point = grid.b_centers(i, :);
    neighbors_indices = [nearest_neighbors(i).id1, nearest_neighbors(i).id2, nearest_neighbors(i).id3, nearest_neighbors(i).id4, ...
                         nearest_neighbors(i).id5, nearest_neighbors(i).id6, nearest_neighbors(i).id7, nearest_neighbors(i).id8];
    
    % Count the number of NaN values in neighbor indices
    nan_count = sum(isnan(neighbors_indices));
    % Record points with 5 NaN values
    if nan_count == 5
        nan_count_5_indices = [nan_count_5_indices, i];
        continue;
    end
end

% If there are points with 5 NaN values, find the nearest one to the origin
if ~isempty(nan_count_5_indices)
    for i = nan_count_5_indices
        current_point = grid.b_centers(i, :);
        distance = norm(current_point - origin_coordinates);
        if distance < min_distance
            start_index= i;
            min_distance = distance;
        end
    end
end
start_coordinates = grid.b_centers(start_index, :);
%% Translate points acc to starting point
grid.b_centers = grid.b_centers-start_coordinates;  % need assign new value
wp_points.w_centers =wp_points.w_centers-start_coordinates;  % need assign new value
%% Plot transformed points to check
figure;
scatter(grid.b_centers(:,1),grid.b_centers(:,2));
hold on;
scatter(wp_points.w_centers(:,1),wp_points.w_centers(:,2),'filled','o','MarkerFaceColor','g');
% Annotate each point with its index
for i = 1:size(grid.b_centers(:,1), 1)
    text(grid.b_centers(i, 1), grid.b_centers(i, 2), num2str(i), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
%% Find Right and Top 
right_top_neighbors = struct('right_neighbor', {}, 'top_neighbor', {});

for i = 1:size(grid.b_centers, 1)
    current_point = grid.b_centers(i, :);
    neighbors_indices = [nearest_neighbors(i).id1, nearest_neighbors(i).id2, nearest_neighbors(i).id3, nearest_neighbors(i).id4, ...
                         nearest_neighbors(i).id5, nearest_neighbors(i).id6, nearest_neighbors(i).id7, nearest_neighbors(i).id8];
    
    % Filter out NaN indices
    valid_indices = ~isnan(neighbors_indices);
    neighbors_indices = neighbors_indices(valid_indices);
    
    neighbor_vectors = grid.b_centers(neighbors_indices, :) - current_point;
    distances = sqrt(sum((neighbor_vectors).^2, 2));  % Euclidean distances for all neighbors

    % Determine displacements in x and y
    dx = neighbor_vectors(:,1);
    dy = neighbor_vectors(:,2);

    % Check direction based on the sign of the displacements relative to the unit vectors
    valid_right = sign(dx) ==1 & (abs(dx) > 15);
    valid_top = sign(dy) == 1 & (abs(dy) > 15);

    % Sort the valid neighbors by the magnitude of their displacements
    if any(valid_right)
        [~, furthest_right_idxs] = maxk(abs(dx(valid_right)), min(3, sum(valid_right)));
        valid_right_indices = find(valid_right);
        right_candidates = neighbors_indices(valid_right_indices(furthest_right_idxs));

        % Find the closest by absolute distance among these candidates
        candidate_distances = sqrt(sum((grid.b_centers(right_candidates, :) - current_point).^2, 2));
        [~, idx_right] = min(candidate_distances);
        right_top_neighbors(i).right_neighbor = right_candidates(idx_right);
    else
        right_top_neighbors(i).right_neighbor = NaN;
    end

    if any(valid_top)
        [~, furthest_top_idxs] = maxk(abs(dy(valid_top)), min(3, sum(valid_top)));
        valid_top_indices = find(valid_top);
        top_candidates = neighbors_indices(valid_top_indices(furthest_top_idxs));

        % Find the closest by absolute distance among these candidates
        candidate_distances = sqrt(sum((grid.b_centers(top_candidates, :) - current_point).^2, 2));
        [~, idx_top] = min(candidate_distances);
        right_top_neighbors(i).top_neighbor = top_candidates(idx_top);
    else
        right_top_neighbors(i).top_neighbor = NaN;
    end
end
% Display or process right_top_neighbors as needed
% disp(right_top_neighbors);
%% Labelling
% Initialize the relabeling counter
new_label = 1;

% Initialize a map to store old index and corresponding new label
index_map = containers.Map('KeyType','double','ValueType','double');

% Start with the given starting index
current_index = start_index;
index_map(current_index) = new_label;

% Update the right and top neighbors with new labels
right_top_neighbors(current_index).new_label = new_label;

% Helper function to check if a neighbor index is valid (not NaN)
isValidNeighbor = @(idx) ~isnan(idx);

% Move right, relabeling the indices
right_neighbor_index = right_top_neighbors(current_index).right_neighbor;
while isValidNeighbor(right_neighbor_index)
    new_label = new_label + 1;
    index_map(right_neighbor_index) = new_label;
    right_top_neighbors(right_neighbor_index).new_label = new_label;
    current_index = right_neighbor_index;
    right_neighbor_index = right_top_neighbors(current_index).right_neighbor;
end

% Reset the current index to the starting point
current_index = start_index;
top_neighbor_index = right_top_neighbors(current_index).top_neighbor;

% Move up, relabeling the indices
while isValidNeighbor(top_neighbor_index)
    new_label = new_label + 1;
    index_map(top_neighbor_index) = new_label;
    right_top_neighbors(top_neighbor_index).new_label = new_label;
    current_index = top_neighbor_index;
    top_neighbor_index = right_top_neighbors(current_index).top_neighbor;
    
    % Move right, relabeling the indices in the same column
    right_neighbor_index = right_top_neighbors(current_index).right_neighbor;
    while isValidNeighbor(right_neighbor_index)
        new_label = new_label + 1;
        index_map(right_neighbor_index) = new_label;
        right_top_neighbors(right_neighbor_index).new_label = new_label;
        current_index = right_neighbor_index;
        right_neighbor_index = right_top_neighbors(current_index).right_neighbor;
    end
end
%% Plot the Final points
figure
scatter(grid.b_centers(:,1), grid.b_centers(:,2));
hold on;
scatter(wp_points.w_centers(:,1), wp_points.w_centers(:,2), 'filled', 'o', 'MarkerFaceColor', 'r');

% Annotate each point with its new label
for i = 1:size(grid.b_centers, 1)
    % Check if the new label exists in right_top_neighbors
    if isfield(right_top_neighbors, 'new_label') && ~isnan(right_top_neighbors(i).new_label)
        % Get the new label
        new_label = right_top_neighbors(i).new_label;
        % Annotate the point with its new label
        text(grid.b_centers(i, 1), grid.b_centers(i, 2), num2str(new_label), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
end
end
