library(visNetwork)
library(dplyr)
library(purrr)
library(magrittr)
#if(file.exists('graph_fns.cpp')){
  #Rcpp::sourceCpp('graph_fns.cpp')  
#}else{
  #Rcpp::sourceCpp('../graph_fns.cpp')  
#}
# ref class for edge
state <- setRefClass("vertex", fields = list(id = "numeric", 
                                             description = "character"), 
                     methods = list(
                       show = function(){
                          cat("State\nDescription:", description, "\nID:",id,"\n")
                       }
                     ))

transition <- setRefClass("edge", fields = list(from = "vertex", 
                                                to = "vertex", 
                                                weight = "numeric", 
                                                description ="character"),
                          methods = list(
                            show = function(){
                              cat("Edge\nDescription:",description,"\nWeight:", weight, "\nFrom:\n")
                              from$show()
                              cat("To:\n")
                              to$show()
                            })
)

adjList <- setRefClass("adjList", fields = list(adjs = "list"),
                         methods = list(
                           addEdge = function(e){
                             if(!("edge" %in% class(e))){
                               stop("Cannot add non edge class to adjacency list")
                             }
                             vName <- paste0("v",e$from$id)
                             adjs[[vName]] <<- c(adjs[[vName]],e$to$id)
                             #cat("Edge Added")
                           },
                           show = function(){
                             vNames <- names(adjs)
                             for(vN in vNames){
                              cat("Vertex:",vN,"\n")
                              cat("Adjs:",adjs[[vN]],"\n")
                             }
                           }
                         )
                       )

dag <- setRefClass("dag", fields = list(vertices = "list",
                                        edges = "list",
                                        adjList = "adjList",
                                        vertexCount = "numeric"),
                  methods = list(
                    newVertex = function(description){
                      v <- state(id = vertexCount, description = description )
                      vertexCount <<- vertexCount + 1
                      vertices <<- c(vertices,v)
                      return(v)
                    },
                    createTransition = function(from, to, weight, description){
                      e <- transition(from = from, to = to, weight= weight, description = description)
                      edges <<- c(edges,e)
                      adjList$addEdge(e)
                      
                      return(e)
                    },
                    # testMe = function(){
                    #   boost_sample()
                    # },
                    plot = function(height = 1080, width = 1920){
                      if(edges %>% length > 0){
                        edgemat<- data.frame( 
                                              from = lapply(edges, function(i){ return(i$from$id)} ) %>% unlist,
                                              to = lapply(edges, function(i){ return(i$to$id)} ) %>% unlist,
                                              arrows =  "middle",
                                              weight = lapply(edges, function(i){ return(i$weight)} ) %>% unlist
                                            )
                      }else{
                        edgemat <- NULL
                      }
                      nodemat <- data.frame(
                        id = lapply(vertices, function(i){return(i$id)}) %>% unlist,
                        label = lapply(vertices, function(i){return(i$description)}) %>% unlist) 
                      
                      return (visNetwork(nodemat, edgemat, height = height, width = width))
                    },
                    plot_heirarchy = function(){
                      return (plot() %>% visHierarchicalLayout())
                    }
                  ))



# g <- dag(vertexCount = 0)
# node_a <- g$newVertex(description = "A")
# g$plot(height = 200,width = 500)
# node_b <- g$newVertex(description = "B")
# g$plot(height = 200,width = 500) %>% visPhysics(enabled = FALSE) 
# # disable the physics engine so that we can create some static charts.
# getDressedA <- g$createTransition(from = node_a, to = node_b, weight = 1, description = "Step 1")
# g$plot(height = 200,width = 500) %>% visPhysics(enabled = FALSE) 
# 
# node_c <- g$newVertex(description = "C")
# g$plot(height = 200,width = 500) %>% visPhysics(enabled = FALSE) 
# 
# getDressedB <- g$createTransition(from = node_b, to = node_c, weight = 0.5, description = "Step 2")
# g$plot(height = 200,width = 500) %>% visPhysics(enabled = FALSE) 

#getDressedCA <- g$createTransition(from = node_c, to = node_a, weight = 1, description = "Step 3")
#g$plot(height = 200,width = 500) %>% visPhysics(enabled = FALSE) 

# getDressedAC <- g$createTransition(from = node_a, to = node_c, weight = 1, description = "Step 3")
# g$plot(height = 200,width = 500) %>% visPhysics(enabled = FALSE) 

# g$plot() %>% visExport(type = 'png', name = 'dag_simple')  
# 
# visSave(g$plot(), 'dag_simple.html' , background = "white")

