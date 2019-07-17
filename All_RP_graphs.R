args <- commandArgs(trailingOnly = TRUE)
cat('Saving Scaled Reference Plots (Horizontal)... \n')

#print(as.character(args[2])) #brew stuff
#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)


#code if plots per page or file type specified
if (is.null(args[2]) || is.na(args[2])) { #if nothing is specified, set defaults
  n <- 8
  ft <- '.pdf'
} else if(is.null(args[3]) || is.na(args[3])) { #if nothing is specified for arg[3]
  if(grepl('.', args[2], fixed = TRUE)) {
    n <- 8
    ft <- args[2] #args[2] is file type
  } else if (!is.na(as.numeric(args[2]))){
    n <- args[2] #args[2] is plots per page
    ft <- '.pdf'
  } else {
    print('Invalid input. Setting plots per page and file type to default: 8 and ".pdf", respectively')
    n <- 8
    ft <- '.pdf'
  }
} else {
  n <- args[2] #assume args[2] is plots per page
  ft <- args[3] #assume args[3] is file type
}

#merges all files located in 'mypath' into one dataframe
multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

#reads textfile containing names of reads
index.conv <- read.table('Index_conv.txt', header = TRUE, stringsAsFactors = FALSE)

#multimerge files in all_depth_cvs directory
#all.depth.csv <- multmerge('./all_depth_cvs') #path-specific
all.depth.csv <- multmerge('all_depth_cvs')

#args[1] <- length(colnames(all.depth.csv))-1 #path-specific --> number of graphs

plots <- list()


########## Standard Scale and Sample's Dataframe ##########
#calculates maximum depth based on all.depth.csv dataframe
max <- 0
for (i in 2:NCOL(all.depth.csv)) {
  v <- as.vector(all.depth.csv[,i])
  v <- na.omit(v)
  max.column <- max(as.numeric(v))

  if(max.column > max) {
    max <- max.column
  }
}


########## Plot Aesthetics ##########
#sets color scheme for gradient
colors <- c('blue4', 'springgreen2', 'yellow', 'orange', 'red', 'red')

#sets color gradient environment for gradient plots (horizontal and vertical)
colorscale <- scale_colour_gradientn(name = 'Depth', values = c(0, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = c('colour', 'fill'))

#sets plot theme and formatting
tf <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
            plot.title = element_text(size = 10, face = 'bold'), axis.title = element_text(size = 10)) #formats plot title

#formats legend
tl <- theme(legend.text = element_text(size = 6))

#sets caption for low coverage plots
cap <- labs(caption = 'Low to No Coverage')


########## Plotting Loop ##########
N = 1
for(i in 2:NCOL(all.depth.csv)){
  print(i-1)

  #gets names of reads and stores as objects to be used for title
  names.all <- colnames(all.depth.csv)
  name <- names.all[i]
  name.first <- strsplit(name, '_')
  name.first <- name.first[[1]]
  name.first <- as.numeric(name.first[length(name.first)])

  read1.first <- index.conv[name.first,1]
  read2.first <- index.conv[name.first,2]

  d <- colnames(all.depth.csv)
  depth.column = d[i]

  if(read1.first != read2.first){
    t <- paste(d[i], '   Read1: ', read1.first, '   Read2: ', read2.first, sep = '')
  }else if(read1.first == read2.first){
    t <- paste(d[i], '   Read: ', read1.first, sep = '')
  }

  #subsets all.depth.csv into dataframe containing position and depth for only one sample
  df1 <- subset(all.depth.csv, select = c('Position', depth.column))
  df1 <- na.omit(df1)
  colnames(df1)[2] <- 'Depth'


  ########## Horizontal Gradient Plot ##########
  horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
    geom_bar(aes(color = Depth, fill = Depth), alpha = 1, stat = 'identity', width = 1.0)+
    colorscale+
    theme_bw()+ #to remove grey background
    tf+
    tl+
    ggtitle(t) #sets plot title

  if(max(df1$Depth) < 1) {
    horizontalPlot <- horizontalPlot+ cap
  }

  #if last graph has been plotted, save pdf; else continuing plotting
  if(N == as.numeric(args[1])) {
    plots[[N]] <- horizontalPlot
    allplots <- ggpubr::ggarrange(plotlist = plots, nrow = n, ncol = 1, align = 'hv', common.legend = TRUE) #common.legend = TRUE creates a single legend for all graphs on a page; if you want a separate legend for each graph, set to FALSE
    the.name = paste('refrences_wide_color_scaled_graphs/', depth.column, '.pdf', sep = '')
    #the.name = paste('refrences_wide_color_scaled_graphs', ft, sep = '') #path-specific
    ggpubr::ggexport(allplots, filename = the.name, width = 25, height = 25)

    #reset variables
    allplots <- NULL
    plots <- list()
    N = 1
  } else {
    plots[[N]] <- horizontalPlot
    N = N + 1
  }
}