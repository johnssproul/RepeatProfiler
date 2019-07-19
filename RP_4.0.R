#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
#args[1] <- 'NC_024511_2_Drosophila_melanogaster_mitochondrion__complete_genome.fa_005' #path-specific

#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)



#code if file type specified
if(is.null(args[3]) || is.na(args[3])) {
  ft <- '.png'
} else if (grepl('.', args[3], fixed = TRUE)){
  ft <- args[3]
} else {
  print('Invalid input. Setting file type to default: ".png"')
  ft <- '.png'
}

#get watermark image
img <- png::readPNG('./images/watermark.png')

########## Preparing Dataframe ##########
cat('Rscript RP_4.0.R started: ', args[1], '\n')

#merges all files located in 'mypath' into one dataframe
multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

#reads textfile containing names of reads
index.conv <- read.table('Index_conv.txt', header = TRUE, stringsAsFactors = FALSE)

#multimerge files in temp_cvs directory
all.depth.csv <- multmerge('temp_cvs')

#gets names of reads
name <- args[1]
name.first <- strsplit(name, '_')
name.first <- name.first[[1]]
name.first <- as.numeric(name.first[length(name.first)])

read1.first <- index.conv[name.first,1]
read2.first <- index.conv[name.first,2]

if(read1.first != read2.first){
  t <- paste(args[1], '   Read1: ', read1.first, '   Read2: ', read2.first, sep = '')
}else if(Read1.first == Read2.first){
  t <- paste(args[1], '   Read: ', read1.first, sep = '')
}

#standard scale based on calculations of maximum depth from all.depth.csv dataframe
max <- 0
for (i in 2:NCOL(all.depth.csv)) {
  v <- as.vector(all.depth.csv[,i])
  v <- na.omit(v)
  max.column <- max(as.numeric(v))

  if(max.column > max) {
    max <- max.column
  }
}

#gets name of sample to be used when subsetting data
depth.column <- make.names(args[1])

#subsets all.depth.csv into dataframe containing position and depth for only one read
df1 <- subset(all.depth.csv, select = c('Position', depth.column))
df1 <- na.omit(df1)
colnames(df1)[2] <- 'Depth'
df1.max <- max(df1$Depth)

#determines bin split based on number of positions; this n value is used for vertical gradient plot and the solid plot
#alternative condition: ((length(df1$Position) + df1.max) < 1300)
if ((length(df1$Position) < 300) || df1.max < 1000){
  n <- 1
} else {
  n <- 10
}


########## Plot Aesthetics ##########
colors <- c('blue4', 'springgreen2', 'yellow', 'orange', 'red', 'red') #sets color scheme for gradient
cs <- scale_colour_gradientn(name = 'Depth', values = c(0, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = c('colour', 'fill')) #sets color gradient environment for gradient plots (horizontal and vertical)
tf <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
        plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6)) #formats plot title
cap <- labs(caption = 'The coverage of this graph is too low to properly plot it.') #sets caption for low coverage plots
wm <- ggpubr::background_image(img) #for watermark


########## Horizontal Gradient Plot ##########
cat('Saving horizontal gradient plot... \n')

horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
  geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = 'identity', width = 1.0)+
  cs+ theme_bw()+ #to remove grey background
  tf+ ggtitle(t) #sets plot title

#low coverage marker
if(df1.max < 1) {
  horizontalPlot <- horizontalPlot+ wm+ cap
}

#horizontalPlot #testing

#plot1name <- paste('./Test_plots/Horizontal_gradient', ft, sep = '') #path-specific
plot1name <- paste(as.character(args[1]), '/Horizontally_colored', ft, sep='')
ggsave(as.character(plot1name), horizontalPlot, units = 'mm', width = 175, height = 50)
cat('file saved to',  plot1name, '\n')


########## Preparing Vertical Gradient Data ##########
cat('Preparing vertical gradient plot data... \n')
#defines a function that splits the depth for vertical plot by=n
vals.fun <- function(y){
  seq(0, y, by = n)
}

#applies vals.fun function (defined above) to df1[[2]] (= depth) and store in vals (a vector of lists)
vals <- lapply(df1[[2]], vals.fun)

#unlists vals to make y a vector of numbers (because vals is a list of lists, rather than a single vector)
y <- unlist(vals)

#creates object pos which has the same length as y (all elements of each list in vals) and has respective (and extrapolated) values from df1$Position
pos <- rep(df1$Position, lengths(vals))

#creates dataframe setting datapoints for each rectangle that will be colored in vertical graph (x and xend define length of segment, y and y end define height of segment)
if(df1.max > 10) {
  df2 <- data.frame(x = pos-1, xend = pos, y = y-1, yend = y)
} else {
  df2 <- data.frame(x = pos, xend = pos, y = 0, yend = y)
}

#since x=pos-1 and y=y-1, goes through df2 and sets any x=-1 or y=-1 values to 0 (otherwise the axes would start at -1 and be grey)
for(i in 1:length(df2$x)) {
  if(df2$y[[i]] < 0) {
    df2$y[[i]] <- 0
  }
  if(df2$x[[i]] < 0) {
    df2$x[[i]] <- 0
  }
}

#sets size of segment based on maximum depth of sample (reduces vertical lines)
if(df1.max > 400) {
  s <- .3
} else if (df1.max > 30){
  s <- 1
} else {
  s <- 2
}

#renames columns 1 and 3 in df2 so that the x-axis and y-axis are labelled correctly
colnames(df2)[1] <- 'Position'
colnames(df2)[3] <- 'Depth'


########## Vertical Gradient Plot ##########
cat('Saving vertical gradient plot... \n')

verticalPlot <- ggplot(data = df2)+
  geom_segment(aes(x = Position, xend = xend, y = Depth, yend = yend, color = Depth), size = s)+
  cs+ theme_bw()+ #to remove grey background
  tf+ ggtitle(t) #sets plot title

#low coverage marker
if(df1.max < 1) {
  verticalPlot <- verticalPlot+ wm+ cap
}

#verticalPlot #testing

#plot2name <- paste('./Test_plots/Vertical_gradient', ft, sep = '') #path-specific
plot2name <- paste(as.character(args[1]), '/Vertically_colored', ft, sep='')
ggsave(as.character(plot2name), verticalPlot, units = 'mm', width = 175, height = 50)
cat('file saved to',  plot2name, '\n')


########## Preparing Solid Plot Data ##########
cat('Preparing solid plot data... \n')
#create new dataframe containing just depth column
df3.1 <- df1[2]

#defines a function that partitions the data into bins of size n
fun.split <- function(x) {
  split(x, ceiling(seq_along(x)/n))
}

if(n != 1) {
  #use lapply to loop through each vector in df3.1, apply fun.split, and create a vector of lists
  df3.2 <- lapply(df3.1, fun.split)

  #loops through the bins in df3.2 and returns a mean for each bin
  sp.names3 <- names(df3.2)
  means3 <- as.list(rep(NA, length(sp.names3))) #rep replicates the data --> so this line (I think) is making a list with the same length as depth3, but all the values are NA
  names(means3) <- names(df3.2)

  #loops through the bins in df3.2 and returns a mean for each bin
  for (i in 1:length(df3.2)) {
    means3[[i]] <- sapply(df3.2[[i]], mean)
  }

  #converts means3 to data frame
  df3 <- data.frame(means3, check.rows = TRUE, fix.empty.names = FALSE)
} else {
  df3 <- df3.1
}

#creates a vector for positions and adds to df3
pos <- NULL
for (i in 1:length(df3$Depth)) {
  pos[i] <- (i*n)
}

df3$Position <- pos


########## Solid Plot ##########
cat('Saving solid plot... \n')

solidPlot <- ggplot(data = df3, aes(x = Position, y = Depth))+
  geom_area(fill = 'blue4')+
  theme_bw()+ #to remove grey background
  tf+ ggtitle(t)

#low coverage marker
if(df1.max < 1) {
  solidPlot <- solidPlot+ wm+ cap
}

#solidPlot #testing

#plot3name <- paste('./Test_plots/Solid', ft, sep = '') #path-specific
plot3name <- paste(as.character(args[1]), '/solid_colored', ft, sep='')
ggsave(as.character(plot3name), solidPlot, units = 'mm', width = 175, height = 50)
cat('file saved to',  plot3name, '\n')
