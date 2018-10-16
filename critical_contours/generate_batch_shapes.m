%This script creates shaded images of shapes along with the slant and depth
%of the shape.  In addition, it will run the MS complex on the slant field,
%creating the "critical contours".

%The save folder is in the ./data folder.  The matching is done via Fast
%Combinatorial Vector Field Topology (Reininghaus 2011).  It may take a
%while for resolutions above 200.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%By Ben Kunsberg and Shivan Nadimpalli
%July 12, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


addpath(genpath(pwd))

%Parameters
num_runs = 1; %set number of desired random shapes here.
resolution = 200;

%Run
for i = 1:num_runs
clc;
string = generate_one_stimuli(); %put i in the argument if you want it to create shape_i; otherwise it just adds shapes to the data folder
clc;
generate_one_MS_stimuli(string, resolution);
end

