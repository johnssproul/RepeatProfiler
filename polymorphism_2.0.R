#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
#args[1] <- 'erecta_CL9_TR_1_x_6687_0nt.fa_001' #path-specific
cat('Plotting Variation Graph... \n')

library(ggplot2)

#.libPaths(as.character(args[2])) #brew stuff

#code if file type specified
if(is.null(args[2]) || is.na(args[2])) {
  ft <- '.png'
} else if (grepl('.', args[2], fixed = TRUE)){
  ft <- args[2]
} else {
  print('Invalid input. Setting file type to default: ".png"')
  ft <- '.png'
}

#reads textfile containing names of reads
index.conv <- read.table('Index_conv.txt', header = TRUE, stringsAsFactors = FALSE)

#gets names of reads and stores as objects to be used for title
name <- args[1]
name.first <- strsplit(name, '_')
name.first <- name.first[[1]]
name.first <- as.numeric(name.first[length(name.first)])

read1.first <- index.conv[name.first,1]
read2.first <- index.conv[name.first,2]

if(read1.first != read2.first){
  t <- paste(args[1], '   Read1: ', read1.first, '   Read2: ', read2.first,sep = '')
} else if(read1.first == read2.first){
  t <- paste(args[1], '   Read: ', read1.first, sep = '')
}

#creates dataframe of counts for bases
#base.counts <- read.table('./erecta_CL9_TR_1_x_6687_0nt.fa_output/erecta_CL9_TR_1_x_6687_0nt.fa_001/pileup_counted.txt', header = TRUE) #path-specific
base.counts <- read.table('pileup_counted.txt', header = TRUE)
head(base.counts[1])

#creates new dataframe based on base.counts, but not including depth column
base.countsRed <- base.counts[1:6]
head(base.countsRed)

#makes a stacked bar chart taken from: https://stackoverflow.com/questions/21236229/stacked-bar-chart
#melt takes data with the same position and stacks it as a set of columns into a single column of data
base.countsRed.m <- reshape2::melt(base.countsRed, id.vars = 'Position')
head(base.countsRed.m)
colnames(base.countsRed.m)[2] <- 'Bases'
colnames(base.countsRed.m)[3] <- 'Depth'

length(base.countsRed.m$Bases)

polymorphPlot <- ggplot(base.countsRed.m, aes(x = Position, y = Depth, fill = Bases, alpha = Bases))+
  geom_bar(stat = 'identity', width = 1.0)+
  scale_fill_manual(values = c('gray', 'red', 'blue', 'yellow', 'green'))+
  scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6))+
  ggtitle(t)

#polymorphPlot #testing

#PlotRname <- paste('./Test_plots/Variation_plot', ft, sep='') #path-specific
PlotRname <- paste('Variation_plot', ft, sep='')
ggsave(as.character(PlotRname), polymorphPlot, units = 'mm', width = 175, height = 50)
cat('file saved to',  PlotRname, '\n')
