# 1. Other packages for plotting graphs
#So far we've done all our plotting with igraph. While igraph's base plotting works great for quick visualization, other libraries will let you make high quality graphics with less effort. It's important to be aware that there are other libraries for plotting, but in this lesson we'll focus on two that are based on the popular ggplot2 framework, ggnet2 and ggnetwork.

#2. Generating data to plot
#First we'll generate a random graph, and then add a few attributes. In this case we'll add centrality and community attributes to each vertex. This will give us some extra dimensions to visualize.

#3. Generate data to plot
#Here is the the basic plot for reference. Keep that in mind as we look at the other basic plots.

#4. Basic ggnet2
#ggnet2 function calls are similar to igraph. You won't notice much difference between these two frameworks until it comes time to plot a graph with more attributes. Also it doesn't work natively with igraph objects. Instead you'll need to use the asNetwork() function from the intergraph package to convert to network format. In practice this will have very little impact on your plotting.

#5. Basic ggnet2
#Here we can see the default ggnet2 plot, it doesn't look that different from the igraph default plot.

#6. Basic ggnetwork
#ggnetwork is a bit different than ggnet2. Using the ggnetwork() function you convert the igraph object into a dataframe that can easily be plotted in ggplot2. If you're familiar with ggplot2, using this package with feel quite natural. When we look at the dataframe that's created, we can see that it has x, y,xend, and yend columns, which allow graphs to be created using ggplot2 segments and curves. It also adds new geoms to use, specifically geom_nodes() and geom_edges(). These new geoms, will specify the aesthetics for edges and vertices.

#7. Basic ggnetwork
#Just like ggnet2, the plot looks basic, it's when we want to visualize other attributes of the graph that these libraries start to make your life easier.

#8. Plotting graphs with attributes
#Now is when things start getting complicated with igraph plots, especially when adding the legends. We don't need to walk through all the details here, what's important is to note just how much code goes into creating this figure.

#9. igraph plot with attributes
#We've now made a plot of our random graph with centrality coded as size, and community membership shown by vertex color.

#10. ggnet2 plot with attributes
#Using ggnet2 we can make the same plot, all we do is specify vertex size and color with the node-dot-size and node-dot-color parameters. We can easily give it a color palette, have the size cutting by default, and provide labels for each legend.

#11. ggnet2 plot with attributes
#With far fewer lines of code, we've recreated the annotated igraph plot.

#12. ggnetwork plot with attributes
#Because we are using ggplot2 with just a specific data frame format, we specify colors and size just like we would any ggplot2 call. Within the aes() calls in each geom, we map color and size. In this case because we want to add colors for community membership and size for centrality, we just specify that within geom_nodes(). To draw edge colors by community membership we do the same within geom_edges. Again we specify legend parameters the exact same way as any ggplot2 call.

#13. ggnetwork plot with attributes
#Just like with ggnet2, we can use a single line of code to recreate a figure that in igraph took 6 lines.


## == ggnet Basics

# There are many ways to visualize a graph beyond the basic igraph plotting. A common framework is to use ggplot2, which provides a way to make high quality plots with minimal graphical parameter setting. In this lesson, we'll cover the basics of creating a plot with ggnet2. This package builds graph plots using the ggplot2 framework. While it produces nice graphics, it relies on graph objects from a different R library network, but it does make plots with a ggplot2 aesthetic without quite the formal grammar of graphics used by ggnetwork, as we'll see in the next lesson. Therefore, you'll notice a lot of overlap in the syntax with igraph (node.size is the same as vertex.size, and edge.size is the same name).

# Create subgraph of retweet_graph
retweet_samp <- induced_subgraph(retweet_graph, vids = verts)

# Plot retweet_samp using igraph
plot(retweet_samp, vertex.label = NA, edge.arrow.size = 0.2, edge.size = 0.5, vertex.color = "black", vertex.size = 1)

# Convert to a network object
retweet_net <- asNetwork(retweet_samp)

# Plot using ggnet2
ggnet2(retweet_net, edge.size = 0.5, node.color = "black", node.size = 1)

## == ggnetwork Basics
# In the last lesson, you saw that the ggnet2 package produces ggplot2-like plots with a reasonably familiar syntax to igraph. However, the ggnetwork package works a bit differently. It converts igraph objects into data frames that are easily plotted by ggplot2. It also adds several new geoms that can be used to build plots. The ggnetwork() function converts the igraph object to a data frame, and some parameters are added into the data frame (in this case, the arrow gap parameter) and then can be plotted using ggplot. From there, you build your graph up with geom_edges() for edges and geom_nodes() for vertices. In this lesson we'll do two basic plots of the retweet graph, one with ggplot defaults, and one with some basic theming to look a bit nicer.

# Call ggplot
ggplot(
  # Convert retweet_samp to a ggnetwork
  ggnetwork(retweet_samp), 
  # Specify x, y, xend, yend
  aes(x = x, y = y, xend = xend, yend = yend)) +
  # Add a node layer
  geom_nodes() +
  # Add an edge layer
  geom_edges()

# Call ggplot
ggplot(
  # Convert retweet_samp to a ggnetwork
  ggnetwork(retweet_samp), 
  # Specify x, y, xend, yend
  aes(x = x, y = y, xend = xend, yend = yend)) +
  # Add a node layer
  geom_nodes() +
  # Change the edges to arrows of length 6 pts
  geom_edges(arrow = arrow(length = unit(6, "pt"))) +
  # Use the blank theme
  theme_blank()

## ==More ggnet Plotting Options
# The real power of ggnet and other alternatives to igraph is that they offer a way to generate advanced plots with just a little parameterization. In the earlier example comparing the two plotting methods, they were somewhat similar. However, in this lesson we'll show how you can make more advanced plots. We'll take the Twitter data set and using igraph add several vertex attributes, centrality and community, and plot them quickly using ggnet.

# The centrality and community membership attributes you created in the last exercise are still present.

# Convert to a network object
retweet_net <- asNetwork(retweet_graph)

# Plot with ggnet2
ggnet2(
  retweet_net,
  # Set the node size to cent
  node.size = "cent", 
  # Set the node color to comm
  node.color = "comm", 
  # Set the color palette to Spectral
  color.palette = "Spectral", 
)

# From previous step
retweet_net <- asNetwork(retweet_graph)

# Update the plot
ggnet2(
  retweet_net, 
  node.size = "cent", 
  node.color = "comm", 
  color.palette = "Spectral",
  # Set the edge color
  edge.color = c("color", "grey90")
) +
  # Turn off the size guide
guides(size = FALSE)

## == More ggnetwork Plotting Options
# Just like in the last lesson, ggnetwork also offers methods to quickly generate nice plots. It's important to keep in mind that each package has a different style, which may or may not appeal to you. Recall that ggnetwork works by converting a graph to a dataframe to be plotted by ggplot2. Therefore. all the parameterizations you're used to will be available. This gives you a great degree of flexibility, but could also mean more effort to achieve the aesthetic you desire. We'll repeat the exercise in the previous lesson, but this time using ggnetwork. This will give you a good point of comparison to decide which package you like the best.

# The centrality and community membership attributes you created in the last exercise are still present.
ggplot(
  # Draw a ggnetwork of retweet_graph_smaller
  ggnetwork(retweet_graph_smaller, arrow.gap = 0.01), 
  aes(x = x, y = y, xend = xend, yend = yend)
) + 
  geom_edges(
    arrow = arrow(length = unit(6, "pt"), type = "closed"), 
    curvature = 0.2, color = "black"
  ) + 
  # Add a node layer, mapping color to comm and setting the size to 4
  geom_nodes(aes(color = comm), size = 4) + 
  theme_blank()

ggplot(
  ggnetwork(retweet_graph_smaller, arrow.gap = 0.01), 
  aes(x = x, y = y, xend = xend, yend = yend)
) + 
  geom_edges(
    # Add a color aesthetic, mapped to comm
    aes(color = comm),
    arrow = arrow(length = unit(6, "pt"), type = "closed"), 
    curvature = 0.2, color = "black"
  ) + 
  # Make the size an aesthetic, mapped to cent 
  geom_nodes(aes(color = comm, size = cent)) + 
  theme_blank() +  
  guides(
    color = guide_legend(title = "Community"), 
    # Add a guide to size titled "Centrality"
    size = guide_legend(title = "Centrality")
  )

## 1. Interactive visualizations
# Beyond some of the alternative packages for plotting that are native to R, we can use R to create javascript plots that are interactive and can easily be exported to html or integrated with shiny dashboards. Again there are multiple ways this can be done, but we'll look at two. The first uses ggiraph to create html widgets out of ggplot2 objects. The other package we'll use is networkD3, which converts igraph objects into D3-dot-js network plots.

#2. Generating some data
#Let's first create a simple random graph to plot. We'll add a centrality attribute that will be our tool tip for the interactive plot.

#3. Interactive plots with ggiraph
#First we'll make our plot using ggnetwork, and specify vertex size. Next we convert that ggplot2 object to something that can be plotted by ggiraph. To do that we'll use the geom_point_interactive function to specify that we want to interact with the vertices. Finally to display it we call ggiraph, and set the code argument to the ggplot2 object.

#4. ggiraph interactive plot
#Now when we move the pointer over the vertex, the centrality is displayed.

#5. ggiraph customization
#ggiraph allows lots of customizations via injecting custom css and parameters in ggiraph function calls. In some cases we can specify things like tooltip offset within the ggiraph function. However we can also include as much customization as we want in tooltips and hovering behavior by adding custom css. In this case we add a `data_id` to use the custom CSS within the `geom_point_interactive()` function that is the same as the tooltip. Next we include some custom css that specifies behavior on mouse over. In this case changing the color of the vertex, and size of the vertex.

#6. ggiraph customization
#Now when we move the pointer over the vertex, the centrality is displayed like before. But now the point zooms to size 5, and changes to red. You can inject as much or as little valid CSS into ggiraph as you want.

#7. Plotting with networkD3
#The networkD3 package is great because it allows you to create network D3-dot-js plots all in javascript from R. However that ease of use means there's not a lot of customization options without directly editing the source javascript which is beyond the scope of this lesson. To get started all we'll do is convert our random graph using the igraph_to_networkD3 function, and then plot the links using the simpleNetwork function. We just plot the links attribute because that has all the edges to be drawn.

#8. More complex networkD3
#To make a more complex plot we need directly add some of the properties to the nodes attribute of the networkD3 object. We do this by adding columns to the node data frame, nd3, in this case group for community membership and then cent for centrality. These will be the size and color in our next graph, just like we've done all lesson. Finally all we do is plot the graph using the forceNetwork() function. But now we've got to specify everything we want to plot. Links and nodes, and then the source and target for drawing the lines. We give it a nodeID which is the name of the vertex, Group is the community membership and nodesize is centrality. Lastly we add a legend and a font size for the pop-up text.
