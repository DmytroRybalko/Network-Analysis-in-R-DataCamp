## == In this lesson we'll be building a graph up from raw twitter data. We'll use our graph to understand what users are most central to the conversation about a given topic, in this case, the rstats hashtag. We'll consider a couple different ways we can construct a graph and then look at who the most influential tweeters are, how one sided the conversations are and find the different communities using this hashtag.

## HOW TO BUILD GRAPH FROM RAW DATA:
## 3. Anatomy of a tweet
# You can see we have two different tweets. One is just a tweet about rstats, and the other a retweet. One of the most obvious ways we can construct a graph about the rstats conversation is by simply building one where vertices are screen names, and directed edges are retweets. In this case we would draw a directed link from kom_256 to elenagbg. To do that we're going to need to parse our data set, and tweet by tweet build up our graph.

## Loading the data
# Here we're going to get a sense of what the raw data looks like. The key fields here are the screen name and the tweet text. These are the fields that will let us build our retweet graph. The screen name tells us who tweeted, and the the text tells us two things when we parse it. First that it was a retweet because it starts with the capital letters RT, and second who is being retweeted, in this case Rbloggers. By parsing that text we can build our igraph object.
 
## == Visualize the graph
# Now that we've thought a bit about how we constructed our network, let's size our graph and make an initial visualization. Before you make the plot, you'll calculate the number of vertices and edges. This allows you to know if you can actually plot the entire network. Also, the ratio of nodes to edges will give you an intuition of just how dense or sparse your plot might be. As you create your plot, take a moment to hypothesize what you think the plot will look like based on these metrics.

## LOAD GRAPH OBJECT FROM THE INTERNET
library(igraph)

#retweet_graph <- read_graph("https://assets.datacamp.com/production/repositories/1576/datasets/edd5a8859ff65d52f34340fd003ffa53efc2ffd8/rt_g.gml", format = c("gml"))
retweet_graph <- read_graph("TwitterCaseStudy/retweet_graph.gml", format = c("gml"))

# Count the number of nodes in retweet_graph
gorder(retweet_graph)

# Count the number of edges in retweet_graph
gsize(retweet_graph)

# Calculate the graph density of retweet_graph
graph.density(retweet_graph)

# Plot retweet_graph
plot(retweet_graph)

## == Visualize nodes by degree
# Now that we've taken a look at our graph and explored some of the basic properties of it, let's think a bit more about our network. We observed that there are some highly connected nodes and many outlier points. We visualize this by conditionally plotting the graph and coloring some of the nodes by in and out degree. Let's think about the nodes as three different types:
# high retweeters and highly retweeted.
# users who retweeted only once (have an in-degree of 0 and an out-degree of 1).
# users who were retweeted only once (have an in-degree of 1 and an out-degree of 0).
# This will help us get more information about what's going on in the ring around the cluster of highly connected nodes.

# HERE IS IMPORTANCE METRICS!!!

# Calculate the "in" degree distribution of retweet_graph
in_deg <- degree(retweet_graph, mode = "in")

# Calculate the "out" degree distribution of retweet_graph
out_deg <- degree(retweet_graph, mode = "out")

# Find the case with one "in" degree and zero "out" degrees
has_tweeted_once_never_retweeted <- in_deg == 1 & out_deg == 0

# Find the case with zero "in" degrees and one "out" degree
has_never_tweeted_retweeted_once <- in_deg == 0 & out_deg == 1

# The default color is set to black
vertex_colors <- rep("black", gorder(retweet_graph))

# Set the color of nodes that were retweeted just once to blue
vertex_colors[has_tweeted_once_never_retweeted] <- "blue"

# Set the color of nodes that were retweeters just once to green 
vertex_colors[has_never_tweeted_retweeted_once] <- "green"

# See the result
vertex_colors

plot(
  # Plot the network
  retweet_graph, 
  # Set the vertex colors to vertex_colors
  vertex.color = vertex_colors
)

## == What's the distribution of centrality?
# Recall that there are many ways that you can assess centrality of a graph. We will use two different methods you learned earlier: betweenness and eigen-centrality. Remember that betweenness is a measure of how often a given vertex is on the shortest path between other vertices, whereas eigen-centrality is a measure of how many other important vertices a given vertex is connected to. Before we overlay centrality on our graph plots, let's get a sense of how centrality is distributed.

# Note that due to algorithmic rounding errors, we can't check for eigen-centrality equaling a specific value; instead, we check a range.

# Calculate directed betweenness of vertices
retweet_btw <- betweenness(retweet_graph, directed = TRUE)

# Get a summary of retweet_btw
summary(retweet_btw)

# Calculate proportion of vertices with zero betweenness
mean(retweet_btw == 0)

# Calculate eigen-centrality using eigen_centrality()
retweet_ec <- eigen_centrality(retweet_graph, directed = TRUE)$vector

# Get a summary of retweet_ec
summary(retweet_ec)

# Calc proportion of vertices with eigen-centrality close to zero
almost_zero <- 1e-10
mean(retweet_ec < almost_zero)

# Result:
# Wow! The distributions are highly skewed. 95% of nodes have zero betweenness, but a few have a large value (with the highest close to 70k). Likewise, 97% of vertices have eigen-centrality close to zero.
 
## == Who is important in the conversation?
# Different measures of centrality all try to get at the similar concept of "which vertices are most important." As we discussed earlier, these two metrics approach it slightly differently. Keep in mind that while each may give a similar distribution of centrality measures, how an individual vertex ranks according to both may be different. Now we're going to compare the top ranking vertices of Twitter users.

# The vectors that store eigen and betweenness centrality are stored respectively as retweet_ec and retweet_btw.

# Get 0.99 quantile of betweenness 
betweenness_q99 <- quantile(retweet_btw, 0.99)

# Get top 1% of vertices by betweenness
top_btw <- retweet_btw[retweet_btw > as.numeric(betweenness_q99)]

# Get 0.99 quantile of eigen-centrality
eigen_centrality_q99 <- quantile(retweet_ec, 0.99)

# Get top 1% of vertices by eigen-centrality
top_ec <- retweet_ec[retweet_ec > as.numeric(eigen_centrality_q99)]

# See the results as a data frame
data.frame(
  Rank = seq_along(top_btw), 
  Betweenness = names(sort(top_btw, decreasing = TRUE)), 
  EigenCentrality = names(sort(top_ec, decreasing = TRUE))
)

# Result: now you can see who the most central screen names are!

## == Plotting important vertices
# Lastly, we'll visualize the graph with the size of the vertex corresponding to centrality. However, we already know the graph is highly skewed, so there will likely be a lot of visual noise. So next, we'll want to look at how connected the most central vertices are. We can do this by creating a subgraph based on centrality criteria. This is an important technique when dealing with large graphs. Later, we'll look at alternative visualization methods, but another powerful technique is visualizing subgraphs.

# The graph, retweet_graph, its vertex betweenness, retweet_btw, and the 0.99 betweenness quantile, betweenness_q99 are available.

# Transform betweenness: add 2 then take natural log
transformed_btw <- log(retweet_btw + 2)

# Make transformed_btw the size attribute of the vertices
V(retweet_graph)$size <- transformed_btw

# Plot the graph
plot(
  retweet_graph, vertex.label = NA, edge.arrow.width = 0.2,
  edge.arrow.size = 0.0, vertex.color = "red"
)

# From previous step
transformed_btw <- log(retweet_btw + 2)
V(retweet_graph)$size <- transformed_btw

# Subset nodes for betweenness greater than 0.99 quantile
vertices_high_btw <- V(retweet_graph)[retweet_btw > betweenness_q99]

# Induce a subgraph of the vertices with high betweenness
retweet_subgraph <- induced_subgraph(retweet_graph, vertices_high_btw)

# Plot the subgraph
plot(retweet_subgraph)

# Result:
# You can see that the most central vertices are all highly connected to each other, and by creating a sub-graph, we can more easily visualize the network. Now that we've explored the retweet graph let's move on to looking at another type of Twitter graph.