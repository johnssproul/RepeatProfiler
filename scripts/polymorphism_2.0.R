#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library (ggplot2)
#need to update path
#setwd("/Users/johnsproul/Documents/NSF_Postdoc/Computational_Biology/RepeatProfiler")

index_conv<-read.table("Index_conv.txt",header = TRUE,stringsAsFactors=FALSE)

name<-args[1]
name_first<-strsplit(name,"_")
name_first<-name_first[[1]]
name_first<-as.numeric(name_first[length(name_first)])


Read1_first=index_conv[name_first,1]
Read2_first=index_conv[name_first,2]

if(Read1_first!=Read2_first){
  
  Title=paste(args[1],"                 ","Read1:",Read1_first,"    Read2:",Read2_first,sep = "")
}else if(Read1_first==Read2_first){
  
  Title=paste(args[1],"                 ","Read:",Read1_first)
  
  
}



#need to update path

base_counts<-read.table("pileup_counted.txt",header=TRUE)
head(base_counts[1])






base_countsRed<-base_counts[1:6]
head(base_countsRed)


library(reshape2)
base_countsRed.m<-melt(base_countsRed, id.vars = "Position")

head(base_countsRed.m)
 
length(base_countsRed.m$variable)
#Makes a stacked bar chart taken from: https://stackoverflow.com/questions/21236229/stacked-bar-chart
#need to figure out how to make all bases matching reference sequence be same color (gray)

myPlot <- ggplot(base_countsRed.m, aes(x = Position, y = value, fill = variable, alpha = variable)) +
  geom_bar(stat='identity')+
  scale_fill_manual(values=c("gray","red", "blue", "yellow", "green"))+
  scale_alpha_manual(values=c(0.35, 1.0, 1.0, 1.0, 1.0))+
  #removes gray background
  theme_bw()+
  #To remove gridlines:
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ ggtitle(Title)

print(myPlot)
