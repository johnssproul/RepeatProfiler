#!/usr/bin/env Rscript

#setwd("/Users/Anya/Documents/GitHub/SproulProject/archives/scriptTest23_edits/scripts")

args = commandArgs(trailingOnly=TRUE)

library(ggplot2)
library(scales)

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x,header=T)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

The_path = getwd()
all_depth_csv = multmerge("temp_cvs")

vector_of_averages <- c()
refrencce_length <- NROW(all_depth_csv)

name<-args[1]
#name <- "aeruginosum_LIB0206ScoreAdaptTrimDeNovoRibosomalComplex_contig_690.fa_001"
name_first <- strsplit(name, "_")
name_first <- name_first[[1]]
name_first <- as.numeric(name_first[length(name_first)])

Read1_first = index_conv[name_first,1]
Read2_first = index_conv[name_first,2]

if(Read1_first != Read2_first){
  Title = paste(args[1], "                 ", "Read1:",Read1_first, "    Read2:", Read2_first,sep = "")
}else if(Read1_first == Read2_first){
  Title = paste(args[1], "                 ", "Read:",Read1_first)
}

for (i in 2:NCOL(all_depth_csv)) {
 v <- as.vector(all_depth_csv[,i])
 sum_coverage <- sum(as.numeric(v), na.rm = TRUE)
 vector_of_averages[i-1] <- sum_coverage/refrencce_length
}

data <- summary(vector_of_averages)
The_midpoint = as.numeric(data[5])
Depth_column=make.names(args[1])

#Depth_column = "aeruginosum_LIB0206ScoreAdaptTrimDeNovoRibosomalComplex_contig_690.fa_005"

df1 <- subset(all_depth_csv, select = c("Position", Depth_column))
colnames(df1)[2] <- "Depth"


########## Plot 1 :: Horizontal Color Ramp ##########
print('Plot 1 :: Horizontal Color Ramp')

#TODO <-- figure out how to make values and rescaler on the same scale using quartiles
#scaledVals <- c(0, 0.25, 0.75, 0.8, 1.0)
#rs <- rescale(df1$Depth, to = c(0, 1)) #rescale values of position to be in range 0-1
colors <- c("blue", "green3", "yellow", "orange", "red") #set colors for gradient

#sets the aesthetics of the colorbar
Lbreak <- c(0, data[2], data[5], data[6], length(df1$Depth)) #sets position of breaks on colorbar
l2 <- round(as.numeric(data[2]),0) #sets second break at Q1 of averages
l3 <- round(as.numeric(data[5]),0) #sets third break at Q3 of averages
l4 <- round(as.numeric(data[6]),0) #sets fourth break at max of averages
l5 <- round(length(df1$Depth),0) #sets last break at maximum depth
Llabels <-  c(0, l2, l3, l4, l5) #creates vector of labels

horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
  geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = "identity", width = 1.0)+
  scale_colour_gradientn(name = "Depth", breaks = Lbreak, labels = Llabels, colours = colors, guide = "colourbar", aesthetics = c("colour", "fill"))+ #use custom colors with custom scale, I think
  #scale_color_gradientn(name = "Depth", colours = colors, guide = "colourbar")+
  #uses the midpoint of the data to exstablish the reference point for the gradient.
  #scale_color_gradient2(low = "blue", mid = "green", high = "red", midpoint = The_midpoint/2)+
  #scale_fill_gradient2(low = "blue", mid = "green", high = "red", midpoint = The_midpoint/2)+
      #midpoint = max(Df2[2])/2)+
  #coord_cartesian(xlim = c(0, length(df1$Position)), ylim = c(0, length(df1$Depth)))+  #sets axis range based on data
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
  ggtitle(Title)

print(horizontalPlot)

Plot1name = paste(as.character(args[1]), "/X1.png", sep="")
ggsave(as.character(Plot1name), horizontalPlot, units = "mm", width = 175, height = 50)
horizontalPlot
########## Good Above ##########

########## Plot 2 :: Vertical Color Ramp ##########
print('Plot 2 :: Vertical Color Ramp')

#defines a function for vals needed by Plot2
vals.fun<-function(y){
  seq(0, y, by=20)
}

vals <- lapply(df1[[2]], vals.fun)
head(vals)
y <- unlist(vals)
mid <- rep(df1$Position, lengths(vals))
df2 <- data.frame(x = mid-0.4, xend = mid+0.4, y = y, yend = y)

verticalPlot<-ggplot(data = df2, aes(x = x, xend = xend, y = y, yend = yend, color = y))+
  geom_segment(size = 2)+
  scale_color_gradientn(name = "Depth", colours = colors, guide = "colourbar")+
  xlab("Position")+ #rename x axis
  ylab("Depth")+ #rename y axis
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
  ggtitle(Title)

print(verticalPlot)

Plot2name = paste(as.character(args[1]), "/X2.png", sep="")
ggsave(as.character(Plot2name), verticalPlot, units = "mm", width = 175, height = 50)
verticalPlot
########## Good Above ##########

#TODO <-- (is this still an issue?) I tried to make plot 3 smoother by extending the window to 25. The window size should really be calculated individually for each reference based on the total length of the reference in order to keep graphics consistent looking
########## Plot 3 :: Preparations ##########

if(data[6] < 500) {
  #defines fun.split function that partitions the data into bins of size 10
  #bin size can be increased or decreased based on reference length
  df3.1 <- df1[2]
  fun.split <- function(x) {
    split(x, ceiling(seq_along(x)/25))
  }

  #use lapply to loop through each vector in df1 and execute the function, fun.split
  #this will split each vector into bins with the specified value in each bin.
  df3.2 <- lapply(df3.1, fun.split)
  print(df3.2)

  ##loops through the bins in df3.2 and returns a mean for each bin
  sp.names3 <- names(df3.2) #makes an object that consists of the names in df3.2, which are the species names
  means3 <- as.list(rep(NA, length(sp.names3))) #makes an empty list the same length as sp.names; rep replicates the data --> so this line (I think) is making a list with the same length as depth3, but all the values are NA
  names(means3) <- names(df3.2) #sets names in means3 to same as those in df3.2

  #loops through the bins in df3.2 and returns a mean for each bin
  for (i in 1:length(df3.2)) {
    means3[[i]] <- sapply(df3.2[[i]],mean)
  }

  #creates a vector for positions
  pos <- NULL
  for (i in 1:length(df3.2$Depth)) {
    pos[i] <- (i*25)
  }

  #converts means3 to data frame and adds position column
  means3.df <- data.frame(means3, check.rows = TRUE,fix.empty.names = FALSE)
  means3.df$Position <- pos
  names(means3.df)[1] <- paste("Depth")

  plot3data <- means3.df
} else {
  plot3data <- df1
}

########## Plot 3 :: Solid Plot ##########
print('Plot 3 :: Solid Plot')

#TODO <-- do you want the solid plot to be a pdf?
#pdf(file ="DepthPlot3.pdf", width=900, height=300)

solidPlot <- ggplot(data=plot3data, aes(x=Position, y=Depth))+
  geom_area(fill="royalblue3")+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
  ggtitle(Title)

print(solidPlot)

Plot3name = paste(as.character(args[1]), "/X3.png", sep="")
ggsave(as.character(Plot3name), solidPlot, units = "mm", width = 175, height = 50)
solidPlot
########## Good Above ##########