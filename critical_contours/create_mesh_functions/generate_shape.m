% create random meshes

function [newShape, vertex_normals, manipShapeVars] = generate_shape()
rng('shuffle')

%% Build manipShapeVars -- the parameters
SHAPEITTS = 10;
SHAPEAMPRANGE = [-0.05,0.05];
SHAPEAMPGAIN = [1,1,1];
SHAPEANGRANGE = [0,2*pi];
SHAPEFREQRANGE = [3,7];

clear manipShapeVars;
manipShapeVars.angles = SHAPEANGRANGE(1)+(SHAPEANGRANGE(2)-SHAPEANGRANGE(1))*rand(SHAPEITTS,3);
manipShapeVars.freqs = SHAPEFREQRANGE(1)+(SHAPEFREQRANGE(2)-SHAPEFREQRANGE(1))*rand(SHAPEITTS,3);
manipShapeVars.amps(:,1) = randperm(SHAPEITTS)';
manipShapeVars.amps(:,2) = repmat(SHAPEAMPRANGE,1,SHAPEITTS/2)';
manipShapeVars.amps = sortrows(manipShapeVars.amps,1);
manipShapeVars.amps(:,1) = randperm(SHAPEITTS)';
manipShapeVars.amps(:,3) = repmat(SHAPEAMPRANGE,1,SHAPEITTS/2)';
manipShapeVars.amps = sortrows(manipShapeVars.amps,1);
manipShapeVars.amps(:,1) = randperm(SHAPEITTS)';
manipShapeVars.amps(:,4) = repmat(SHAPEAMPRANGE,1,SHAPEITTS/2)';
manipShapeVars.amps(:,1) = [];
manipShapeVars.amps = sortrows(manipShapeVars.amps,1);
manipShapeVars.phases = zeros(size(manipShapeVars.amps))*2*pi;

%% Build the shape
baseShape = sphere_tri('ico',5,[],0);
newShape = genBlobbyShape(baseShape, ...
    manipShapeVars.angles, ...
    manipShapeVars.freqs, ...
    [manipShapeVars.amps(:,1) * SHAPEAMPGAIN(1),...
    manipShapeVars.amps(:,2) * SHAPEAMPGAIN(2),...
    manipShapeVars.amps(:,3) * SHAPEAMPGAIN(3)]);

TR = triangulation(newShape.faces, newShape.vertices);
vertex_normals = vertexNormal(TR);

%% Check for occlusion
%shoot out rays parallel to view direction and make sure each one has
%only two intersections?

%or project to depth map and make sure it is smooth?

%or calculate slant

%get the normals and make sure


%% Plot (test)
test = 1;
if test
    figure; patch(newShape, 'FaceColor', 'none');
end

%% Save figures

%save .mat file




end
