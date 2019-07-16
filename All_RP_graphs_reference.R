cat("Plotting Combined Samples Graphs... \n")
args = commandArgs(trailingOnly = TRUE)

#print(as.character(args[1])) #brew stuff
#.libPaths(as.character(args[1])) #brew stuff

library(ggplot2)
library(scales)
library(ggpubr)


multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x,y,all = TRUE)}, datalist)
}

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

all_depth_csv = multmerge("temp_cvs")

#determines number of plots per page based on number of samples -- setting default at 8 for now
#l <- length(colnames(all_depth_csv))
#if (l < 10) {
# n <- l
#} else {
# n <- 8
#}

#set standard scale
max <- 0
for (i in 2:NCOL(all_depth_csv)) {
  v <- as.vector(all_depth_csv[,i])
  v <- na.omit(v)
  max_column <- max(as.numeric(v))

  if(max_column > max) {
    max <- max_column
  }
}

Plots_list <- list()

for(i in 2:NCOL(all_depth_csv)){
  print(i-1)

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
    Title = paste(d[i], "   Read1: ", Read1_first, "   Read2: ", Read2_first,sep = "")
  }else if(Read1_first == Read2_first){
    Title = paste(d[i], "   Read: ", Read1_first)
  }

  df1 <- subset(all_depth_csv, select = c("Position", Depth_column))
  df1 <- na.omit(df1)
  colnames(df1)[2] <- "Depth"


  ########## Plot 1 :: Horizontal Color Ramp ##########
  colors <- c("blue", "green3", "yellow", "orange", "red", "red")

  horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
    geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = "identity", width = 1.0)+
    scale_colour_gradientn(name = "Depth", values = c(0, .20, .30, .50, .80, 1.0), colours = colors, limits = c(0, max), guide = "colourbar")+
    scale_fill_gradientn(name = "Depth", values = c(0, .20, .30, .50, .80, 1.0), colours = colors, limits = c(0, max), guide = "colourbar")+
    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          plot.title = element_text(face = "bold"))+ #to remove gridlines and format title
    ggtitle(Title)

  Plots_list[[i-1]] <- horizontalPlot
}

All_plots <- ggarrange(plotlist = Plots_list, nrow = 8, ncol = 1, align = "v", common.legend = TRUE) #common.legend = TRUE creates a single legend for all graphs on a page; if you want a separate legend for each graph, set to FALSE
ggexport(All_plots, filename = "combined_horizontal_colored.pdf", width = 25, height = 25)