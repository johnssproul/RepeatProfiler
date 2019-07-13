args = commandArgs(trailingOnly = TRUE)

library(ggplot2)
library(reshape2)
library(ggpubr)


#multi_poly_names <- read.table("./Wed_Jul_10_08:09:48_EDT_2019/REsat1.fa_output/multi_poly_names.txt", header = TRUE, stringsAsFactors = FALSE) #path-specific
multi_poly_names <- read.table("multi_poly_names.txt", header = TRUE, stringsAsFactors = FALSE)

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors=FALSE)

#determines number of plots per page based on number of samples; this can be changed however you want it
l <- length(multi_poly_names$name_poly)
if (l < 16) {
  n <- l
} else {
  n <- l/2
}

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

  #name_of_table_used <- paste("./Wed_Jul_10_08:09:48_EDT_2019/REsat1.fa_output/multi_poly/", multi_poly_names[i,1], ".txt", sep = "") #path-specific
  name_of_table_used <- paste("multi_poly/", multi_poly_names[i,1], ".txt", sep = "")

  base_counts <- read.table(name_of_table_used,header = TRUE)
  head(base_counts[1])

  base_countsRed <- base_counts[1:6]
  head(base_countsRed)

  #makes a stacked bar chart taken form: https://stackoverflow.com/questions/21236229/stacked-bar-chart
  #melt takes data with the same position and stacks it as a set of columns into a single column of data
  base_countsRed.m <- melt(base_countsRed, id.vars = "Position")
  head(base_countsRed.m)
  colnames(base_countsRed.m)[2] <- "Bases"
  colnames(base_countsRed.m)[3] <- "Depth"

  length(base_countsRed.m$variable)

  polymorphPlot <- ggplot(base_countsRed.m, aes(x = Position, y = Depth, fill = Bases, alpha = Bases))+
    geom_bar(stat = 'identity', width = 1.0)+
    scale_fill_manual(values = c("gray", "red", "blue", "yellow", "green"))+
    scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
    ggtitle(Title)

  #print(polymorphPlot)

  Plots_list[[i]] <- polymorphPlot
}

All_plots <- ggarrange(plotlist = Plots_list, nrow = n, ncol = 1, align = "hv", common.legend = TRUE)
ggexport(All_plots, filename = "combined_variation_plots.pdf", width = 25, height = 25)