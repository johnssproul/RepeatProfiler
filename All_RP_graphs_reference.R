print("this is ALL_RP_GRAPHS_REFRERENCE")

#setwd("/Users/Anya/Documents/GitHub/SproulProject/scriptTest23/scripts")

library(ggplot2)
library(scales)
library(ggpubr)
#library(gridExtra)

multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x,y,all = TRUE)}, datalist)
}

all_depth_csv = multmerge("temp_cvs")

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

vector_of_averages <- c()

for (i in 2:NCOL(all_depth_csv)) {
  v <- as.vector(all_depth_csv[,i])
  v <- na.omit(v)
  sum_coverage <- sum(as.numeric(v), na.rm = TRUE)
  vector_of_averages[i-1] <- sum_coverage/(NROW(v))
}

data <- summary(vector_of_averages)

The_midpoint = as.numeric(data[5])

Plots_list <- list()

for(i in 2:NCOL(all_depth_csv)){
  names_all <- colnames(all_depth_csv)
  name <- names_all[i]
  name_first <- strsplit(name, '_')
  name_first <- name_first[[1]]
  name_first <- as.numeric(name_first[length(name_first)])

  Read1_first = index_conv[name_first,1]
  Read2_first = index_conv[name_first,2]

  d <- colnames(all_depth_csv)
  Depth_column = d[i]

  if(Read1_first != Read2_first){
    Title = paste(d[i], "                 ", "Read1:", Read1_first, "    Read2:", Read2_first,sep = "")
  }else if(Read1_first == Read2_first){
    Title = paste(d[i], "                 ", "Read:", Read1_first)
  }

  df1 <- subset(all_depth_csv, select = c("Position", Depth_column))
  df1 <- na.omit(df1)
  colnames(df1)[2] <- "Depth"

### makes plot 1 ###
  colors <- c("blue", "green3", "yellow", "orange", "red") #set colors for gradient

  horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
    geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = "identity", width = 1.0)+
    scale_colour_gradientn(name = "Depth", colours = colors, guide = "colourbar", aesthetics = c("colour", "fill"))+ #use custom colors with custom scale, I think
    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
    ggtitle(Title)

  print(horizontalPlot)

  Plots_list[[i-1]] <- horizontalPlot
}

#All_plots <- do.call(grid.arrange, c(Plots_list,ncol=1))
All_plots <- ggarrange(plotlist = Plots_list, nrow = 5, ncol = 1, align = "v", common.legend = TRUE)
#ggsave("Plots_all_reads_combined.pdf", All_plots, width = 25, height = 49, units = "in")
ggexport(All_plots, filename = "Plots_all_reads_combined.pdf", width = 25, height = 25)