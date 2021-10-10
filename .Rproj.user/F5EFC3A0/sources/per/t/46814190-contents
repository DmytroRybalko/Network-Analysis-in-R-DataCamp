## == 1. Simple word clustering
#This chapter moves beyond simple one-word frequency to give you exposure to slightly more technical text mining.

#2. Hierarchical clustering example
#You will start by doing a hierarchical clustering and making a dendrogram. Consider this example of annual rainfall. The rain data frame contains four cities with corresponding annual rainfall in inches. You will do a cluster analysis for the cities based on the rainfall. The dist function applied to the city rainfall data frame calculates the pairwise distances between each city to make dist_rain. For example, Cleveland and Portland have the same rainfall so their distance is 0 while Boston gets slightly more and New Orleans gets significantly more than the other three.

#3. A simple dendrogram
#The resulting dist_rain object is passed to hclust to create a hierarchical cluster object. Lastly, calling base plot on the hc object will get you a simple dendrogram. Notice how Cleveland and Portland are equal. They have no distance between them and are in fact the lowest of the four rainfall totals. Boston is slightly elevated but closer to Cleveland and Portland than to New Orleans which is the highest. It should be noted that a denrogram will reduce information. If Cleveland and Portland were separated by a small amount, even a single inch, the dendrogram would look the same.

#4. Dendrogram aesthetics
#Since the basic plot is not very eye-pleasing, we load the dendextend library. This is the code applied to a TDM instead of rainfall. It follows the same steps but adds branches_attr_by_labels. This function allows you to color specific branches of the dendrogram. Then you call plot the same as before. Since text dendrograms can be very busy, you may also want to add rectangles using the rect-dot-dendrogram function specifying the number of clusters, 2, and the border color "grey50".

## == Distance matrix and dendrogram
# A simple way to do word cluster analysis is with a dendrogram on your term-document matrix. Once you have a TDM, you can call dist() to compute the differences between each row of the matrix.

#Next, you call hclust() to perform cluster analysis on the dissimilarities of the distance matrix. Lastly, you can visualize the word frequency distances using a dendrogram and plot(). Often in text mining, you can tease out some interesting insights or word clusters based on a dendrogram.

#Consider the table of annual rainfall that you saw in the last video. Cleveland and Portland have the same amount of rainfall, so their distance is 0. You might expect the two cities to be a cluster and for New Orleans to be on its own since it gets vastly more rain.

# Create dist_rain
dist_rain <- dist(rain[,2])

# View the distance matrix
dist_rain

# Create hc
hc <- hclust(dist_rain)

# Plot hc
plot(hc, labels = rain$city)

## == Make a dendrogram friendly TDM
#Now that you understand the steps in making a dendrogram, you can apply them to text. But first, you have to limit the number of words in your TDM using removeSparseTerms() from tm. Why would you want to adjust the sparsity of the TDM/DTM?
  
# TDMs and DTMs are sparse, meaning they contain mostly zeros. Remember that 1000 tweets can become a TDM with over 3000 terms! You won't be able to easily interpret a dendrogram that is so cluttered, especially if you are working on more text.

# In most professional settings, a good dendrogram is based on a TDM with 25 to 70 terms. Having more than 70 terms may mean the visual will be cluttered and incomprehensible. Conversely, having less than 25 terms likely means your dendrogram may not plot relevant and insightful clusters.

# When using removeSparseTerms(), the sparse parameter will adjust the total terms kept in the TDM. The closer sparse is to 1; the more terms are kept. This value represents a percentage cutoff of zeros for each term in the TDM.

# Print the dimensions of tweets_tdm
dim(tweets_tdm)

# Create tdm1
tdm1 <- removeSparseTerms(tweets_tdm ,sparse = 0.95)

# Create tdm2
tdm2 <- removeSparseTerms(tweets_tdm ,sparse = 0.975)

# Print tdm1
tdm1

# Print tdm2
tdm2

##  The dendrogram can show you insightful clusters of words amid a sea of information.
# Create tweets_tdm2
tweets_tdm2 <- removeSparseTerms(tweets_tdm, sparse = 0.975)

# Create tdm_m
tdm_m <- as.matrix(tweets_tdm2)

# Create tweets_dist
tweets_dist <- dist(tdm_m)

# Create hc
hc <- hclust(tweets_dist)

# Plot the dendrogram
plot(hc)

## == Dendrogram aesthetics
#So you made a dendrogram…but it's not as eye-catching as you had hoped!

#The dendextend package can help your audience by coloring branches and outlining clusters. dendextend is designed to operate on dendrogram objects, so you'll have to change the hierarchical cluster from hclust using as.dendrogram().

#A good way to review the terms in your dendrogram is with the labels() function. It will print all terms of the dendrogram. To highlight specific branches, use branches_attr_by_labels(). First, pass in the dendrogram object, then a vector of terms as in c("data", "camp"). Lastly, add a color such as "blue".

#After you make your plot, you can call out clusters with rect.dendrogram(). This adds rectangles for each cluster. The first argument to rect.dendrogram() is the dendrogram, followed by the number of clusters (k). You can also pass a border argument specifying what color you want the rectangles to be (e.g. "green").

# Create hcd
hcd <- as.dendrogram(hc)

# Print the labels in hcd
labels(hcd)

# Change the branch color to red for "marvin" and "gaye"
hcd_colored <- branches_attr_by_labels(hcd, c("marvin","gaye"), "red")

# Plot hcd_colored
plot(hcd_colored, main = "Better Dendrogram")

# Add cluster rectangles
rect.dendrogram(hcd, k = 2, border = "grey50")

## == Using word association
# Another way to think about word relationships is with the findAssocs() function in the tm package. For any given word, findAssocs() calculates its correlation with every other word in a TDM or DTM. Scores range from 0 to 1. A score of 1 means that two words always appear together in documents, while a score approaching 0 means the terms seldom appear in the same document.

#Keep in mind the calculation for findAssocs() is done at the document level. So for every document that contains the word in question, the other terms in those specific documents are associated. Documents without the search term are ignored.

#To use findAssocs() pass in a TDM or DTM, the search term, and a minimum correlation. The function will return a list of all other terms that meet or exceed the minimum threshold.

#findAssocs(tdm, "word", 0.25)
#Minimum correlation values are often relatively low because of word diversity. Don't be surprised if 0.10 demonstrates a strong pairwise term association.

#The coffee tweets have been cleaned and organized into tweets_tdm for the exercise. You will search for a term association, and manipulate the results with list_vect2df() from qdap and then create a plot with the ggplot2 code in the example script.

## == N-grams tokenization
# Changing n-grams
#So far, we have only made TDMs and DTMs using single words. The default is to make them with unigrams, but you can also focus on tokens containing two or more words. This can help extract useful phrases that lead to some additional insights or provide improved predictive attributes for a machine learning algorithm.

#The function below uses the RWeka package to create trigram (three word) tokens: min and max are both set to 3.

#tokenizer <- function(x) {
#  NGramTokenizer(x, Weka_control(min = 3, max = 3))
#}
#Then the customized tokenizer() function can be passed into the TermDocumentMatrix or DocumentTermMatrix functions as an additional parameter:
  
#  tdm <- TermDocumentMatrix(
#    corpus, 
#    control = list(tokenize = tokenizer)
#  )

# Make tokenizer function 
tokenizer <- function(x) {
  NGramTokenizer(x, Weka_control(min = 2, max = 2))
}

# Create unigram_dtm
unigram_dtm <- DocumentTermMatrix(text_corp)

# Create bigram_dtm
bigram_dtm <- DocumentTermMatrix(
  text_corp,
  control = list(tokenize = tokenizer)
)

# Print unigram_dtm
unigram_dtm

# Print bigram_dtm
bigram_dtm

## == How do bigrams affect word clouds?
#Now that you have made a bigram DTM, you can examine it and remake a word cloud. The new tokenization method affects not only the matrices but also any visuals or modeling based on the matrices.

#Remember how "Marvin" and "Gaye" were separate terms in the chardonnay word cloud? Using bigram, tokenization grabs all two-word combinations. Observe what happens to the word cloud in this exercise.

#This exercise uses str_subset from stringr. Keep in mind, other DataCamp courses cover regular expressions in more detail. As a reminder, the regular expression ^ matches the starting position within the exercise's bigrams.

# Create bigram_dtm_m
bigram_dtm_m <- as.matrix(bigram_dtm)

# Create freq
freq <- colSums(bigram_dtm_m)

# Create bi_words
bi_words <- names(freq)

# Examine part of bi_words
str_subset(bi_words, "^marvin")

# Plot a word cloud
wordcloud(bi_words, freq, max.words = 15)

## == Changing frequency weights
# So far, you've simply counted terms in documents in the DocumentTermMatrix or TermDocumentMatrix. In this exercise, you'll learn about TfIdf weighting instead of simple term frequency. TfIdf stands for term frequency-inverse document frequency and is used when you have a large corpus with limited-term diversity.

#TfIdf counts terms (i.e. Tf), normalizes the value by document length and then penalizes the value the more often a word appears among the documents. This is common sense; if a word is commonplace, it's important but not insightful. This penalty aspect is captured in the inverse document frequency (i.e., Idf).

#For example, reviewing customer service notes may include the term "cu" as shorthand for "customer". One note may state "the cu has a damaged package" and another as "cu called with question about delivery". With document frequency weighting, "cu" appears twice, so it is expected to be informative. However, in TfIdf, "cu" is penalized because it appears in all the documents. As a result, "cu" isn't considered novel, so its value is reduced towards 0, which lets other terms have higher values for analysis.

# Create a TDM
tdm <- TermDocumentMatrix(text_corp)

# Convert it to a matrix
tdm_m <- as.matrix(tdm)

# Examine part of the matrix
tdm_m[c("coffee", "espresso", "latte"), 161:166]

# Edit the controls to use Tfidf weighting
tdm <- TermDocumentMatrix(text_corp,
                          control = list(weighting = weightTfIdf))

# Convert to matrix again
tdm_m <- as.matrix(tdm)

# Examine the same part: how has it changed?
tdm_m[c("coffee", "espresso", "latte"), 161:166]

# Result:  Using TF weighting, coffee has a score of 1 in all tweets, which isn't that interesting. Using Tf-Idf, terms that are important in specific documents have a higher score.

## == Capturing metadata in tm
#Depending on what you are trying to accomplish, you may want to keep metadata about the document when you create a corpus.

#To capture document-level metadata, the column names and order must be:
  
#doc_id - a unique string for each document
#text - the text to be examined
#... - any other columns will be automatically cataloged as metadata.
#Sometimes you will need to rename columns in order to fit the expectations of DataframeSource(). The names() function is helpful for this.

#tweets exists in your worksapce as a data frame with columns "num", "text", "screenName", and "created".

# Rename columns
names(tweets)[1] <- "doc_id"

# Set the schema: docs
docs <- DataframeSource(tweets)

# Make a clean volatile corpus: text_corpus
text_corpus <- clean_corpus(VCorpus(docs))

# Examine the first doc content
content(text_corpus[[1]])

# Access the first doc metadata
meta(text_corpus[1])
