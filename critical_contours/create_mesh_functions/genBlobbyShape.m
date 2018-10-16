function genBlobbyShape = genBlobbyShape(baseShape, angles, freqs, amps, phases, DEBUG) 
% genBlobbyShape
% Steve Cholewiak - scholewiak@gmail.com
%
%   This function will apply sinusoidal pertubations to a base mesh
%   (defined as a structure with vertices). The input variables, angles,
%   freqs, and amps, need to be nx3 matrices, where the first
%   column is for the x-axis modulation, second column is for y-axis, and
%   third column is for z-axis.  The output is a structure of transformed
%   vertices.  Use the following code to prepare the mesh for moglmorpher
%   if creating a new Psychtoolbox experiment:
%     genBlobbyShape.normals = patchnormals(genBlobbyShape);
%     genBlobbyShape.texcoords = genBlobbyShape.vertices;
%     genBlobbyShape.vertices = genBlobbyShape.vertices';
%     genBlobbyShape.faces = genBlobbyShape.faces'-1;
%     genBlobbyShape.normals = genBlobbyShape.normals';
%     genBlobbyShape.texcoords = genBlobbyShape.vertices+0.5;
%
%   Examples:
%   % Create blobby shape
%     angles = [2.1104,5.0559,1.5422;...
%             0.8624,3.5590,5.0990;...
%             4.2091,3.4773,3.8453;...
%             3.2286,5.6909,3.1115;...
%             0.2443,5.5485,5.3976];
%     freqs = [9.6375,5.5278,11.6415;...
%             5.1616,7.2833,12.3212;...
%             12.4602,4.7653,11.8595;...
%             6.5986,4.1786,10.0673;...
%             5.0346,10.9616,9.6997];
%     amps = [-0.0117,0.0170,-0.0040;...
%             -0.0190,-0.0004,0.0167;...
%             -0.0032,0.0164,-0.0164;...
%             0.0003,0.0048,-0.0025;...
%             0.0145,-0.0197,0.0086];
%     baseShape = sphere_tri('ico',5,[],0);
%     newShape = genBlobbyShape(baseShape, angles, freqs, amps)
%   % Create random blobby shape
%     numPertubations = 5;
%     angles = rand(numPertubations,3)*2*pi;
%     freqs = rand(numPertubations,3)*5+5;
%     amps = rand(numPertubations,3)*0.02-0.01;
%     baseShape = sphere_tri('ico',5,[],0);
%     newShape = genBlobbyShape(baseShape, angles, freqs, amps)
%
%   REVISION HISTORY:
%       24.09.2013 - SAC - Improved documentation
%       05.12.2014 - SAC - Added phase manipulation

    if (nargin < 5) %|| isempty(phases)
        phases = zeros(size(angles));
    end
    if (nargin < 6) %|| isempty(DEBUG)
        DEBUG = false;
    end
    genBlobbyShape = baseShape;

    % Setup shape parameters
    shapeItts = size(angles,1);
    
    for i = 1:shapeItts
        % Rotate around x-axis, applied to yz-plane
        a=cos(angles(i,1)) * freqs(i,1);
        b=sin(angles(i,1)) * freqs(i,1);
        genBlobbyShape.vertices(:,1) = genBlobbyShape.vertices(:,1) + ...
        sin(a*genBlobbyShape.vertices(:,2) + b*genBlobbyShape.vertices(:,3) + phases(i,1)) * amps(i,1);
        % Rotate around y-axis, applied to xz-plane
        a=cos(angles(i,2)) * freqs(i,2);
        b=sin(angles(i,2)) * freqs(i,2);
        genBlobbyShape.vertices(:,2) = genBlobbyShape.vertices(:,2) + ...
        sin(a*genBlobbyShape.vertices(:,1) + b*genBlobbyShape.vertices(:,3) + phases(i,2)) * amps(i,2);
    end
    for i = 1:shapeItts
        % Rotate around z-axis, applied to xy-plane
        a=cos(angles(i,3)) * freqs(i,3);
        b=sin(angles(i,3)) * freqs(i,3);
        genBlobbyShape.vertices(:,3) = genBlobbyShape.vertices(:,3) + ...
        sin(a*genBlobbyShape.vertices(:,1) + b*genBlobbyShape.vertices(:,2) + phases(i,3)) * amps(i,3);
    end
    
    if DEBUG
        patch(genBlobbyShape,'EdgeColor',[0.5,0.5,0.5])
    end
end