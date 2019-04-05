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
                                             description = "character", 
                                             level = "numeric"), 
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
                    initialize=function(...) {
                      .self$initFields(vertexCount=0, ...)
                    },
                    newVertex = function(description, level = -1){
                      v <- state(id = vertexCount, description = description, level = level)
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
                    plot = function(height = 1080, width = 1920, colorRootLeaves = F, path_highlight = NULL){
                      if(edges %>% length > 0){
                        fs <- lapply(edges, function(i){ return(i$from$id)} ) %>% unlist
                        ts <- lapply(edges, function(i){ return(i$to$id)} ) %>% unlist
                        edgemat<- data.frame(from = fs,
                                             to = ts,
                                             arrows =  "middle",
                                             weight = lapply(edges, function(i){ return(i$weight)} ) %>% unlist )
                        edgemat %<>% mutate(key = paste0(from, "-", to))
                        
                        if(length(path_highlight) > 1){
                          p<- data.frame(from = path_highlight[1:(length(path_highlight)-1)],
                                         to = path_highlight[2:length(path_highlight)])
                          p %<>% mutate(key = paste0(from,"-",to))
                          edgemat$color<-'#97C2FC'
                          edgemat$color[edgemat$key %in% p$key] <- '#000000'
                          edgemat$width<-1
                          edgemat$width[edgemat$key %in% p$key] <- 3
                          
                        }
                      }else{
                        edgemat <- NULL
                      }
                      nodemat <- data.frame(
                        id = lapply(vertices, function(i){return(i$id)}) %>% unlist,
                        label = lapply(vertices, function(i){return(i$description)}) %>% unlist,
                        level = lapply(vertices, function(i){return(i$level)}) %>% unlist)
                      if(colorRootLeaves){
                        nodemat$color <- '#97C2FC'
                        nodemat$color[leaf_nodes()] <- '#AA3939' #red
                        nodemat$color[root_nodes()] <- '#2D8633' #green
                        nodemat$color.border <- '#2B7CE9' #green
                        nodemat$borderWidth <- 1
                      }
                      if(length(path_highlight) > 1){
                        #may as well paint the borders of these nodes in black
                        nodemat$color.border[nodemat$id %in% path_highlight] <- '#000000'
                        nodemat$borderWidth[nodemat$id %in% path_highlight]<- 3
                      }
                      return (visNetwork(nodemat, edgemat, height = height, width = width))
                    },
                    plot_heirarchy = function(colorRootLeaves = F, turn = F, path_highlight = NULL){
                      direction = NULL
                      if(turn){
                        direction <- 'lr'
                      }
                      return (plot(colorRootLeaves = colorRootLeaves, path_highlight = path_highlight) %>% 
                                visHierarchicalLayout(direction = direction))
                    },
                    load_from_file = function(fileprefix){
                      E<- read.csv(paste0(fileprefix, '_edges.csv'))
                      N<- read.csv(paste0(fileprefix, '_nodes.csv'))
                      for(i in 1:nrow(N)){
                        newVertex(description = N$description[i] %>% as.character(), N$level[i])
                      }
                      for(i in 1:nrow(E)){
                        createTransition(from = g$vertices[[E$from[i]+1]], 
                                         to = g$vertices[[E$to[i]+1]], 
                                         weight = E$weight[i], 
                                         description = E$description[i] %>% as.character())
                      }
                    },
                    leaf_nodes= function(){
                      get_untouched_nodes(e_start = lapply(edges, function(i){ return(i$from$id)} ) %>% unlist, 
                                    num_nodes = vertexCount)
                    },
                    root_nodes= function(){
                      get_untouched_nodes(e_start = lapply(edges, function(i){ return(i$to$id)} ) %>% unlist, 
                                     num_nodes = vertexCount)
                    },
                    close_graph = function(){
                      #find all leaf nodes, connect them to the a new dummy node which closes the graph.
                      leaves<- leaf_nodes()
                      if(leaves %>% length > 0){
                        last_level<- lapply(leaves, function(i){ return(vertices[[i]]$level)} ) %>% unlist %>% max()
                        end_node <- newVertex(description = "Present at\nSatRday", level = last_level + 1)
                        for(i in leaves){
                          createTransition(from = vertices[[i]], to = end_node, weight = 0, "")
                        }
                      }
                    },
                    shortest_path = function(from, to){
                      fs <- lapply(g$edges, function(i){ return(i$from$id)} ) %>% unlist
                      ts <- lapply(g$edges, function(i){ return(i$to$id)} ) %>% unlist
                      edgemat<- data.frame(from = fs,
                                           to = ts,
                                           arrows =  "middle",
                                           weight = lapply(g$edges, function(i){ return(i$weight)} ) %>% unlist )
                      edgemat$weight <- (edgemat$weight - (edgemat$weight %>% min()))*10
                      
                      path<- shortest_path_a_b(from - 1, to - 1, edgemat$from, edgemat$to, weights = edgemat$weight, num_nodes =g$vertexCount)
                      return(path)
                    },
                    critical_path = function(from, to){
                      fs <- lapply(g$edges, function(i){ return(i$from$id)} ) %>% unlist
                      ts <- lapply(g$edges, function(i){ return(i$to$id)} ) %>% unlist
                      edgemat<- data.frame(from = fs,
                                           to = ts,
                                           arrows =  "middle",
                                           weight = lapply(g$edges, function(i){ return(i$weight)} ) %>% unlist )
                      edgemat$weight <- (edgemat$weight - (edgemat$weight %>% min()))*10
                      #a critical path is the longest path from a-b, which is the same as the inverted edge weights in the potivie domain
                      m<- edgemat$weight %>% max()
                      edgemat$weight <- m - edgemat$weight
                      path<- shortest_path_a_b(from - 1, to - 1, edgemat$from, edgemat$to, weights = edgemat$weight, num_nodes =g$vertexCount)
                      return(path)
                    }
                  ))






