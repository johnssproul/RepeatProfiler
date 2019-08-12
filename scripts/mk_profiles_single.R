#!/usr/bin/env Rscript

##### The script (called by 'repeatprof') makes color gradient read depth profiles as the program loops through each set of reads for each reference.
##### The code is similar to the All_RP_graphs* scripts, except that they make multi-plot PDFs after all sample have run, whereas this makes individual plots.


args <- commandArgs(trailingOnly = TRUE)
#args[1] <- 'dmel_rDNA_ETS_Other_rDNA.fa_001' #testing

cat('Rscript mk_profiles for singlecopy.R started: ', args[1], '\n')

#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)

Normalized <- as.character(args[3]) #change it to args[3] when brew prep
print(Normalized)
plot_yaxis<-"Depth"
ft <- '.pdf'
#code if file type specified
# if(is.null(args[3]) || is.na(args[3])) {
#   ft <- '.png'
# } else if (grepl('.', args[3], fixed = TRUE)){
#   ft <- args[3]
# } else {
#   print('Invalid input. Setting file type to default: '.png'')
#   ft <- '.png'
# }

#img <- png::readPNG('./images-RP/watermark.png') #get watermark image


########## Preparing Dataframe ##########
#merges all files located in 'mypath' into one dataframe
multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

#index.conv <- read.table('../index_conv.txt', header = TRUE, stringsAsFactors = FALSE) #testing
index.conv <- read.table('index_conv.txt', header = TRUE, stringsAsFactors = FALSE) #reads textfile containing names of reads
all.depth.csv <- multmerge('single_cvs')

plot_yaxis<-"Singlegene_coverage"



# all.depth.csv<-cbind(Position=all.depth.csv[,1],all.depth.csv[,2:NCOL(all.depth.csv)]/Normalized)
# all.depth.csv<-all.depth.csv[,1:NCOL(all.depth.csv)]/Normalized
# all.depth.csv$Position<-all.depth.csv$Position*Normalized

#gets names of reads

for(x in 2:NCOL(all.depth.csv)){

name <- colnames(all.depth.csv)[x]
name.first <- strsplit(name, '_')
name.first <- name.first[[1]]
name.first <- as.numeric(name.first[length(name.first)])

read1.first <- index.conv[name.first,1]
read2.first <- index.conv[name.first,2]

print(read1.first)

if(read1.first != read2.first){
  t <- paste(args[1], '   Read1: ', read1.first, '   Read2: ', read2.first, sep = '')
}else if(read1.first == read2.first){
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

#max <- 2718 #testing - standard scale 44662 2718

depth.column <- make.names(name) #gets name of sample to be used when subsetting data

#subsets all.depth.csv into dataframe containing position and depth for only one read
df1 <- subset(all.depth.csv, select = c('Position', depth.column))
df1 <- na.omit(df1)
colnames(df1)[2] <- plot_yaxis
df1.max <- max(df1$Singlegene_coverage)

#determines bin split based on number of positions; this n value is used for vertical gradient plot and the solid plot
if ((length(df1$Position) < 500) || df1.max < 1500){
  n <- 1
} else if (df1.max < 5000){
  n <- 5
} else if (df1.max < 10000){
  n <- 10
} else if (df1.max < 15000){
  n <- 20
} else if (df1.max < 20000){
  n <- 40
} else if (df1.max < 40000){
  n <- 70
} else {
  n <- 100
}

#defines a function to check and handle low coverage
lc <- function(plot) {
  if(df1.max < 1) {
    plot <- plot+ cap
  } else {
    plot <- plot
  }
}

########## Plot Aesthetics ##########
colors <- c('blue4', 'springgreen2', 'yellow', 'orange', 'red', 'red') #sets color scheme for gradient
cs <- scale_colour_gradientn(name = plot_yaxis, values = c(0, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = c('colour', 'fill')) #sets color gradient environment for gradient plots (horizontal and vertical)
tf <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
        plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6)) #formats plot title
tl <- theme(legend.text = element_text(size = 6)) #formats legend
cap <- labs(caption = 'This graph has no coverage.') #sets caption for low coverage plots
#wm <- ggpubr::background_image(img) #for watermark




########## Preparing Solid Plot Data ##########
cat('Preparing solid plot data... \n')

df3.1 <- df1[2] #create new dataframe containing just depth column

#defines a function that partitions the data into bins of size n
fun.split <- function(x) {
  split(x, ceiling(seq_along(x)/n))
}

if(n != 1) {
  df3.2 <- lapply(df3.1, fun.split) #use lapply to loop through each vector in df3.1, apply fun.split, and create a vector of lists
  sp.names3 <- names(df3.2)
  means3 <- as.list(rep(NA, length(sp.names3))) #rep replicates the data --> so this line (I think) is making a list with the same length as depth3, but all the values are NA
  names(means3) <- names(df3.2)

  #loops through the bins in df3.2 and returns a mean for each bin
  for (i in 1:length(df3.2)) {
    means3[[i]] <- sapply(df3.2[[i]], mean)
  }

  df3 <- data.frame(means3, check.rows = TRUE, fix.empty.names = FALSE)
} else {
  df3 <- df3.1
}

#creates a vector for positions and adds to df3
pos <- NULL
for (i in 1:length(df3$Singlegene_coverage)) {
  pos[i] <- (i*n)
}

df3$Position <- pos


########## Solid Plot ##########
cat('Saving solid plot... \n')

solidPlot <- ggplot(data = df3, aes(x = Position, y = Singlegene_coverage))+
  geom_area(fill = 'blue4')+
  theme_bw()+
  tf+ tl+ ggtitle(t)

solidPlot <- lc(solidPlot);

#solidPlot #testing

#plot3name <- paste('/Volumes/SamsungUSB/RP_test/Validation_010819_scaled/Test_plots/Solid', ft, sep = '') #testing
plot3name <- paste(as.character("plots_single_copy"), '/',name, ft, sep='')
ggsave(as.character(plot3name), solidPlot, units = 'mm', width = 175, height = 50)
cat('file saved to ',  plot3name, '\n')
}