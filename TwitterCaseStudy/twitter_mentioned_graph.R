## 1. Building a mentions graph
#We've already explored our retweet graph a bit, but the great thing about the fact that we're working with the raw data is that we can choose how to construct our graph. Depending the decisions we make, the same raw data can tell us different things. Previously we looked at how people retweeted about the rstats hashtag, but now let's build a slightly different graph, one that's centered around conversation, not retweets.

#2. Recall tweet anatomy
#Tweets that mention someone tend to be of two types: a reply to some earlier conversation, in which case the tweet starts off with a persons name or simply calling out someone when referencing their work as in the second tweet. If you'll recall all retweets started off with the capital letters RT. This means when we build up our graph, we have two challenges we didn't before. One: we can't simply pull out all the names, we need to specifically avoid names that are in retweets. Two: a given tweet might mention multiple people, so we need to pull out all the names, and in this case draw a link between AlexisAchim and four others.

#3. Build your mentions graph
#Just like when we built up our retweet graph, we first create an empty graph and then add a vertex for each screen name. Next we loop over all the raw tweets in our dataframe and extract all the screen names (recall that I have a special function for doing this that uses regular expressions, which is beyond the scope of this course). Because you can have multiple names in a tweet, the function returns a vector of names. Then just like before, if anything was returned we add the edges. However now we need an extra loop in case multiple screen names were returned. We make sure both vertices are in the graph, and add them if they're not, and finally add the edge. Lastly we simplify and trim out any vertices with no connection.

## == Comparing mention and retweet graph
# By looking at the ratio of in degree to out degree, we can learn something slightly different about each network. In the case of a retweet network, it will show us users who are often retweeted but don't retweet (high values), or those who often retweet but aren't retweeted (low values). Similarly, if you have a in/out ratio of close to 1 in a mention graph, then the conversation is relatively equitable. However, a low ratio would imply that a given user often starts conversations but they aren't responded to. When you compare the density plots of the different networks, consider what you'd expect. Which network do you expect to be more skewed and which do you expect to have a ratio closer to 1?

## LOAD GRAPH OBJECT FROM THE INTERNET
library(igraph)

mention_graph <- read_graph("TwitterCaseStudy/ment_g.gml", format = c("gml"))

# Read this code
mention_data <- data.frame(
  graph_type = "mention",
  degree_in = degree(mention_graph, mode = "in"),
  degree_out = degree(mention_graph, mode = "out"),
  io_ratio = degree_in / degree_out
)

# Create a dataset of retweet ratios from the retweet_graph
retweet_data <- data.frame(
  graph_type = "retweet",
  degree_in = degree(retweet_graph, mode = "in"),
  degree_out = degree(retweet_graph, mode = "out"),
  io_ratio = degree_in / degree_out
)

# Bind the datasets by row
io_data <- bind_rows(mention_data, retweet_data) %>% 
  # Filter for finite, positive io_ratio
  filter(is.finite(io_ratio), io_ratio > 0)

# Using io_data, plot io_ratio colored by graph_type
ggplot(io_data, aes(x = io_ratio, color = graph_type)) + 
  # Add a geom_freqpoly layer
  geom_freqpoly() + 
  scale_x_continuous(breaks = 0:10, limits = c(0, 10))

io_data %>% 
  # Group by graph_type
  group_by(graph_type) %>% 
  summarize(
    # Calculate the mean of io_ratio
    mean_io_ratio = mean(io_ratio),
    # Calculate the median of io_ratio
    median_io_ratio = median(io_ratio)
  )

# Resutl: Now you can see the difference in the ratio of in and out degrees of mention and retweet graphs.

## == Assortativity and reciprocity
# Another two key components of understanding our graphs are reciprocity and degree assort~ativity. Recall that reciprocity is the number of vertices that have connections going in each direction. Therefore, in the retweet graph, reciprocity is measuring the overall amount of nodes that retweet each other. In the mention graph, it will tell us how many nodes are conversing back and forth.

# Assortitivity is a bit less obvious. Values greater than 0 indicate that vertices with high degrees tend to be connected to each other. However, values less than zero indicate a more degree disassortative graph. If you visualize the graph and see a hub and spoke type pattern, this is likely to be disassortative.

# Find the reciprocity of the retweet graph
reciprocity(retweet_graph)

# Find the reciprocity of the mention graph
reciprocity(mention_graph)

# Find the directed assortivity of the retweet graph
assortativity.degree(retweet_graph)

# Find the directed assortivity of the mention graph
assortativity.degree(mention_graph)

# Result: Reciprocity is higher in the mention graph compared to the retweet graph, and both graphs have negative assortativity.

## == Finding who is talking to whom
# Recall from the first lesson that cliques are complete subgraphs within a larger undirected graph. When we look at the clique structure of a conversational graph in Twitter, it tells us who is talking to whom. One way we can use this information is to see who might be interested in talking to other people. It's easy to see how this basic information could be used to construct models of suggested users to follow or interact with.
# Get size 3 cliques
list_of_clique_vertices <- cliques(mention_graph, min = 3, max = 3)

# Loop over cliques, getting IDs
clique_ids <- lapply(list_of_clique_vertices, as_ids)

# From previous step
list_of_clique_vertices <- cliques(mention_graph, min = 3, max = 3)
clique_ids <- lapply(list_of_clique_vertices, as_ids)

# Loop over cliques, finding cases where revodavid is in the clique
has_revodavid <- sapply(
  clique_ids, 
  function(clique) {
    "revodavid" %in% clique
  }
)

# Subset cliques that have revodavid
cliques_with_revodavid <- clique_ids[has_revodavid]

# Unlist cliques_with_revodavid and get unique values
people_in_cliques_with_revodavid <- unique(unlist(cliques_with_revodavid))

# Induce subgraph of mention_graph with people_in_cliques_with_revodavid 
revodavid_cliques_graph <- induced_subgraph(mention_graph, people_in_cliques_with_revodavid)

# Plot the subgraph
plot(revodavid_cliques_graph)

# Result: Classy clique analysis! Revodavid is in six cliques of size three.
# 

## ==  Finding communities
 #One of the most common things you'll want to do with this type of social data is find "communities". Communities are a natural way to think of a mention graph. You're trying to algorithmically find groups of people who talk to each other, more than they talk to any other group of people. Recall that in the first lesson it was covered that there are a number of methods for doing this. Here what we're going to focus on is how you can understand the difference between these methods.

# 2. Three different communities
#Let's find communities using three different methods in our mention graph. Here we're going to use the edge betweenness, leading eigen vector, and label propagation methods.

#3. Sizing the communities
#First we're going to just look at the number and sizes of the communities that were found. If we look at the length of each community object, it tells us the number of communities found. In this case, label propagation found the largest number of communities (212).

#4. Sizing the communities (2)
#We can use the sizes() function to get the size of each community and use the table() function to see how many there are. In this case each algorithm found 103 communities of size 2, but then things start to diverge. The label propagation algorithm found 19 communities of size five, but the other two found only 7. So how can we compare these?
  
#5. Comparing communities
#The compare() function allows us to measure similarity between community structures. Here we're using the variance in information metric. Essentially it says how much variation is there in community membership for each vertex. The closer the number is to 0, the more likely it is that any two vertices are to be found in the same community as determined by each algorithm. In this case, the eigen vector method and label propagation are the least similar.

## == Comparing community algorithms
# There are many ways that you can find a community in a graph (you can read more about them here). Unfortunately, different community detection algorithms will give different results, and the best algorithm to choose depends on some of the properties of your graph Yang et. al..

# You can compare the resulting communities usingcompare(). This returns a score ("the variance in information"), which counts whether or not any two vertices are members of the same community. A lower score means that the two community structures are more similar.

# You can see if two vertices are in the same community using membership(). If the vertices have the same membership number, then they are in the same community.

# Make retweet_graph undirected
retweet_graph_undir <- as.undirected(retweet_graph)

# Find communities with fast greedy clustering
communities_fast_greedy <- cluster_fast_greedy(retweet_graph_undir)

# Find communities with infomap clustering
communities_infomap <- cluster_infomap(retweet_graph_undir)

# Find communities with louvain clustering
communities_louvain <- cluster_louvain(retweet_graph_undir)

# Compare fast greedy communities with infomap communities
compare(communities_fast_greedy, communities_infomap)

# Compare fast greedy with louvain
compare(communities_fast_greedy, communities_louvain)

# Compare infomap with louvain
compare(communities_infomap, communities_louvain)

two_users <- c("bass_analytics", "big_data_flow")

# Subset membership of communities_fast_greedy by two_users
membership(communities_fast_greedy)[two_users]

# Subset membership of communities_infomap by two_users
membership(communities_infomap)[two_users]

# Subset membership of communities_louvain by two_users
membership(communities_louvain)[two_users]

# Result: Delightful community detection! compare() returned a smaller distance between Infomap and Louvain communities, meaning that those algorithms gave more similar results than “Fast and Greedy”. In “Fast and Greedy”, the users bass_analytics and big_data_flow were placed in the same community but the other algorithms placed them in different communities.

## == Visualizing the communities
# Now that we've found communities, we'll visualize our results. Before we plot, we'll assign each community membership to each vertex and a crossing value to each edge. The crossing() function in igraph will return true if a particular edge crosses communities. This is useful when we want to see certain vertices that are bridges between communities. You may just want to look at certain communities because the whole graph is a bit of a hairball. In this case, we'll create a subgraph of communities only of a certain size (number of members).

# Color vertices by community membership, as a factor
V(retweet_graph)$color <- factor(membership(communities_louvain))

# Find edges that cross between commmunities
is_crossing <- crossing(communities_louvain, retweet_graph)

# Set edge linetype: solid for crossings, dotted otherwise 
E(retweet_graph)$lty <- ifelse(is_crossing, "solid","dotted")

# Get the sizes of communities_louvain
community_size <- sizes(communities_louvain)

# Find some mid-size communities
in_mid_community <- unlist(communities_louvain[community_size > 50 & community_size < 90])

# Induce a subgraph of retweet_graph using in_mid_community
retweet_subgraph <- induced_subgraph(retweet_graph, in_mid_community)

# Plot those mid-size communities
plot(retweet_subgraph, vertex.label = NA, edge.arrow.width = 0.8, edge.arrow.size = 0.2, 
     coords = layout_with_fr(retweet_subgraph), margin = 0, vertex.size = 3)

# Result: Most of the edges connect members of a community to each other. There are only a few lines connecting each community to other communities.
