#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
#args[1] <- "aeruginosum_LIB0206ScoreAdaptTrimDeNovoMtGenome_contig_565.fa_002" #path-specific

#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)


########## Prepping Data Frame ##########
multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x,header=T)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

all_depth_csv = multmerge("temp_cvs")

name<-args[1]
name_first <- strsplit(name, "_")
name_first <- name_first[[1]]
name_first <- as.numeric(name_first[length(name_first)])

Read1_first = index_conv[name_first,1]
Read2_first = index_conv[name_first,2]

if(Read1_first != Read2_first){
  Title=paste(args[1],"Read1:",Read1_first,"Read2:",Read2_first,sep = " ")
}else if(Read1_first == Read2_first){
  Title=paste(args[1],"Read:",Read1_first,sep = " ")
}


########## Prep for Standard Scale and Data Set ##########
max <- 0
for (i in 2:NCOL(all_depth_csv)) {
  v <- as.vector(all_depth_csv[,i])
  v <- na.omit(v)
  max_column <- max(as.numeric(v))

  if(max_column > max) {
    max <- max_column
  }
}

Depth_column = make.names(args[1])

df1 <- subset(all_depth_csv, select = c("Position", Depth_column))
df1 <- na.omit(df1)
colnames(df1)[2] <- "Depth"

#determines split based on number of positions; this can be changed however you want it -- this n value is also used for plot 3
if ((length(df1$Position) < 1000) || max(df1$Depth) < 800) {
  n <- 1
} else {
  n <- 20
}

colors <- c("blue", "green3", "yellow", "orange", "red", "red")

########## Plot 1 :: Horizontal Color Ramp ##########
print('Plot 1 :: Horizontal Color Ramp')

horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
  geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = "identity", width = 1.0)+
  scale_colour_gradientn(name = "Depth", values = c(0, .20, .30, .50, .80, 1.0), colours = colors, limits = c(0, max), guide = "colourbar")+
  scale_fill_gradientn(name = "Depth", values = c(0, .20, .30, .50, .80, 1.0), colours = colors, limits = c(0, max), guide = "colourbar")+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),plot.title = element_text(size = 5, face = "bold"))+ ggtitle(Title)

#print(horizontalPlot)

#Plot1name = paste("X1.png") #path-specific
Plot1name = paste(as.character(args[1]), "/Horizontally_colored.png", sep="")
ggsave(as.character(Plot1name), horizontalPlot, units = "mm", width = 175, height = 50)
########## Good Above ##########


########## Prep for Plot 2 ##########
#defines a function that splits the data for plot 2 by=n
vals.fun<-function(y){
  seq(0, y, by=n)
}

vals <- lapply(df1[[2]], vals.fun)
head(vals)
y <- unlist(vals)
mid <- rep(df1$Position, lengths(vals))

df2 <- data.frame(x = mid-0.5, xend = mid+0.5, y = y, yend = y)
colnames(df2)[1] <- "Position"
colnames(df2)[3] <- "Depth"


########## Plot 2 :: Vertical Color Ramp ##########
print('Plot 2 :: Vertical Color Ramp')

verticalPlot<-ggplot(data = df2, aes(x = Position, xend = xend, y = Depth, yend = yend, color = Depth))+
  geom_segment(size = 2)+
  scale_colour_gradientn(name = "Depth", values = c(0, .20, .30, .50, .80, 1.0), colours = colors, limits = c(0, max), guide = "colourbar")+
  scale_fill_gradientn(name = "Depth", values = c(0, .20, .30, .50, .80, 1.0), colours = colors, limits = c(0, max), guide = "colourbar")+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),plot.title = element_text(size = 5, face = "bold"))+ ggtitle(Title)

#print(verticalPlot)

#Plot2name = paste("X2.png") #path-specific
Plot2name = paste(as.character(args[1]), "/Vertically_colored.png", sep="")
ggsave(as.character(Plot2name), verticalPlot, units = "mm", width = 175, height = 50)
########## Good Above ##########


#TODO <-- (is this still an issue?) I tried to make plot 3 smoother by extending the window to 25. The window size should really be calculated individually for each reference based on the total length of the reference in order to keep graphics consistent looking
########## Plot 3 :: Preparations ##########
df3.1 <- df1[2]

#defines fun.split function that partitions the data into bins of size n; this can be changed however you want it
fun.split <- function(x) {
  split(x, ceiling(seq_along(x)/n))
}

if(n != 1) {
  #use lapply to loop through each vector in df1 and execute the function, fun.split
  #this will split each vector into bins with the specified value in each bin.
  df3.2 <- lapply(df3.1, fun.split)

  ##loops through the bins in df and returns a mean for each bin
  sp.names3 <- names(df3.2) #makes an object that consists of the names in df3.2, which are the species names
  means3 <- as.list(rep(NA, length(sp.names3))) #makes an empty list the same length as sp.names; rep replicates the data --> so this line (I think) is making a list with the same length as depth3, but all the values are NA
  names(means3) <- names(df3.2) #sets names in means3 to same as those in df3.2

  #loops through the bins in df3.2 and returns a mean for each bin
  for (i in 1:length(df3.2)) {
    means3[[i]] <- sapply(df3.2[[i]], mean)
  }

  #converts means3 to data frame and adds position column
  df3 <- data.frame(means3, check.rows = TRUE, fix.empty.names = FALSE)
} else {
  df3 <- df3.1
}

#creates a vector for positions
pos <- NULL
for (i in 1:length(df3$Depth)) {
  pos[i] <- (i*n)
}

df3$Position <- pos
names(df3)[1] <- paste("Depth")

head(df3)

########## Plot 3 :: Solid Plot ##########
print('Plot 3 :: Solid Plot')

#TODO <-- do you want the solid plot to be a pdf?
#pdf(file ="DepthPlot3.pdf", width=900, height=300)

solidPlot <- ggplot(data = df3, aes(x = Position, y = Depth))+
  geom_area(fill="royalblue3")+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),plot.title = element_text(size = 5, face = "bold"))+ ggtitle(Title)

#print(solidPlot)

#Plot3name = paste("X3.png") #path-specific
Plot3name = paste(as.character(args[1]), "/solid_colored.png", sep="")
ggsave(as.character(Plot3name), solidPlot, units = "mm", width = 175, height = 50)
########## Good Above ##########