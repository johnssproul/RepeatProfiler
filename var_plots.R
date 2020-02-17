#!/usr/bin/env Rscript

##### This script (called in 'repeatprof') plots depth profiles with a visual summarize variants at each position along the reference sequence.
##### It is similar to multi_var_plots.R, but this code outputs individual plots, whereas the other outputs multi-plot PDFs


args <- commandArgs(trailingOnly = TRUE)
#args[1] <- 'erecta_CL1_TR_1_x_181_0nt.fa_011' #testing

##### print statements and defining variables

cat('Saving variation plot... \n')

#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)


ft <- '.pdf'

#code if file type specified
# if(is.null(args[3]) || is.na(args[3])) {
#   ft <- '.png'
# } else if (grepl('.', args[3], fixed = TRUE)){
#   ft <- args[3]
# } else {
#   print('Invalid input. Setting file type to default: '.png'')
# }

#objects for handling low coverage plots
#img <- png::readPNG('./images-RP/watermark.png')
#wm <- ggpubr::background_image(img) #for watermark
cap <- labs(caption = 'This graph has no coverage.') #sets caption for low coverage plots

index.conv <- read.table('index_conv.txt', header = TRUE, stringsAsFactors = FALSE) #reads text file containing names of reads

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
#base.counts <- read.table('./erecta_CL1_TR_1_x_181_0nt.fa_output/erecta_CL1_TR_1_x_181_0nt.fa_011/depth_counts.txt', header = TRUE) #testing
base.counts <- read.table('depth_counts.txt', header = TRUE)
head(base.counts[1])

#creates new dataframe based on base.counts, but not including depth column
base.countsRed <- base.counts[1:6]
head(base.countsRed)

#makes a stacked bar chart based on: https://stackoverflow.com/questions/21236229/stacked-bar-chart
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
  theme(legend.text = element_text(size = 6))+ #formats legend
  ggtitle(t)

#low coverage cases
if(max(base.counts$Depth) < 1) {
  polymorphPlot <- polymorphPlot+ cap
}

#polymorphPlot #testing

#plot.name <- paste('./Test_plots/variant_profile', ft, sep = '') #testing
plot.name <- paste('variant_profile', ft, sep = '')
ggsave(as.character(plot.name), polymorphPlot, units = 'mm', width = 175, height = 50)
cat('file saved to ',  plot.name, '\n')

##### end script