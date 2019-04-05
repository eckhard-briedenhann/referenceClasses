// assumes you have the boost libraries installed.
// see https://www.boost.org/ for the source.

// [[Rcpp::plugins(cpp14)]]
// note: this line above enables the c14 compiler which is required for the
// specific syntax of that version of cpp
#include <Rcpp.h>
#include <boost/config.hpp>
#include <deque>
#include <iostream>
#include <iterator>

#include <boost/graph/graph_traits.hpp>
#include "boost/graph/adjacency_list.hpp"
#include "boost/graph/dijkstra_shortest_paths.hpp"
#include "boost/graph/topological_sort.hpp"

using namespace Rcpp;
using namespace boost;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

typedef property<edge_weight_t, int> EdgeWeightProperty;
typedef std::pair<int, int> Edge;
typedef adjacency_list<listS, vecS, directedS, no_property, EdgeWeightProperty>
    DirectedGraph;
typedef graph_traits<DirectedGraph>::edge_descriptor edge_descriptor;
typedef graph_traits<DirectedGraph>::vertex_descriptor vertex_descriptor;


// [[Rcpp::export]]
std::vector<int> get_untouched_nodes(NumericVector e_start, int num_nodes) {
  std::vector<bool> isleaf(num_nodes, true);
  std::vector<int> s = Rcpp::as<std::vector<int>>(e_start);
  for (int i = 0; i < s.size(); i++) {
    isleaf[s[i]] = false;
  }
  std::vector<int> leaf_indexes;
  for (int i = 0; i < isleaf.size(); i++) {
    if (isleaf[i]) {
      leaf_indexes.push_back(i + 1);  // +1 because R is using 1-based indexing
    }
  }
  return leaf_indexes;
}

// [[Rcpp::export]]
std::vector<int> shortest_path_a_b(int a, int b, NumericVector froms,
                                NumericVector tos, NumericVector weights,
                                int num_nodes) {
  std::vector<int> FV = Rcpp::as<std::vector<int>>(froms);
  std::vector<int> TV = Rcpp::as<std::vector<int>>(tos);
  std::vector<double> w = Rcpp::as<std::vector<double>>(weights);
  
  Edge edge_array[FV.size()];
  int W[FV.size()];

  for (int i = 0; i < FV.size(); i++) {
    edge_array[i] = Edge(FV[i], TV[i]);
    W[i] = weights[i];
  }
  int num_arcs = sizeof(edge_array) / sizeof(Edge);
   DirectedGraph g(edge_array, edge_array + num_arcs, W, num_nodes);

  property_map<DirectedGraph, edge_weight_t>::type weightmap = get(edge_weight, g);
  std::vector<vertex_descriptor> p(num_vertices(g));
  std::vector<int> d(num_vertices(g));
  vertex_descriptor s = vertex(a, g);

  dijkstra_shortest_paths(g, s, predecessor_map(&p[0]).distance_map(&d[0]));
  
  // std::cout << "distances and parents:" << std::endl;
  // graph_traits < DirectedGraph >::vertex_iterator vi, vend;
  // for (tie(vi, vend) = vertices(g); vi != vend; ++vi) {
  //   std::cout << "distance(" << std::to_string(*vi) << ") = " << d[*vi] << ", ";
  //   std::cout << "parent(" << std::to_string(*vi) << ") = " << std::to_string(p[*vi]) << std::
  //     endl;
  // }
  // std::cout << std::endl;
  std::vector<int> path;
  vertex_descriptor goal = vertex(b, g);
  vertex_descriptor current = goal;
  
  while(current != s) 
  {
    path.push_back(current);
    current = p[current];
  }
  path.push_back(s);
  std::reverse(path.begin(), path.end());
  
  return path;
}
