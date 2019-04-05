Rcpp::sourceCpp('graph_fns.cpp')
source('graph_fns.R')


g <- dag(vertexCount = 0)
n = 30
for(i in 1:n){
  g$newVertex(description = i %>% as.character())
}
s<- function(n) { sample(1:n, n)}
fs<- c(s(n), s(n)); ts <- c(s(n), s(n));
for(i in 1:length(fs)){
  g$createTransition(from =g$vertices[[fs[i]]], 
                     to = g$vertices[[ts[i]]],
                     weight = rnorm(1), 
                     'random edge') 
}

#g$plot()
#g$plot_heirarchy()
fileprefix = ""
if(!file.exists('classic_bst_nodes.csv')){
  fileprefix = '../'
}

nodes<- read.csv('classic_bst_nodes.csv')
for(i in 1:nrow(nodes)){
  nodes$description[i] <- paste0(sample(x = letters, size = 5), collapse = '')
}
nodes$description[1] <- "Determine Topic"
write.csv(x = nodes,file = 'classic_bst_nodes.csv',row.names = F)

g<- dag()
g$load_from_file(paste0(fileprefix,'classic_bst'))
dest<- paste0(getwd(), '/presentation/')
g$plot() %>% visSave(file = paste0(dest,'bst_no_heirarchy.html'), background = 'transparent')
g$plot_heirarchy() %>% visSave(file = paste0(dest,'bst_heirarchy.html'), background = 'transparent')
g$plot_heirarchy(colorRootLeaves = T) %>% visSave(file = paste0(dest,'bst_heirarchy_color.html'), background = 'transparent')
g$plot(colorRootLeaves = T)  %>% visSave(file = paste0(dest,'bst_no_heirarchy_color.html'), background = 'transparent')
g$plot_heirarchy(colorRootLeaves = T, turn = T) %>% visSave(file = paste0(dest,'bst_heirarchy_color_turn.html'), background = 'transparent')


g$close_graph()
g$plot_heirarchy(colorRootLeaves = T, turn = T)%>% visSave(file = paste0(dest,'proj_man_dag.html'), background = 'transparent')

g$plot_heirarchy(colorRootLeaves = T, turn = T, g$shortest_path(g$root_nodes(),
                                                                g$leaf_nodes())) %>% 
  visSave(file = paste0(dest,'proj_man_dag_sp.html'), background = 'transparent')


g$plot_heirarchy(colorRootLeaves = T, turn = T, g$critical_path(g$root_nodes(),
                                                                g$leaf_nodes())) %>% 
  visSave(file = paste0(dest,'proj_man_dag_cp.html'), background = 'transparent')

g$plot(colorRootLeaves = T, path_highlight =  g$shortest_path(g$root_nodes(), g$leaf_nodes())) %>% 
  visSave(file = paste0(dest,'proj_man_dag_sp_free.html'), background = 'transparent')

g$plot(colorRootLeaves = T, path_highlight =  g$critical_path(g$root_nodes(), g$leaf_nodes())) %>% 
  visSave(file = paste0(dest,'proj_man_dag_cp_free.html'), background = 'transparent')


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