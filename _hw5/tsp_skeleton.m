function tsp_skeleton(varargin)
    if (nargin == 0)
        % The start location.
        startPoint = [25; 25];
        % The number of cities.
        numberOfCities = 30;
        % The maximal distance from the center.
        mapRadius = 50;    
        % It generates cities randomly.
        points = [startPoint, mapRadius*rand(2, numberOfCities)];
    else
        points = varargin{1};
    end
    numberOfPoints = size(points,2);
    % It shows the generated cities and the start position.
    createGraphOfLocations(points, 'y');
    % All-to-all distances are computed.
    allToAllDistances = computeAllToAllDistances(points);
    % A minimal spanning tree is found.
    edgesOfSpanningTree = minimalSpanningTree(allToAllDistances, numberOfPoints);
    % It draws the minimal spanning tree in the graph.
    drawMinimalSpanningTree(edgesOfSpanningTree, points);
    % 2-approximate algorithm is used to find initial Hamiltonian circuit.
    [hamiltonianCircuit] = findHamiltonianCircuit(allToAllDistances, edgesOfSpanningTree, numberOfPoints);
    % It draws the initial Hamiltonian circuit.
    drawHamiltonianCircuit(hamiltonianCircuit, points, 'y');
    % It prints initial lengths.
    fprintf('The minimal spanning tree: %5.3f km\n', calculateTotalDistance(edgesOfSpanningTree));
    fprintf('Initial Hamiltonian circuit: %5.3f km\n', calculateTotalDistance(hamiltonianCircuit));
    % It tries to improve the length of the route.
    apply2optHeuristicsDCV(hamiltonianCircuit, points);
    
    
function [d] = distance(x,y)
    d = sqrt(sum((x-y)'.*(x-y)', 2))';

    
function [distances] = computeAllToAllDistances(points)
    writeIndex = 1;
    numberOfPoints = size(points,2);
    distances = zeros(3, numberOfPoints*(numberOfPoints-1)/2);
    for i=1:numberOfPoints
        for j=(i+1):numberOfPoints
            distances(:, writeIndex) = [i; j; distance(points(:,i), points(:,j))];
            writeIndex = writeIndex+1;
        end
    end
    % The array of edges is sorted ascendly according to edge lengths.
    [sortedDistances, indices] = sort(distances(3,:));
    distances = [distances(1:2,indices); sortedDistances];

    
function createGraphOfLocations(points, confirm)
    % The start location is at index 1.
    hold off; plot(points(1,1), points(2,1), 'ro'); hold on;
    % Show location of generated cities.
    plot(points(1,2:end), points(2,2:end), 'bx');
    % Add graph labels and a title.
    title('Map of generated cities', 'fontsize', 14);
    xlabel('x coordinate [km]'); ylabel('y-coordinate [km]'); 
    closeGraphAfterConfirmation(confirm);

    
function [treeEdges] = minimalSpanningTree(distances, numberOfPoints)
    % Edges of spanning tree and graph components are required to keep.
    treeEdges = zeros(numberOfPoints-1,1);
    componentNumber = 1; edgeWriterIndex = 1;
    graphComponents = zeros(numberOfPoints,1);
    % The edges are added to the graph in increasing order of distances.
    for k=1:size(distances,2)
        % Select edge (i,j).
        i = distances(1,k); j = distances(2,k);
        % Find out in which components nodes i,j are placed.
        c1 = graphComponents(i); c2 = graphComponents(j);
        % Check if the graph is still acyclic after adding the selected edge.
        if (c1 ~= c2 || (c1 == 0 && c2 == 0))
            % The selected edge can be added without breaking acyclic.
            treeEdges(edgeWriterIndex) = k;
            if ((c1 == 0) && (c2 == 0))
                % The added edge creates a new graph component.
                graphComponents(i) = componentNumber;
                graphComponents(j) = componentNumber;
                componentNumber = componentNumber+1;
            elseif (c1 == 0)
                % The node 'i' is connected with existing component c2.
                graphComponents(i) = c2;
            elseif (c2 == 0)
                % The node 'j' is connected with existing component c1.
                graphComponents(j) = c1;
            else
                % Both components c1 and c2 are merged into one.
                graphComponents(graphComponents == c2) = c1;
            end
            edgeWriterIndex = edgeWriterIndex+1;
        end
    end
    % The edge indices are transformed to edges.
    treeEdges = distances(:,treeEdges);

    
function [totalLength] = calculateTotalDistance(edges)
    totalLength = sum(edges(3,:));

    
function drawMinimalSpanningTree(treeEdges, points)
    % It draws cities and initial location.
    createGraphOfLocations(points, 'n');
    % All edges of the minimal spanning tree are drawn.
    for i=1:size(treeEdges,2)
        i1 = treeEdges(1,i); i2 = treeEdges(2,i);
        x1 = points(1,i1); y1 = points(2,i1);
        x2 = points(1,i2); y2 = points(2,i2);
        plot([x1,x2], [y1,y2], 'r');
    end
    % The length of the minimal spanning tree will be shown in the graph.
    treeLength = calculateTotalDistance(treeEdges);
    title(['The spanning tree ', num2str(treeLength), ' km'],'fontsize', 14);
    closeGraphAfterConfirmation('y');

    
function [circuitEdges] = findHamiltonianCircuit(distances, treeEdges, numberOfPoints)
    % Current location in the map.
    currentNode = 1; edgeWriterIndex = 1;
    % Edges of Hamiltonian circuit.
    circuitEdges = zeros(3, size(treeEdges,2));
    % The array of visited points.
    closedNodes = zeros(numberOfPoints,1);

    while ~all(closedNodes > 0.5)
        % All edges from the 'currentNode' are selected.
        selectedEdges = treeEdges(:, ceil(find(treeEdges(1:2,:) == currentNode)/2));
        % Each acceptable edge has both its nodes unclosed.
        usableEdges = find((closedNodes(selectedEdges(1,:))+closedNodes(selectedEdges(2,:))) < 0.5);
        if (~isempty(usableEdges))
            % The spanning tree edge is used.
            cheapestEdge = selectedEdges(:,usableEdges(1));
        else
            % The cheapest edge is selected from the graph.
            candidateEdges = distances(:, ceil(find(distances(1:2,:) == currentNode)/2));
            % It finds the first cheapest edge which has both nodes unclosed.
            edgeIndex = find((closedNodes(candidateEdges(1,:))+closedNodes(candidateEdges(2,:))) < 0.5, 1);
            if (isempty(edgeIndex))
                % The last edge is added to create circuit. 
                cheapestEdge = distances(:, (distances(1,:) == 1) & (distances(2,:) == currentNode));
            else
                cheapestEdge = candidateEdges(:, edgeIndex);
            end
        end
        % Check edge orientation and swap direction if it is required.
        if (cheapestEdge(1) ~= currentNode)
            cheapestEdge(1:2) = cheapestEdge(2:-1:1);
        end
        % Add the edge to the circuit, close current node and continue...
        circuitEdges(:,edgeWriterIndex) = cheapestEdge;
        edgeWriterIndex = edgeWriterIndex+1;
        closedNodes(currentNode) = 1;
        currentNode = cheapestEdge(2,1);
    end


function drawHamiltonianCircuit(circuitEdges, points, confirm)
    % It draws cities and initial location.
    createGraphOfLocations(points, 'n');
    % Plot Hamiltonian circuit.
    Lines = [circuitEdges(1:2,:); inf*ones(1,size(circuitEdges,2))];
    Lines = [Lines(:)'; Lines(:)'];
    Lines(:,(Lines(1,:) ~= Inf)) = points(:,Lines(1,(Lines(1,:) ~= Inf)));
    plot(Lines(1,:), Lines(2,:), 'g');
    % It computes and print the length of the Hamiltonian circuit.
    circuitLength = calculateTotalDistance(circuitEdges);
    title(['The Hamiltonian circuit ', num2str(circuitLength), ' km'], 'fontsize', 14);
    closeGraphAfterConfirmation(confirm);


function drawKoptImprovement(circuitEdges, locations, removeEdges, newEdges)
    % It draws the Hamiltonian circuit.
    drawHamiltonianCircuit(circuitEdges, locations, 'n');
    % The red edges will be removed.
    for i=1:size(removeEdges,2)
        edge = locations(:,removeEdges(1:2,i)');
        plot(edge(1,:), edge(2,:), 'r');
    end
    % The blue edged will be added.
    for i=1:size(newEdges,2)
        edge = locations(:,newEdges(1:2,i)');
        plot(edge(1,:), edge(2,:), 'b');
    end
    closeGraphAfterConfirmation('y');
    

function closeGraphAfterConfirmation(confirm)
    if (strcmp('y', confirm))
        input('Please press any key to continue...');
        close();
    end

    
function apply2optHeuristicsDCV(circuit, locations)
    numberOfLocations = size(locations,2);    
    % It computes all-to-all distance matrix.
    t = 0:(numberOfLocations*numberOfLocations-1);
    distanceVector = distance(locations(:,fix(t/numberOfLocations)+1), locations(:,mod(t,numberOfLocations)+1));
    matrixOfWeights = reshape(distanceVector, numberOfLocations, numberOfLocations);
    
    % TODO - implement 2-opt heuristic.
    % Use drawKoptImprovement function to show progress.
    % drawKoptImprovement(circuitEdges, locations, removeEdges, newEdges)
    improvement = true;
    while(improvement)
        [circuit,improvement] = twoopt(circuit,matrixOfWeights,locations);
    end
    
    % It displays final route.
    drawHamiltonianCircuit(circuit, locations, 'y');

function [circuit,improvement] = twoopt(circuit,w,locations)
    improvement = false;
    for i=1:size(circuit,2)
        for j=i+2:size(circuit,2)
            if(i ~= j)
                newTour = circuit;
                e1 = newTour(:,i);
                e2 = newTour(:,j);
                if(w(e1(1),e2(1)) + w(e1(2),e2(2)) < w(e1(1),e1(2)) + w(e2(1),e2(2)))
                    newTour(2,i) = e2(1);
                    newTour(3,i) = w(e1(1),e2(1));
                    
                    newTour(1,j) = e1(2);
                    newTour(3,j) = w(e1(2),e2(2));
                    
                    newTour(:,i+1:j-1) = fliplr(newTour(:,i+1:j-1));
                    newTour(1:2,i+1:j-1) = flipud(newTour(1:2,i+1:j-1));
                    
                    removedEdges(:,1) = circuit(:,i);
                    removedEdges(:,2) = circuit(:,j);
                    addedEdges(:,1) = newTour(:,i);
                    addedEdges(:,2) = newTour(:,j);
                    drawKoptImprovement(newTour, locations, removedEdges, addedEdges)
                    circuit = newTour;
                    improvement = true;
                    return;
                end
            end
        end
    end
