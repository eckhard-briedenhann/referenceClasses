// assumes you have the boost libraries installed. 
// see https://www.boost.org/ for the source. 

// [[Rcpp::plugins(cpp14)]]                                        
// note: this line above enables the c14 compiler which is required for the specific syntax of that version of cpp
#include <Rcpp.h>
#include <iostream>
#include <deque>
#include <iterator>

#include "boost/graph/adjacency_list.hpp"
#include "boost/graph/topological_sort.hpp"
#include "boost/graph/dijkstra_shortest_paths.hpp"
using namespace Rcpp;


// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//



typedef boost::property<boost::edge_weight_t, int> EdgeWeightProperty;
typedef boost::adjacency_list<boost::listS, boost::vecS, boost::directedS, boost::no_property, EdgeWeightProperty > DirectedGraph;
typedef boost::graph_traits<DirectedGraph>::edge_iterator edge_iterator;


// [[Rcpp::export]]
NumericVector boost_sample_2(){
  DirectedGraph* g = new DirectedGraph();
  boost::add_edge (0, 1, 8, *g);
  boost::add_edge (0, 3, 18, *g);
  std::pair<edge_iterator, edge_iterator> ei = edges(*g);
  std::cout << "Number of edges = " << num_edges(*g) << "\n";
  std::cout << "Edge list:\n";
  
  std::copy( ei.first, ei.second,
             std::ostream_iterator<boost::adjacency_list<>::edge_descriptor>{
               std::cout, "\n"});
  
  std::cout << std::endl;
  return 0;
}

// [[Rcpp::export]]
std::vector<int> get_untouched_nodes(NumericVector e_start, int num_nodes){
  std::vector<bool> isleaf(num_nodes, true);
  std::vector<int> s = Rcpp::as<std::vector<int>>(e_start);
  for(int i =0; i < s.size(); i++){
    isleaf[s[i]] = false;
  }
  std::vector<int> leaf_indexes;
  for(int i = 0; i < isleaf.size(); i++){
    if(isleaf[i]){
      leaf_indexes.push_back(i + 1); // +1 because R is using 1-based indexing
    }
  }
  return leaf_indexes;
}



// [[Rcpp::export]]
NumericVector shortest_path_a_b(int a, int b, NumericVector froms, NumericVector tos, NumericVector weights){
  // DirectedGraph g;
  // 
  // dijkstra_shortest_paths(g, s, predecessor_map(&p[0]).distance_map(&d[0]));
  
}

// [[Rcpp::export]]
NumericVector boost_sample(){
  DirectedGraph g;
  
  boost::add_edge (0, 1, 8, g);
  boost::add_edge (0, 3, 18, g);
  boost::add_edge (1, 2, 20, g);
  boost::add_edge (2, 3, 2, g);
  boost::add_edge (3, 1, 1, g);
  boost::add_edge (1, 3, 7, g);
  boost::add_edge (1, 4, 1, g);
  boost::add_edge (4, 5, 6, g);
  boost::add_edge (2, 5, 7, g);
  
  std::pair<edge_iterator, edge_iterator> ei = edges(g);
  
  std::cout << "Number of edges = " << num_edges(g) << "\n";
  std::cout << "Edge list:\n";

  std::copy( ei.first, ei.second,
             std::ostream_iterator<boost::adjacency_list<>::edge_descriptor>{
               std::cout, "\n"});

  std::cout << std::endl;
  
  return 0;
}

// [[Rcpp::export]]
NumericVector timesTwo(NumericVector x) {
  return x * 2;
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//


// timesTwo(42)
// boost_sample()
// boost_sample_2();

