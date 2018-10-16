README:

Code is written and maintained by Ben Kunsberg.
The mex components were written by Shivam Nadimpalli.
The 3D potato shape generation was written by Steve Cholowiak.

This code generates:
1. A collection of shaded images of randomly generated 'potato' shapes.
2. True depth and slant (slant is related to the projection of surface normal onto view vector) images.
3. Critical contours from images.  The extremal curves computation is done via Fast
Combinatorial Vector Field Topology (Reininghaus 2011).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Getting Started%

This code may run out of the box (e.g. on a Mac 10.13.6) or you may need to mex the 'run_fast_CVFT.cpp' file. It requires gcc 4.9 or greater and the LEMON graph library. 

I have included a copy of the most recent Lemon library (as of 5/18) in  the ./cvft folder.  If you use that, you must unzip 'cvft/lemon' first. Then either run 'mex fast_CVFT_mat.cpp' or run " 'mex fast_CVFT_mat.cpp -'location_of_lemon_library_here' ". 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

There are two functions and one script in this root folder.

1.  For 'generate_batch_shapes', you can just run it with no arguments.  It will create random potato shapes and then generate the critical contours ('extremal contours') on the associated slant image.

2. For a particular slant image, you can run find_critical_contours_from_slant('filename_here').
It will return images showing the max-saddle separatrices for that slant image.

Ex: find_critical_contours_from_slant('shape_slant')

3. For a particular shaded image, you can run find_critical_contours_from_image('filename_here').
It will return images showing the max-saddle separatrices for that slant image.

Ex: find_critical_contours_from_image('shaded_slant')


The results from all three can be found in the ./data folder.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This code generated many of the figures in https://epubs.siam.org/doi/abs/10.1137/17M1145525
Critical Contours: An Invariant Linking Image Flow with Salient Surface Organization



10/16/18
Ben Kunsberg