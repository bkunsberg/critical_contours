/* 

Fast Combinatorial Vector Field Topology

Implementation of Reininghaus, et. al. (2011). 

LEMON Graph Library used instead of Boost or Igraph.

Date: February 24, 2018

**********************
NOTE: COUNTING EDGES IS ACTUALLY VERY EXPENSIVE AND IS LINEAR IN SIZE OF GRAPH, SO MAYBE SUPPRESS THAT! But tbh hardly 
takes up any time, adding maybe a second, so doesn't really matter maybe?
**********************
TODO: Maybe output Paths_arr and the matching directly to Matlab. See the note at the end of the code for more details. 
**********************

*/

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <math.h>
#include <sstream>
#include <list>
#include <utility> 
#include <typeinfo>

#include <lemon/list_graph.h>
#include <lemon/concepts/digraph.h>
#include <lemon/core.h>
#include <lemon/concepts/graph.h>

#include "mex.h"
#include "matrix.h"

using namespace lemon;
using namespace std;

/*

GLOBAL VARIABLES AND MAPS DECALRED HERE

*/

int N;
int startU;
int endU; 
int finalMatch;

ListGraph G; 
ListGraph M;

ListGraph::EdgeMap<double> weight(G);

ListGraph::NodeMap<int> isActive(G);
ListGraph::NodeMap<int> bipartition(G);
ListGraph::NodeMap<double> dist(G);
ListGraph::NodeMap<int> predLink(G);

/*

SUPPLEMENTARY FUNCTIONS BELOW

*/


bool isValidAugmentingPath(ListGraph &match, vector<int> &path){
	int cnt1 = 0; int cnt2 = 0;

	for (ListGraph::IncEdgeIt e(match, match.nodeFromId(path.front())); e != INVALID; ++e) {
	cnt1++;
	}

	for (ListGraph::IncEdgeIt e(match, match.nodeFromId(path.back())); e != INVALID; ++e) {
	cnt2++;
	}


	if(cnt1 == 0 && cnt2 == 0){
		return true;
	}
	else{

		return false;
	}
}


double augmentingPathWeight(ListGraph &graph, vector<int> &path){
	double weightpath = 0;

	for(int l = 0; l < path.size() - 1; l++){
		ListGraph::Edge edge = findEdge(graph, graph.nodeFromId(path[l]), graph.nodeFromId(path[l + 1])); 
		weightpath += pow(-1, l) * weight[edge];
	}

	return weightpath;
}


void symmetricDifference(ListGraph &match, vector<int> &path){
	for(int i = 0; i < path.size() - 1; i ++){
		ListGraph::Node node1 = match.nodeFromId(path[i]);
		ListGraph::Node node2 = match.nodeFromId(path[i+1]);

		ListGraph::Edge edge = findEdge(match, node1, node2);
		if(edge != INVALID){

			match.erase(edge);
		}
		else{

			match.addEdge(node1, node2);
		}
	}
}


vector<int> getAugmentingPath(ListGraph &graph, int a){
	vector<int> p;
	p.push_back(a);

	ListGraph:: Node node = graph.nodeFromId(a);

	while(true){
	
		if(predLink[node] == 0){
			return p;
		}
		else{
			p.push_back(predLink[node]);
			node = graph.nodeFromId(predLink[node]);
		}
	}
}


bool sortbysec(pair<int,double> &a, pair<int,double> &b){
    return (a.second < b.second);
}

bool longest(const std::vector<int>& lhs, const std::vector<int>& rhs)
{
  return lhs.size() < rhs.size();	
}
/*

MAIN FUNCTIONS AS DEFINED IN REININGHAUS ET. AL. 

*/


// Have placed default arguments, get rid of them later.
void bellmanFord(ListGraph &graph, ListGraph &match, int N){
	mexPrintf("Running Bellman-Ford algorithm.\n");
	for(int i = 1; i <= N; i++){


		ListGraph::Node node = graph.nodeFromId(i);
		predLink[node] = 0; //predLink nil
		isActive[node] = 1; //isActive True

		// bipartitions: 1 = U (1 simplices), 0 = W (0, 2 simplices)
		if(bipartition[node] == 1){
			ListGraph::IncEdgeIt unmatched(match, match.nodeFromId(i));
			if(unmatched == INVALID){  // Node unmatched in match M
				dist[node] = 0;
			}
			else{
			dist[node] = 1000000000;    // Matched node but in U
			}
		}
		else{		// Node in W, so automatically \notin U\S(M)
			dist[node] = 1000000000;                                  
		}
	}

	// Setup for L
	ListDigraph L;
	ListDigraph::ArcMap<double> dirLweight(L);

	// Initialize nodes
	for(int i = 1; i <= N + 1; i++){
		L.addNode();
	}


	// Add edges to L
	for(ListGraph::EdgeIt e(graph); e!=INVALID; ++e){
		int u; int w;

		if(bipartition[graph.u(e)] == 1){
			// This means G.u(e) is in U
			u = graph.id(graph.u(e)); w = graph.id(G.v(e));
		}	
		else{
			// This means G.v(e) is in U  
			u = graph.id(graph.v(e)); w = graph.id(G.u(e));
		}

		// Next, we check if there is an edge between (u, v) in M. Below if no edge in M:
		if(findEdge(match, match.nodeFromId(u), match.nodeFromId(w)) == INVALID){
			ListDigraph::Arc label = L.addArc(L.nodeFromId(u), L.nodeFromId(w));
			dirLweight[label] = -weight[e];
		}
		else{ // There is an edge in M
			ListDigraph::Arc label = L.addArc(L.nodeFromId(w), L.nodeFromId(u));
			dirLweight[label] = weight[e];
		}
	}


	int abort = 0;

	while(abort == 0){

		abort = 1;

		for(int i = 1; i <= N; i++){

			// Node s is declared here: this is the s in line 19 of Alg. 4
			ListGraph::Node s = graph.nodeFromId(i);

			if(isActive[s] == 1){

				isActive[s] = 0; 

				for(ListDigraph::InArcIt e(L, L.nodeFromId(i)); e!=INVALID; ++e){

					ListGraph::Node src = graph.nodeFromId(L.id(L.source(e)));

					if(dist[s] > dist[src] + dirLweight[e]){

						dist[s] = dist[src] + dirLweight[e];

						predLink[s] = graph.id(src); 

						for(ListDigraph::OutArcIt e(L, L.nodeFromId(i)); e!=INVALID; ++e){
			
							ListGraph::Node tgt = graph.nodeFromId(L.id(L.target(e)));

							isActive[tgt] = 1;

							abort = 0;
						}
					}
				}
			}
		}
	}

	L.clear(); // Clear out the digraph at the end of everything
}


bool predict(ListGraph &graph, ListGraph &match, vector<vector<int> > &paths){

	bellmanFord(graph, match, N);

	// Setting up A
	vector <pair<int, double> > unmatchedInW;

	for(int i = 1; i <= N; i++){

		if(bipartition[graph.nodeFromId(i)] == 0){	

			ListGraph::IncEdgeIt unmatched(match, match.nodeFromId(i));

			if(unmatched == INVALID){ // Unmatched in M

				if(dist[graph.nodeFromId(i)] < 1000000000){
					unmatchedInW.push_back(make_pair(i, dist[graph.nodeFromId(i)]));
				}
			}
		}
	}

	sort(unmatchedInW.begin(), unmatchedInW.end(), sortbysec);

	list<int> A;

	for(int i = 0; i < unmatchedInW.size(); i++){
		A.push_back(unmatchedInW[i].first);
	}

	// Main stuff
	if(A.size() == 0){

		return true;
	}
	else{

		while(A.size() != 0){

			int actual_node = A.front();
			A.pop_front();

			vector<int> p = getAugmentingPath(graph, actual_node);

			if(isValidAugmentingPath(match, p)){

				symmetricDifference(match, p);

				paths.push_back(p);
			};
		}

		return false;
	}
}


void correct(ListGraph &graph, ListGraph &match, vector<vector<int> > &paths){

	while(true){

 		bellmanFord(graph, match, N);

		// Setting up A
		vector <pair<int, double> > unmatchedInW;

		for(int i = 1; i <= N; i++){

			if(bipartition[graph.nodeFromId(i)] == 0){	

				ListGraph::IncEdgeIt unmatched(match, match.nodeFromId(i));

				if(unmatched == INVALID){ // Unmatched in M

					if(dist[graph.nodeFromId(i)] < 1000000000){
						unmatchedInW.push_back(make_pair(i, dist[graph.nodeFromId(i)]));
					}
				}
			}
		}

		sort(unmatchedInW.begin(), unmatchedInW.end(), sortbysec);

		list<int> A;

		for(int i = 0; i < unmatchedInW.size(); i++){
			A.push_back(unmatchedInW[i].first);
		}

		//  Main stuff below
		if(A.size() == 0){
			break;
		}
		else{
			vector<int> p = getAugmentingPath(graph, A.front());

			double barrier = augmentingPathWeight(graph, p);

			if(barrier <= augmentingPathWeight(graph, paths.back())){
				break;
			}
			else{

				while(barrier > augmentingPathWeight(graph, paths.back())){

					vector<int> actual_path = paths.back();
					paths.pop_back();
					symmetricDifference(match, actual_path);
				}
			}
		}
	}
}

void predictorCorrector(ListGraph &graph, ListGraph &match, vector<vector<int> > &paths, int matchSize){
	mexPrintf("Size of matching:  %d nodes.\n", matchSize);
	while(true){
		bool isFinished = predict(graph, match, paths);
		mexPrintf("Finished predictor. The size of the matching is %d nodes.\n", countEdges(match));

 		if (countEdges(match) == matchSize){
			mexPrintf("Done!\n");
			break;
		}

		else{
			correct(graph, match, paths);
			mexPrintf("Finished corrector. The size of the matching is %d nodes.\n", countEdges(match));
			mexEvalString("drawnow;");
		}

		// if(isFinished == false){
		// 	correct(graph, match, paths);
		// 	mexPrintf("Finished corrector. The size of the matching is %d nodes.\n", countEdges(match));
		// 	mexEvalString("drawnow;");

			
		// }
		// else{
		// 	mexPrintf("Done!\n");
		// 	break;
		// }
	}
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){

	double *graphLoc = mxGetPr(prhs[0]);
	mwSize mrows = mxGetM(prhs[0]);
    mwSize ncols = mxGetN(prhs[0]); 

	N = (int)*mxGetPr(prhs[1]);
	startU = (int)*mxGetPr(prhs[2]);
	endU = (int)*mxGetPr(prhs[3]);
	finalMatch = (int)*mxGetPr(prhs[4]);

	mexPrintf("Importing graph from Matlab...\n");

	// Adding nodes and setting up the bipartition.  
	for(int i = 0; i <= N; i++){
		G.addNode();
		if(i >= startU && i <= endU){
			bipartition[G.nodeFromId(i)] = 1;
		}
		else{
			bipartition[G.nodeFromId(i)] = 0;
		}

		M.addNode();
	}

	// Adding edges to the graph. 
	for(int n = 0; n < ncols; n++){
		ListGraph::Edge label = G.addEdge(G.nodeFromId(graphLoc[n*(mrows)]), G.nodeFromId(graphLoc[n*(mrows) + 1]));
		weight.set(label, graphLoc[n*(mrows) + 2]);
	}

mexPrintf("Starting predictor-corrector algorithm.\n");

vector<vector<int> > Paths_arr;

predictorCorrector(G, M, Paths_arr, finalMatch);

mexPrintf("Processing data to return to MATLAB...\n");

// Want to return matching in the form (W, U)
// int output_rows = countEdges(M);

// plhs[0] = mxCreatempf_classMatrix(2, output_rows, mxREAL);
// mpf_class *outputMatrix = mxGetPr(plhs[0]);

// // REMEMBER TO TAKE TRANSPOSE OF THIS MATRIX IN MATLAB
// for(ListGraph::EdgeIt i(M); i!=INVALID; ++i){
// 	int col = M.id(i) - 1;
// 	int u = M.id(M.u(i));
// 	int v = M.id(M.v(i));

// 	if(bipartition[G.nodeFromId(u)] == 0){ // so the u node is in W, add (u,v)
// 		outputMatrix[col*2] = u;
//     	outputMatrix[1 + col*2] = v;
// 	}
// 	else{ // so the v node is in W, and add (v, u)
// 		outputMatrix[col*2] = v;
//     	outputMatrix[1 + col*2] = u;
// 	}
// }

/*

Now have to return Paths_arr, which is a vector<vector<int>>	

The original plan was to directly return it to Matlab as a plhs, 
but Matlab keeps crashing. I suspect this is because the array is 
pretty massive and there isn't enough space on the heap (especially
if working with say a 500x500 image).

So instead I'll write to a .txt file and import that from Matlab, 
might be a bit slower, but at least will guarantee that we won't run
into memory issues. 

I have commented out the broken code for future reference/if I ever
decide to edit it. 

*/

// int m = Paths_arr.size();

// auto it = std::max_element(Paths_arr.begin(), Paths_arr.end(), longest);
// int n = it->size();

// plhs[1] = mxCreatempf_classMatrix(m, n, mxREAL);
// mpf_class *paths = mxGetPr(plhs[1]);

// for(int i = 0; i < m; i++){

// 	vector<int> curr_path = Paths_arr.at(i);
// 	int length_curr_path = curr_path.size();

// 	for(int j = 0; j < n; j++){
// 		// col*rowlen + row
// 		if(j >= length_curr_path){
// 			paths[i*m + j] = 0;
// 		}
// 		else{
// 			paths[i*m + j] = curr_path.at(j);
// 		}
// 	}
// }

fstream output_file_1("matching.txt");
for(ListGraph::EdgeIt e(M); e!=INVALID; ++e){
	// if (i < startU || i > endU){	// want it of format (w, u) in increasing order
	// 	for (ListGraph::IncEdgeIt e(M, M.nodeFromId(i)); e != INVALID; ++e){
	// 		output_file_1 << i << "," << M.id(M.oppositeNode(M.nodeFromId(i), e)) << endl;
	// 	}
	// }					

	int u = M.id(M.u(e));
	int v = M.id(M.v(e));

	if(u < v){ // so the u node is in W, add (u,v)
		output_file_1 << u << "," << v << endl;
	}
	else{ // so the v node is in W, and add (v, u)
		output_file_1 << v << "," << u << endl;
	}
}

fstream output_file_2("paths.txt");
ostream_iterator<int> output_iterator(output_file_2, "\t");
for (int i = 0; i < Paths_arr.size(); i++){
	copy(Paths_arr.at(i).begin(), Paths_arr.at(i).end(), output_iterator);
	output_file_2 << "\n" ;
}

G.clear(); M.clear();
output_file_1.close(); output_file_2.close();

return;
}
