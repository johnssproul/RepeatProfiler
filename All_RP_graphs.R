args = commandArgs(trailingOnly=TRUE) #what are the arguments
print("this is ALL_RP_GRAPHS SCRIPT")

setwd("/Users/Anya/Documents/GitHub/SproulProject/scriptTest23/scripts")

library(ggplot2)
library(scales)
library(gridExtra)

index_conv <- read.table("Index_conv.txt", header = TRUE, stringsAsFactors = FALSE)

multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

The_path = getwd()
all_depth_csv = multmerge("all_depth_cvs") #this one returns a null object
#all_depth_csv = multmerge("temp_cvs")

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
    Title = paste(d[i],"                 ","Read1:",Read1_first,"    Read2:",Read2_first,sep = "")
  }else if(Read1_first == Read2_first){
    Title = paste(d[i],"                 ","Read:",Read1_first)
  }

  df1<-subset(all_depth_csv,select = c("Position",Depth_column))
  df1<-na.omit(df1)
  colnames(df1)[2] <- "Depth"

### makes plot 1 ###
  rs <- rescale(df1$Position, to = c(0, 1)) #rescale values of position to be in range 0-1
  colors <- c("blue", "green3", "yellow", "orange", "red") #set colors for gradient

  #sets the aesthetics of the colorbar
  Lbreak <- c(0, data[2], data[5], data[6], length(df1$Depth)-1000) #sets position of breaks on colorbar
  l2 <- round(as.numeric(data[2]),0) #sets second break at Q1 of averages
  l3 <- round(as.numeric(data[5]),0) #sets third break at Q3 of averages
  l4 <- round(as.numeric(data[6]),0) #sets fourth break at max of averages
  l5 <- round(length(df1$Depth),0)-1000 #sets last break at 1000 less than maximum depth (label didn't show up at maximum depth)
  Llabels <-  c(0, l2, l3, l4, l5) #creates vector of labels
  #TODO <-- figure out how to make values and rescaler on the same scale using quartiles
  scaledVals <- c(0, 0.25, 0.75, 0.8, 1.0)

  horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
    geom_bar(aes(color = Depth), alpha = 1, stat = "identity", width = 1.0)+
    coord_cartesian(xlim = c(0, length(df1$Position)), ylim = c(0, length(df1$Depth)))+  #sets axis range based on data
    scale_color_gradientn(name = "Depth", breaks = Lbreak, labels = Llabels, rs, colours = colors, values = scaledVals, guide = "colourbar")+ #use custom colors with custom scale, I think
    #scale_color_gradientn(name = "Depth", colours = colors, guide = "colourbar")+ #use custom colors without custom scale

    #uses the midpoint of the data to exstablish the reference point for the gradient.
    #scale_color_gradient2(low = "blue", mid = "green", high = "red", midpoint = The_midpoint/2)+
    #scale_fill_gradient2(low = "blue", mid = "green", high = "red", midpoint = The_midpoint/2)+
    #midpoint = max(Df2[2])/2)+

    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ #to remove gridlines
    ggtitle(Title)

  print(horizontalPlot)

  #Plot1name=paste(d[i],".png",sep="")
  #ggsave(as.character(Plot1name), Plot1, units = "mm", width = 175, height = 50)

  #args[1] is the number of graphs
  if(N == 5) {
    Plots_list[[N]] <- horizontalPlot
    test_ggpubr <- ggarrange(plotlist = Plots_list, ncol = 1)
    ggexport(test_ggpubr, filename = "test_ggpubr.pdf")
    #All_plots <- do.call(grid.arrange, c(Plots_list,ncol = 1))
    #the_name = paste("all_graphs_scaled/", Depth_column, ".pdf", sep = "")
    #ggsave("the_name.pdf", All_plots, width = 25, height = 25, units = "in",limitsize = TRUE)
    All_plots <- NULL
    Plots_list <- list()
    N = 1
  } else {
    Plots_list[[N]] <- horizontalPlot
    N = N + 1
  }
}




