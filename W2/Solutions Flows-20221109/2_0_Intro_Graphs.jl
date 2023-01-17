using Graphs, GraphPlot

# # Undirected Graphs
adjacency = [
    0 1 1
    1 0 1
    1 1 0
]
g = Graph(adjacency)
gplot(g)

# properties
adjacency_matrix(g)
nv(g) # number of vertices
ne(g) # number of edges
degree(g)[1] # degree of node
neighbors(g,1) # neighbors
edges_g = collect(edges(g)) # all edges
vertices_g = collect(vertices(g)) # all vertices
[(src(e), dst(e)) for e in edges(g)] # get edge list as tuples
src(edges_g[1])
dst(edges_g[2])


# # Directed Graphs
elist = [(2,1), (2,3), (3,1)] 
g_directed = DiGraph(Edge.(elist)) # Edge: Constructor
gplot(g_directed)

# properties
degree(g_directed)[1]
neighbors(g_directed,1)
inneighbors(g_directed,1)
outneighbors(g_directed,1)
edges_g_directed = collect(edges(g_directed)) # print all edges
vertices_g_directed = collect(vertices(g_directed)) # print all vertices
[(src(e), dst(e)) for e in edges(g_directed)] # get edge list as tuples
src(edges_g_directed[1])
dst(edges_g_directed[2])