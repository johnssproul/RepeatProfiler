#!/usr/bin/env Rscript
setwd("/Users/Anya/Documents/GitHub/SproulProject/scriptTest23/scripts")

args = commandArgs(trailingOnly=TRUE)

library (ggplot2)
library(reshape2)
#TODO <-- need to update path
#setwd("/Users/johnsproul/Documents/NSF_Postdoc/Computational_Biology/RepeatProfiler")

index_conv<-read.table("Index_conv.txt",header = TRUE,stringsAsFactors=FALSE)

#name <- args[1]
name <- "aeruginosum_LIB0206ScoreAdaptTrimDeNovoRibosomalComplex_contig_690.fa_001"
name_first <- strsplit(name,"_")
name_first <- name_first[[1]]
name_first <- as.numeric(name_first[length(name_first)])

Read1_first = index_conv[name_first,1]
Read2_first = index_conv[name_first,2]

if(Read1_first != Read2_first){
  Title = paste(args[1],"                 ","Read1:",Read1_first,"    Read2:",Read2_first,sep = "")
}else if(Read1_first == Read2_first){
  Title = paste(args[1],"                 ","Read:",Read1_first)
}

#TODO <-- need to update path
base_counts <- read.table("../test2/ref/sample1/pileup_counted.txt",header=TRUE)
head(base_counts[1])

base_countsRed <- base_counts[1:6]
head(base_countsRed)

#makes a stacked bar chart taken form: https://stackoverflow.com/questions/21236229/stacked-bar-chart
#melt takes data with the same position and stacks it as a set of columns into a single column of data
base_countsRed.m <- melt(base_countsRed, id.vars = "Position")
head(base_countsRed.m)

length(base_countsRed.m$variable)

#TODO <-- (is this still an issue?) need to figure out how to make all bases matching reference sequence be same color (gray)
polymorphPlot <- ggplot(base_countsRed.m, aes(x = Position, y = value, fill = variable, alpha = variable)) +
  geom_bar(stat = 'identity')+
  scale_fill_manual(values = c("gray", "red", "blue", "yellow", "green"))+
  scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
  ggtitle(Title)

print(polymorphPlot)
