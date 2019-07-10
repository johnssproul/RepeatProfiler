args = commandArgs(trailingOnly = TRUE)
print("this is ALL_RP_GRAPHS SCRIPT")

#setwd("/Users/Anya/Documents/GitHub/SproulProjectExtras/PipeTests/test12/")

#install.packages(c("ggplot","scaales","ggpubr"))
library(ggplot2)
library(scales)
library(ggpubr)
#library(gridExtra)

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

#The_path = getwd()
all_depth_csv = multmerge("all_depth_cvs")
#all_depth_csv = multmerge("./Wed_Jul_10_08:09:48_EDT_2019/all_depth_cvs")

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

N = 1
for(i in 2:NCOL(all_depth_csv)){
  names_all <- colnames(all_depth_csv)
  name <- names_all[i]
  name_first <- strsplit(name,"_")
  name_first <- name_first[[1]]
  name_first <- as.numeric(name_first[length(name_first)])

  Read1_first = index_conv[name_first,1]
  Read2_first = index_conv[name_first,2]

  d <- colnames(all_depth_csv)
  Depth_column = d[i]

  if(Read1_first != Read2_first){
    Title = paste(d[i], "                 ", "Read1:", Read1_first, "    Read2:", Read2_first, sep = "")
  }else if(Read1_first == Read2_first){
    Title = paste(d[i], "                 ", "Read:", Read1_first)
  }

  df1 <- subset(all_depth_csv,select = c("Position", Depth_column))
  df1 <- na.omit(df1)
  colnames(df1)[2] <- "Depth"

### makes plot 1 ###
  colors <- c("blue", "green3", "yellow", "orange", "red") #set colors for gradient

  horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
    geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = "identity", width = 1.0)+
    scale_colour_gradientn(name = "Depth", colours = colors, guide = "colourbar")+ #use custom colors with custom scale, I think
    scale_fill_gradientn(colours = colors)+
    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
    ggtitle(Title)

  print(horizontalPlot)

  #args[1] is the number of graphs --> as.numeric(args[1])
  if(N == as.numeric(args[1])) {
    Plots_list[[N]] <- horizontalPlot
    #All_plots <- do.call(grid.arrange, c(Plots_list,ncol = 1))
    All_plots <- ggarrange(plotlist = Plots_list, nrow = 5, ncol = 1, align = "v", common.legend = TRUE)
    the_name = paste("all_graphs_scaled/", Depth_column, ".pdf", sep = "")
    #ggsave("the_name.pdf", All_plots, width = 25, height = 25, units = "in",limitsize = TRUE)
    ggexport(All_plots, filename = the_name, width = 25, height = 25)

    #reset variables
    All_plots <- NULL
    Plots_list <- list()
    N = 1
  } else {
    Plots_list[[N]] <- horizontalPlot
    N = N + 1
  }
}
