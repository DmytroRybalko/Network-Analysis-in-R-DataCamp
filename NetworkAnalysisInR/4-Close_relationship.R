## == Assortativity
# In this exercise you will determine the assortativity() of the second friendship network from the first chapter. This is a measure of how preferentially attached vertices are to other vertices with identical attributes. You will also determine the degree assortativity which determines how preferentially attached are vertices to other vertices of a similar degree.

# Plot the network
plot(g1)

# Convert the gender attribute into a numeric value
values <- as.numeric(factor(V(g1)$gender))

# Calculate the assortativity of the network based on gender
assortativity(g1, values)

# Calculate the assortativity degree of the network
assortativity.degree(g1, directed = FALSE)

## == Using randomizations to assess assortativity
# In this exercise you will determine how likely the observed assortativity in the friendship network is given the genders of vertices by performing a randomization procedure. You will randomly permute the gender of vertices in the network 1000 times and recalculate the assortativity for each random network.

# Calculate the observed assortativity
observed.assortativity <- assortativity(g1, values)

# Calculate the assortativity of the network randomizing the gender attribute 1000 times
# Inside the for loop calculate the assortativity of the network g1 using assortativity() while randomly permuting the object values each time with sample().
results <- vector('list', 1000)
for(i in 1:1000){
  results[[i]] <- assortativity(g1, sample(values))
}

# Plot the distribution of assortativity values and add a red vertical line at the original observed value
hist(unlist(results))
abline(v = observed.assortativity, col = "red", lty = 3, lwd=2)

## == Reciprocity
# The reciprocity of a directed network reflects the proportion of edges that are symmetrical. That is, the proportion of outgoing edges that also have an incoming edge. It is commonly used to determine how inter-connected directed networks are. An example of a such a network may be grooming exchanges in chimpanzees. Certain chimps may groom another but do not get groomed by that individual, whereas other chimps may both groom each other and so would have a reciprocal tie.

# Make a plot of the chimp grooming network
plot(g,
     edge.color = "black",
     edge.arrow.size = 0.3,
     edge.arrow.width = 0.5)

# Calculate the reciprocity of the graph
reciprocity(g)

## == Fast-greedy community detection
# The first community detection method you will try is fast-greedy community detection. You will use the Zachary Karate Club network. This social network contains 34 club members and 78 edges. Each edge indicates that those two club members interacted outside the karate club as well as at the club. Using this network you will determine how many sub-communities the network has and which club members belong to which subgroups. You will also plot the networks by community membership.

# Perform fast-greedy community detection on network graph
kc = fastgreedy.community(g)

# Determine sizes of each community
sizes(kc)

# Determine which individuals belong to which community
membership(kc)

# Plot the community structure of the network
plot(kc, g)

## == Edge-betweenness community detection
# An alternative community detection method is edge-betweenness. In this exercise you will repeat the community detection of the karate club using this method and compare the results visually to the fast-greedy method.
# Perform edge-betweenness community detection on network graph
gc = edge.betweenness.community(g)

# Determine sizes of each community
sizes(gc)

# Plot community networks determined by fast-greedy and edge-betweenness methods side-by-side
par(mfrow = c(1, 2)) 
plot(kc, g)
plot(gc, g)


## == Interactive networks with threejs
# In this course you have exclusively used igraph to make basic static network plots. There are many packages available to make network plots. One very useful one is threejs which allows you to make interactive network visualizations. This package also integrates seamlessly with igraph. In this exercise you will make a basic interactive network plot of the karate club network using the threejs package. Once you have produced the visualization be sure to move the network around with your mouse. You should be able to scroll in and out of the network as well as rotate the network.

library(igraph)
library(threejs)

# Set a vertex attribute called 'color' to 'dodgerblue' 
g <- set_vertex_attr(g, "color", value = "dodgerblue")

# Redraw the graph and make the vertex size 1
graphjs(g, vertex.size = 1)


## == Sizing vertices in threejs
# As with all network visualizations it is often worth adjusting the size of vertices to illustrate their relative importance. This is also straightforward in threejs. In this exercise you will create an interactive threejs plot of the karate club network and size vertices based on their relative eigenvector centrality.

# Create numerical vector of vertex eigenvector centralities 
ec <- as.numeric(eigen_centrality(g)$vector)

# Create new vector 'v' that is equal to the square-root of 'ec' multiplied by 5
v <- 5*sqrt(ec)

# Plot threejs plot of graph setting vertex size to v
graphjs(g, vertex.size = v)

## == 3D community network graph
# Finally in this exercise you will create an interactive threejs plot with the vertices based on their community membership as produced by the fast-greedy community detection method.

# Create an object 'i' containin the memberships of the fast-greedy community detection
i <-  membership(kc)

# Check the number of different communities
sizes(kc)

# Add a color attribute to each vertex, setting the vertex color based on community membership
g <- set_vertex_attr(g, "color", value = c("yellow", "blue", "red")[i])

# Plot the graph using threejs
graphjs(g)
