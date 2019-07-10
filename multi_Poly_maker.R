#setwd("/Users/Anya/Documents/GitHub/SproulProject/scriptTest23/scripts")

multi_poly_names<-read.table("multi_poly_names.txt", header = TRUE, stringsAsFactors=FALSE)
args = commandArgs(trailingOnly = TRUE)

library(ggplot2)
library(reshape2)
library(ggpubr)
#library(gridExtra)

#TODO <-- need to update path
#setwd("/Users/johnsproul/Documents/NSF_Postdoc/Computational_Biology/RepeatProfiler")

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors=FALSE)

Plots_list <- list()

for (i in 1:NROW(multi_poly_names)) {
  print(i)

  name <- multi_poly_names[i,1]
  name_first <- strsplit(name, "_")
  name_first <- name_first[[1]]
  name_first <- as.numeric(name_first[length(name_first)])

  Read1_first = index_conv[name_first,1]
  Read2_first = index_conv[name_first,2]

  if(Read1_first != Read2_first){
    Title = paste(multi_poly_names[i,1], "                 ", "Read1:", Read1_first, "    Read2:", Read2_first, sep = "")
  }else if(Read1_first == Read2_first){
    Title = paste(multi_poly_names[i,1], "                 ", "Read:", Read1_first)
  }

#TODO <-- need to update path
  name_of_table_used <- paste("multi_poly/", multi_poly_names[i,1], ".txt", sep = "")
  base_counts <- read.table(name_of_table_used,header = TRUE)
  head(base_counts[1])

  base_countsRed <- base_counts[1:6]
  head(base_countsRed)

  #makes a stacked bar chart taken form: https://stackoverflow.com/questions/21236229/stacked-bar-chart
  #melt takes data with the same position and stacks it as a set of columns into a single column of data
  base_countsRed.m <- melt(base_countsRed, id.vars = "Position")
  head(base_countsRed.m)

  length(base_countsRed.m$variable)

  polymorphPlot <- ggplot(base_countsRed.m, aes(x = Position, y = value, fill = variable, alpha = variable))+
    geom_bar(stat = 'identity')+
    scale_fill_manual(values = c("gray","red", "blue", "yellow", "green"))+
    scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
    xlab("Position")+ #rename x axis
    ylab("Depth")+ #rename y axis
    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
    ggtitle(Title)

  print(polymorphPlot)

  Plots_list[[i]] <- polymorphPlot
}

#All_plots <- do.call(grid.arrange,c(Plots_list,ncol=1))
All_plots <- ggarrange(plotlist = Plots_list, nrow = 5, ncol = 1, align = "v", common.legend = TRUE)
#ggsave("all_Poly_reads_graphs_combinded.pdf", All_plots, width = 25, height = 49, units = "in")
ggexport(All_plots, filename = "all_Poly_reads_graphs_combinded.pdf", width = 25, height = 25)

