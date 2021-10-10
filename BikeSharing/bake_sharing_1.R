## INTRO
# 1. Exploring our data
# By now you've seen that graph data rarely comes in a form that we can work with right "out of the box". In this chapter we'll be working with a dataset from the Chicago Divvy bike sharing network. To start with we'll look at a subset of data that they make freely available. We'll cover how we go from raw data to an igraph object and the decisions about calculating graph properties like edge weights.

#2. Bike data frame
#Let's start by looking at the fields in the data set. Each row is an individual trip. It has to and from station id, name, and lat / lon. There's also some metadata about each trip including how long the trip was in seconds, usertype, gender, age, and distance in meters between stations. All we'll need to create our graph is the to and from station ids, but all that metadata will be useful in later lessons because it will allow us to compare graphs of different groups of bike network users. Let's start with creating our basic graph.

#3. Creating the bike sharing graph
#The first thing we'll do is group our data by from and to station id's. Then we need to consider what we want to use for edge weights. There are a variety things we could use. There's trip duration, so we could do average trip time, or percent of user type. Another intuitive feature to use as an edge weight is the number of trips between stations. That's the feature we'll be using and can calculate it using the n() function in dplyr.

#4. Creating the bike sharing graph
#We'll use the graph_from_data_frame() function to create a graph based on the from and to station id's. Next we'll add the edge weight parameters and quickly size our graph. We can see that it's got approximately 19, 000 edges and 300 vertices. In other words a very dense graph.

#5. Explore the graph
#Let' look at the first 12 vertices of the graph. We'll create a subgraph and then visualize it by setting the edge width to the number of trips taken. The most obvious thing that stands out is that there are many loops in the graph. These represent trips where people took a bike out from the station and returned it to the same one. In fact based on the edge width we can see this is the most common kind of trip! Another thing we see is that closer vertices tend to have more trips between them than distant vertices. However we should be careful, just because igraph draws them close together doesn't mean that they are geographically close (but we'll cover that later in the chapter).

# Load data from csv:
bike_dat <- read.csv("BikeSharing/divvy_bike_sample.csv")

## == Making Graphs of Different User Types
# Let's compare graphs of people who subscribe to the divvy bike vs. more casual non-subscribing customers.
library(dplyr)
library(magrittr)
library(igraph)

subscribers <- bike_dat %>% 
  # Filter for rows where usertype is Subscriber
  filter(usertype == "Subscriber")

# Count the number of subscriber trips
n_subscriber_trips <- nrow(subscribers)

subscriber_trip_graph <- subscribers %>% 
  # Group by from_station_id and to_station_id
  group_by(from_station_id, to_station_id) %>% 
  # Calculate summary statistics
  summarize(
    # Set weights as proportion of total trips
    weights = n() / n_subscriber_trips
  ) %>%
  # Make a graph from the data frame
  graph_from_data_frame()

customers <- bike_dat %>% 
  # Filter for rows where usertype is "Customer"
  filter(usertype == "Customer")

# Count the number of customer trips
n_customer_trips <- nrow(customers)

customer_trip_graph <- customers %>% 
  # Group by from_station_id and to_station_id
  group_by(from_station_id, to_station_id) %>% 
  # Calculate summary statistics
  summarize(
    # Set weights as proportion of total trips 
    weights = n() / n_customer_trips
  ) %>%
  # Make a graph from the data frame
  graph_from_data_frame()

# Calculate number of different trips by subscribers
gsize(subscriber_trip_graph)

# Calculate number of different trips by customers
gsize(customer_trip_graph)

# Result: Subscribers made over 14 thousand different trips, compared to over 9 thousand for (non-subscribing) customers.

# == Compare Graphs of Different User Types
# One of the easiest ways we can see differences between the graphs is by plotting a small subgraph of each one. If different patterns are strong, they should be easy to visually detect. As you look at these two different plots, what stands out? It's worth taking a moment to think about the differences between these two populations. While there's doubtless overlap between these two groups, what are some different traits between each population? Subscribers are probably regular users, local, and might be more likely to travel to more remote parts of the graph. Customers are likely tourists or locals who don't bike regularly. Their use is probably more centered in major stations, and they might ride more for leisure in some of the touristy parts of the city.

# Induce a subgraph from subscriber_trip_graph of the first 12 vertices
twelve_subscriber_trip_graph <- induced_subgraph(subscriber_trip_graph, 1:12)

# Plot the subgraph and title it "Subscribers"
plot(
  twelve_subscriber_trip_graph, 
  main = "Subscribers"
)

# Induce a subgraph from customer_trip_graph of the first 12 vertices
twelve_customer_trip_graph <- induced_subgraph(customer_trip_graph, 1:12)

# Plot the subgraph
plot(
  twelve_customer_trip_graph, 
  main = "Customers"
)

## == Compare graph distance vs. geographic distance

## 1. Compare graph distance vs. geographic distance
#It's important to keep in mind that a graph is an abstract representation of connected things, and often they are connected in physical space. Because of that, properties of a graph can be constrained by, and often reflect, the underlying nature of the system. In this case, the graph represents the geography of the city of Chicago. In this video we'll take a look at how graph distance is related to geographic distance.

#2. A map of the graph
#Here we can see an overview of the all the bike sharing stations (with no edges drawn) that represent the vertices in our graph. Now let's look at graph distance and plot that back on our map.

#3. Graph distance
#Here we've identified the longest shortest path between two vertices. There are two functions we can use: farthest_vertices() which tells us the two end vertices and the path length, and get_diameter() which returns the actual path. We might expect these two vertices to also be quite far geographically so next let's plot these on the map.

#4. Graph distance vs geographic distance
#Now we can see that the vertices with the longest shortest path are quite far apart on the map as well. But just how far apart? Luckily our initial data frame has the latitude and longitude of each bike station. Let's walk through how we can find the geographic distance.

#5. Geographic distance
#To find the farthest distance we only need to use a simple function in the geosphere package. The real guts are just grabbing a single vector of latitude and longitude from the dataframe. To do that we use dplyr to first filter by station_id, take just one row using sample_n(1) and and lastly select just the longitude and latitude. Once we have a vector, we can just input these into the distm() function.

#6. Geographic distance
#Because we may want to do this on more than one station, we can easily convert these few lines of code into a function to use later called bike_dist().

## == Compare Subscriber vs. Non-Subscriber Distances
# Let's compare subscriber to non-subscriber graphs by distance. Remember we can think of subscribers as local Chicago residents who regularly use the bikes, whereas non-subscribers are likely to be more casual users or tourists. Also it's important to keep in mind that this graph is a representation of geography. Which graph do you think has a further geographic distance? Why?
  
#  get_diameter() and farthest_vertices() both provide the vertices in the graph that have the longest "shortest route" between them – get_diameter() provides all the intermediate vertices, whereas farthest_vertices() provides the end vertices and the number of nodes between them.

# calc_physical_distance_m(), a function that takes in two station IDs as inputs and calculates the physical distance between the stations (in meters), is also provided. You can view the function by running calc_physical_distance_m in the console.

library(geosphere)
# Get the diameter of the subscriber graph
get_diameter(subscriber_trip_graph)

# Get the diameter of the customer graph
get_diameter(customer_trip_graph)

# Find the farthest vertices of the subscriber graph
farthest_vertices(subscriber_trip_graph)

# Find the farthest vertices of the customer graph
farthest_vertices(customer_trip_graph)

## HERE IS A SET OF FUNCTIONS IN SLIDES!!!

# Calc physical distance between end stations for subscriber graph
calc_physical_distance_m(200, 298)

# Calc physical distance between end stations for customer graph
calc_physical_distance_m(116, 281)

# Result: In the subscriber graph, the furthest stations were 17km apart, compared to 7km for non-subscribing customers. Now on to most traveled to and from stations

trip_deg <- data_frame(
  # Find the "out" degree distribution
  trip_out = degree(trip_g_simp, mode = "out"), 
  # ... and the "in" degree distribution
  trip_in = degree(trip_g_simp, mode = "in"),
  # Calculate the ratio of out / in
  ratio = trip_out / trip_in
)

trip_deg_filtered <- trip_deg %>%
  # Filter for rows where trips in and out are both over 10
  filter(trip_in > 10, trip_out > 10) 

# Plot histogram of filtered ratios
hist(trip_deg_filtered$ratio)

## == Most Traveled To and From Stations with Weights
# So far, we've only looked at our network with unweighted edges. But our edge weights are actually the number of trips, so it seems logical that we would want to extend our analysis of degrees by adding a weighted degree distribution. This is important because while a balanced degree ratio is important, the item that would need to be rebalanced is bikes. If the weights are the same across all stations, then an unweighted degree ratio would work. But if we want to know how many bikes are actually flowing, we need to consider weights.

# The weighted analog to degree distribution is strength. We can calculate this with the strength() function, which presents a weighted degree distribution based on the weight attribute of a graph's edges.

trip_strng <- data_frame(
  # Find the "out" strength distribution
  trip_out = strength(trip_g_simp, mode = "out"), 
  # ... and the "in" strength distribution
  trip_in = strength(trip_g_simp, mode = "in"),
  # Calculate the ratio of out / in
  ratio = trip_out / trip_in
)

trip_strng_filtered <- trip_strng %>%
  # Filter for rows where trips in and out are both over 10
  filter(trip_in > 10, trip_out > 10) 

# Plot histogram of filtered ratios
hist(trip_strng_filtered$ratio)

## == Visualize central vertices
# As we saw in the last lesson, station 275 had the lowest out/in degree ratio. We can visualize this using make_ego_graph() to see all the outbound paths from this station. It's also useful to plot this on a geographic coordinate layout, not the default igraph layout. By default, igraph uses the layout_nicely() function to display your graph, making an algorithmic guess about what the best layout should be. However, in this case we want to specify the coordinates of each station, because when a vertex is above another it means it's actually north of it.

# Make an ego graph of the least traveled graph
g275 <- make_ego_graph(trip_g_simp, 1, nodes = "275", mode= "out")[[1]]

# Plot ego graph
plot(
  g275, 
  # Weight the edges by weight attribute 
  edge.width = E(g275)$weight
)

# From previous step
g275 <- make_ego_graph(trip_g_simp, 1, nodes = "275", mode= "out")[[1]]

# Plot ego graph
plot(
  g275, 
  edge.width = E(g275)$weight,
  # Use geographic coordinates
  layout = latlong 
)

## == Weighted Measures of Centrality
# Another common measure of important vertices is centrality. There are a number of ways that we can measure centrality, but for this lesson, we'll consider two metrics: eigen centrality and closeness. While eigen centrality has already been covered, closeness is another way of assessing centrality. It considers how close any vertex is to all the other vertices. In earlier lessons, we haven't explicitly considered weighted versus unweighted versions of centrality. In this lesson, we'll calculate both weighted and unweighted versions and see if the change is returned.

# In the below example, do you expect to see the same vertex each time? What do you think will be the biggest difference between metrics or between weighted and unweighted versions?

# This calculates weighted eigen-centrality 
ec_weight <- eigen_centrality(trip_g_simp, directed = TRUE)$vector

# Calculate unweighted eigen-centrality 
ec_unweight <- eigen_centrality(trip_g_simp, directed = TRUE, weights = NA)$vector

# This calculates weighted closeness
close_weight <- closeness(trip_g_simp)

# Calculate unweighted closeness
close_unweight <- closeness(trip_g_simp, weights = NA)

# Get vertex names
vertex_names <- names(V(trip_g_simp))

# Complete the data frame to see the results
data_frame(
  "Weighted Eigen Centrality" = vertex_names[which.min(ec_weight)],
  "Unweighted Eigen Centrality" = vertex_names[which.min(ec_unweight)],
  "Weighted Closeness" = vertex_names[which.min(close_weight)],
  "Unweighted Closeness" = vertex_names[which.min(close_unweight)]
)

## Connectivity
# 1. Connectivity
#Connectivity is a measure of how densely connected the vertices of a graph are. It's measured in two forms: vertex and edge connectivity. Each measure tells you how many vertices or edges need to be removed to disconnect the graph creating two distinct graphs.

#2. Measuring connectivity
#Here we have a small graph with 10 vertices. Let's measure the edge and vertex connectivity.

#3. Measuring connectivity
#Each measure is returning how many vertices or edges we need to remove. In this case, both are two. However this doesn't tell us what the split would be and what the specific cuts are being made.

#4. Minimum number of cuts
#Using the min_cuts() function we can learn a lot about the connectivity. First we get the value for edge connectivity, and then we can see the two cuts that are made. In this case between vertices 10 and 7 and 10 and 1. Lastly we see the two partitions. In this case it's a single vertex partitioned from the rest of the graph.

#5. Connectivity randomizations
#Now that we have a better understanding of connectivity, let's see how the graph connectivity of of a random graph compares to our bike sharing graph. To do this we'll use a similar process to what we've used in the intro lesson where we build a random graph with the same properties as the graph of interest and compare a metric to the distribution of metrics from a random graph.

#6. Connectivity randomizations
#The connectivity of our bike sharing graph is much less than we'd expect by chance. We can hypothesize this is likely because the connection between vertices is constrained by geography. It is unlikely that two stations that are 15 kilometers apart will be connected, but in a random graph, there is no geographic constraint - so those far apart vertices can be connected. This leads to much greater connectivity than a random graph.

## Find the minimum cut 1
# Connectivity tells us the minimum number of cuts needed to split the graph into two different subgraphs. igraph has two functions that we can use to tell us which vertices are actually cut into those two different subgraphs and how many cuts are required. The first is min_cut(), which returns all the cuts made, the number of cuts, and the two different subgraphs created. The number of cuts differs between directed and undirected graphs. In directed graphs, the minimum number of cuts only counts inbound edges, whereas in an undirected graph, it is how many cuts for all edges.

# Calculate the minimum number of cuts
ud_cut <- min_cut(trip_g_ud, value.only = FALSE)

# See the result
ud_cut

# The number of cuts are shown in value, and the vertices in each new graph are listed in partition1 and partition2.

# Find the minimum cut 2
# Another function for cutting graphs into several smaller graphs is stMincuts(). This requires the graph and the IDs of two vertices, and tells you minimum number of cuts needed in the graph to disconnect them (specified by the value element of the function output). The syntax for this function is:
  
# stMincuts(graph, "node1", "node2")

# Make an ego graph from the first partition
ego_partition1 <- make_ego_graph(trip_g_ud, nodes = ud_cut$partition1)[[1]]

# Plot the ego graph
plot(ego_partition1)

# Find the number of cuts needed to disconnect nodes "231" and "321"
stMincuts(trip_g_simp, "231", "321")

# Find the number of cuts needed to disconnect nodes "231" and "213"
stMincuts(trip_g_simp, "231", "213")

# Nodes "231" and "321" needed 157 cuts compared to 77 cuts for nodes "231" and "213".

## == Unweighted Clustering Randomizations
# We've seen that the bike graph has a very low connectivity relative to a random graph. This is unsurprising because we expect that a graph that represents geographic space should have some parts that are connected by small corridors, and therefore, it wouldn't take much to disconnect the graph. It follows that it's likely that there are geographic clusters that are highly connected to each other and less connected to other clusters. We can test this hypothesis by looking at the transitivity of the network, or the clustering coefficient, a concept introduced in our introductory lesson. Several types of clustering coefficients exist, but we'll be looking at the global definition (essentially the portion of fully closed triangles), which is the same one covered earlier. First, we will look at an unweighted version of the graph and compare it to a random graph.

# To calculate the global transitivity of a network, you'll need to set type to "global" in your call to transitivity().

# The bike trip network, trip_g_simp is available.

# Calculate global transitivity
actual_global_trans <- transitivity(trip_g_simp, type = "global")

# See the result
actual_global_trans

# Calculate the order
n_nodes <- gorder(trip_g_simp)

# Calculate the edge density
edge_dens <- edge_density(trip_g_simp)

# Run the simulation
simulated_global_trans <- rep(NA, 300)
for(i in 1:300) {
  # Generate an Erdos-Renyi simulated graph
  simulated_graph <- erdos.renyi.game(n_nodes, edge_dens, directed = TRUE)
  # Calculate the global transitivity of the simulated graph
  simulated_global_trans[i] <- transitivity(simulated_graph, type = "global")
}

# Plot a histogram of simulated global transitivity
hist(
  simulated_global_trans, 
  xlim = c(0.35, 0.6), 
  main = "Unweighted clustering randomization"
)

# Add a vertical line at the actual global transitivity
abline(v = actual_global_trans, col = "red")

# Result: What a simulating exercise! The global transitivity of each simulation is much lower than the global transitivity of the original graph. Let's try it again but with weighted clustering.

## == Weighted Clustering Randomizations
# We can see support for the hypothesis that a graph with low connectivity would also have very high clustering, much higher than by chance. But our graph is more than just an undirected graph, it also has weights that represent the number of trips taken. So now we have several things to consider in our randomization. First, the weighted version of the metric is local only, so a transitivity value is calculated for each vertex. Second, the random graph doesn't include weights. To solve both of these problems, we'll look at the mean vertex transitivity, and implement a slightly more complicated randomization scheme.

# To calculate the weighted vertex transitivity of a network, you'll need to set type to "weighted" in your call to transitivity().

# The bike trip network, trip_g_simp is available.

# Find the mean local weighted clustering coeffecient using transitivity()
actual_mean_weighted_trans <- mean(transitivity(trip_g_simp, type = "weighted"))

# Calculate the order
n_nodes <- gorder(trip_g_simp)

# Calculate the edge density
edge_dens <- edge_density(trip_g_simp)

# Get edge weights
edge_weights <- E(trip_g_simp)$weigths

# Run the simulation
simulated_mean_weighted_trans <- rep(NA, 100)
for(i in 1:100) {
  # Generate an Erdos-Renyi simulated graph
  simulated_graph <- erdos.renyi.game(n_nodes, edge_dens, directed = TRUE)
  # Get number of edges in simulated graph
  n_simulated_edges <- gsize(simulated_graph)
  # Sample existing weights and add them to the random graph
  E(simulated_graph)$weight <- sample(edge_weights, n_simulated_edges, replace = TRUE)
  # Get the mean transitivity of the simulated graph
  simulated_mean_weighted_trans[i] <- mean(transitivity(simulated_graph, type = "weighted"))
}

# Compare the simulated mean weighted transitivities to the value from the original graph.
# Plot a histogram of simulated mean weighted transitivity
hist(
  simulated_mean_weighted_trans, 
  xlim = c(0.35, 0.7), 
  main = "Mean weighted clustering randomization"
)

# Add a vertical line at the actual mean weighted transitivity
abline(v = actual_mean_weighted_trans, col = "red")

# And we've reached the end of the ride for this bike chapter, but now let's wrap it up with some alternative plotting types.
# 