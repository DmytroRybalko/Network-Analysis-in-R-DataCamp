## == Finding Dyads and Triads
# Let's think a little bit more about what we can learn from dyad and triad censuses of the overall graph. Because we are interested in understanding how items are purchased together and whether or not they are reciprocally purchased, dyad and triad censuses can provide a useful initial look. A dyad census will tell us how many items are purchased reciprocally vs. asymmetrically. The triad census will tell us which items might be important, specifically patterns 4, 9, and 12. All of these have one vertex that has 2 out degree edges and no in degree edges. Edge density should also give some insight we expect for graph clustering.

# The Amazon co-purchase graph, amzn_g, is available.

# The graph, amzn_g, is available
amzn_g

# Perform dyad census
dyad_census(amzn_g)

# The dyad census shows us there were 3199 mutual connections, meaning items were bought together.

# Perform triad census
triad_census(amzn_g)

# Find the edge density
edge_density(amzn_g)

## == Clustering and Reciprocity
# Our previous work looking at the dyad census should give some intuition about how we expect other graph level metrics like reciprocity and clustering in our co-purchase graph to look. Recall that there are 10,754 edges in our graph of 10,245 vertices, and of those, more than 3,000 are mutual, meaning that almost 60 percent of the vertices have a mutual connection. What do you expect the clustering and reciprocity measures to look like given this information? We can test our intuition against a null model by simulating random graphs. In light of the results of our previous simulation, what do you expect to see here? Will reciprocity also be much higher than expected by chance?

# Calculate reciprocity
actual_recip <- reciprocity(amzn_g)

# Calculate the order
n_nodes <- gorder(amzn_g)

# Calculate the edge density
edge_dens <- edge_density(amzn_g)

# Run the simulation
simulated_recip <- rep(NA, 1000)
for(i in 1:1000) {
  # Generate an Erdos-Renyi simulated graph
  simulated_graph <- erdos.renyi.game(n_nodes, edge_dens, directed = TRUE)
  # Calculate the reciprocity of the simulated graph
  simulated_recip[i] <- reciprocity(simulated_graph)
}

# Compare the simulated reciprocity to the value from the original graph.
# Reciprocity of the original graph
actual_recip

# Calculate quantile of simulated reciprocity
quantile(simulated_recip , c(0.025, 0.5, 0.975))

# Weirdly though, notice how the reciprocity of the simulations is much lower than the reciprociy of the original graph
 
# Important Products
# We've now seen that there's a clear pattern in our graph. Let's take the next step and move beyond just understanding the structure. Given the context of graph structure, what can we learn from it? For example, what drives purchases? A place to start might be to look for "important products", e.g. those products that someone purchases and then purchases something else. We can make inferences about this using in degree and out degree. First, we'll look at our graph and see the distribution of in degree and out degree, and then use that to set up a working definition for what an "important product" is (something that has > X out degrees and < Z in degrees). We'll then make a subgraph to visualize what these subgraphs look like.

# Calculate the "out" degrees
out_degree <- degree(amzn_g, mode = "out")

## ... and "in" degrees
in_degree <- degree(amzn_g, mode = "in")

# See the distribution of out_degree
table(out_degree)

## ... and of in_degree
table(in_degree)

## ==Visualizing edges
## In this exercise you will learn how to change the size of edges in a network based on their weight, as well as how to remove edges from a network which can sometimes be helpful in more effectively visualizing large and highly clustered networks. In this introductory chapter, we have just scratched the surface of what's possible in visualizing igraph networks. You will continue to develop these skills in future chapters.
## 
# Create condition of out degree greater than 3
# and in degree less than 3
is_important <- out_degree > 3 & in_degree < 3

# Subset vertices by is_important
imp_prod <- V(amzn_g)[is_important]

# Output the vertices
print(imp_prod)

## == What Makes an Important Product?
# Now that we've come up with a working definition of an important product, let's see if they have any properties that might be correlated. One candidate pairing is salesrank.from and salesrank.to. We can ask if important products tend to have higher sales ranks than the products people purchase downstream. We'll look at this by first subsetting out the important vertices, joining those back to the initial dataframe, and then creating a new dataframe using the package dplyr. We'll create a new graph, and color the edges blue for high ranking (1, 2, 3) to low ranking (20, 21, 22) and red for the opposite. If rank is correlated with downstream purchasing, then we'll see mostly blue links, and if there's no relationship, it will be about equally red and blue.

# The dataset ip_df contains the information about important products.
# Select the from and to columns from ip_df
ip_df_from_to <- ip_df[c('from','to')]

# Create a directed graph from the data frame
ip_g <- graph_from_data_frame(ip_df_from_to, directed = TRUE)

# Set the edge color. If salesrank.from is less than or 
# equal to salesrank.to then blue else red.
edge_color <- ifelse(
  ip_df$salesrank.from <= ip_df$salesrank.to, 
  yes = "blue", 
  no = "red"
)
plot(
  # Plot a graph of ip_g
  ip_g, 
  # Set the edge color
  edge.color = edge_color,
  edge.arrow.width = 1, edge.arrow.size = 0, edge.width = 4, 
  vertex.label = NA, vertex.size = 4, vertex.color = "black"
)
legend(
  "bottomleft", 
  # Set the edge color using edge_color
  fill = unique(edge_color), 
  legend = c("Lower to Higher Rank", "Higher to Lower Rank"), cex = 0.7
)

# Result: You can see that sales rank is correlated with product importance.

## == Metrics through time
# So far, we have been looking at products that drive other purchases by examining their out degree. However, up until the last lesson we've just been looking at a single snapshot in time. One question is, do these products show similar out degrees at each time step? After all, a product driving other purchases could just be idiosyncratic, or it if were more stable through time it might indicate that product could be responsible for driving co-purchases. To get at this question, we're going to build off the code we've already walked through that generates a list with a graph at each time step.

# Loop over time graphs calculating out degree
degree_count_list <- lapply(time_graph, degree, mode = "out")

# Flatten it
degree_count_flat <- unlist(degree_count_list)

degree_data <- data.frame(
  # Use the flattened counts
  degree_count = degree_count_flat,
  # Use the names of the flattened counts
  vertex_name = names(degree_count_flat),
  # Repeat the dates by the lengths of the count list
  date = rep(d, lengths(degree_count_list))
)

important_vertices <- c(1629, 132757, 117841)

important_degree_data <- degree_data %>% 
  # Filter for rows where vertex_name is
  # in the set of important vertices
  filter(vertex_name %in% important_vertices)

# Using important_degree_data, plot degree_count vs. date, colored by vertex_name 
ggplot(important_degree_data, aes(x = date, y = degree_count, color = vertex_name)) + 
  # Add a path layer
  geom_path()

# Result: Transcendent temporal analysis! Only one product, 132757, has a consistently high out degree, indicating it may be consistently driving secondary transactions. The other two might just be having high out degree by chance.

## == Plotting Metrics Over Time
# We can also examine how metrics for the overall graph change (or don't) through time. Earlier we looked at two important ones, clustering and reciprocity. Each were quite high, as we expected after visually inspecting the graph structure. However, over time, each of these might change. Are global purchasing patterns on Amazon stable? If we think so, then we expect plots of these metrics to essentially be horizontal lines, indicating that reciprocity is about the same every day and there's a high degree of clustering structure. Let's see what we can find here.

# Code to calculate the transitivity by graph is shown.
# Examine this code
transitivity_by_graph <- data.frame(
  date = d,
  metric = "transitivity",
  score = sapply(all_graphs, transitivity)
)

# Calculate reciprocity by graph
reciprocity_by_graph <- data.frame(
  date = d,
  metric = "reciprocity",
  score = sapply(all_graphs, reciprocity))

# Bind these two datasets by row
metrics_by_graph <- bind_rows(transitivity_by_graph, reciprocity_by_graph)

# See the result
metrics_by_graph

# Using metrics_by_graph, plot score  vs. date, colored by metric
ggplot(metrics_by_graph, aes(x = date, y = score, color = metric)) +
  # Add a path layer with geom_path()
  geom_path()

# Result:
# Marvelous metric plotting! Reciprocity was fairly stable over time. Transitivity decreased after the first time point. This supports the idea that co-purchase networks are relatively stable over this time window