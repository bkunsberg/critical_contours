# critical_contours
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project%
Matlab Code to Generate Random Shaded, Depth, Slant Images and associated Critical Contours 


Code is written and maintained by Ben Kunsberg.
The mex components were written by Shivam Nadimpalli.
The 3D potato shape generation was written by Steve Cholowiak.

This code generates:
1. A collection of shaded images of randomly generated 'potato' shapes.
2. True depth and slant images.
3. Critical contours from images.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Getting Started%

This code may run out of the box (e.g. on a Mac 10.13.6) or you may need to mex the 'run_fast_CVFT.cpp' file. I think it requires gcc 4.9 or greater and the LEMON graph library.  You can do that by either
'mex fast_CVFT_mat.cpp', 'mex fast_CVFT_mat.cpp -I/usr/local/include/'  You may need to replace '-I/usr/local/include/' with the location of LEMON library.  I have included a copy of the Lemon library in  ./cvft folder


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Use%

There are two functions and one script in this root folder.

1.  For 'generate_batch_shapes', you can just run it with no arguments.  It will create random potato shapes and then generate the critical contours ('extremal contours') on the associated slant image.

2. For a particular slant image, you can run find_critical_contours_from_slant('filename_here').
It will return images showing the max-saddle separatrices for that slant image.

Ex: find_critical_contours_from_slant('shape_slant')

3. For a particular shaded image, you can run find_critical_contours_from_image('filename_here').
It will return images showing the max-saddle separatrices for that slant image.

Ex: find_critical_contours_from_image('shaded_slant')


The results from all three can be found in the ./data folder.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This code generated many of the figures in https://epubs.siam.org/doi/abs/10.1137/17M1145525
Critical Contours: An Invariant Linking Image Flow with Salient Surface Organization


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MIT License

Copyright (c) 2018 Benjamin Kunsberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
