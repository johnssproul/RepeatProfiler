#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)
#args[1] <- "dmel_rDNA_ETS_Other_rDNA.fa_001" #path-specific

#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)
library(reshape2)


index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

name <- args[1]
name_first <- strsplit(name, "_")
name_first <- name_first[[1]]
name_first <- as.numeric(name_first[length(name_first)])

Read1_first = index_conv[name_first,1]
Read2_first = index_conv[name_first,2]

if(Read1_first != Read2_first){
  Title = paste(args[1], "   Read1: ", Read1_first, "   Read2: ", Read2_first,sep = "")
} else if(Read1_first == Read2_first){
  Title = paste(args[1], "   Read: ", Read1_first)
}

#base_counts <- read.table("./Mon_Jul_15_15:59:55_EDT_2019-RepeatProfiler/dmel_rDNA_ETS_Other_rDNA.fa_output/dmel_rDNA_ETS_Other_rDNA.fa_001/pileup_counted.txt", header = TRUE) #path-specific
base_counts <- read.table("pileup_counted.txt", header = TRUE)
head(base_counts[1])

base_countsRed <- base_counts[1:6]
head(base_countsRed)

#makes a stacked bar chart taken from: https://stackoverflow.com/questions/21236229/stacked-bar-chart
#melt takes data with the same position and stacks it as a set of columns into a single column of data
base_countsRed.m <- melt(base_countsRed, id.vars = "Position")
head(base_countsRed.m)
colnames(base_countsRed.m)[2] <- "Bases"
colnames(base_countsRed.m)[3] <- "Depth"

length(base_countsRed.m$Bases)

polymorphPlot <- ggplot(base_countsRed.m, aes(x = Position, y = Depth, fill = Bases, alpha = Bases))+
  geom_bar(stat = 'identity', width = 1.0)+
  scale_fill_manual(values = c("gray", "red", "blue", "yellow", "green"))+
  scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(size = 6, face = "bold"), axis.title = element_text(size = 6))+
  ggtitle(Title)

PlotRname = paste("Variation_plot.png", sep="")
ggsave(as.character(PlotRname), polymorphPlot, units = "mm", width = 175, height = 50)
cat("file saved to",  PlotRname)
