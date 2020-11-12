### This makes the combined colorful plots and puts all references on the same color scale. All plots within a given reference will be on the same color scale. 
### This script is called in the repeatprof script. The code is quite similar to 'mk_profiles_ref.R' but that script only puts graphs within the same reference on the same color scale.

args <- commandArgs(trailingOnly = TRUE)

##### print statements and defining initial variables

cat('Saving color plots scaled across all references (horizontal gradient)... \n')

#print(as.character(args[2])) #brew stuff
#.libPaths(as.character(args[2])) #brew stuff

library(ggplot2)





Normalized <- as.character(args[3]) #normalize stuff
annotation_file <- as.character(args[4]) #annotation file path

color_flag <- as.character(args[5]) #annotation file path
indel_flag<-as.character(args[6])
indel_cutoff<-as.numeric(as.character(args[7]))

print(paste("colorflag is ",color_flag))
      

if(!is.na(indel_cutoff)){
  
  if (indel_cutoff>1 || indel_cutoff<0 ){
    
    indel_cutoff<-0.10
    
    
    
    
  }
  
  
  
}else {
  
  
  indel_cutoff<-0.10
  
  
}




annote=FALSE
if (annotation_file != "placeholder"){
  annote=TRUE
  print("annotation is working")
  annotation_file  <-  read.table(annotation_file,stringsAsFactors = FALSE)
  colnames(annotation_file)<-c("ref","start","end","annot")
 # print(annotation_file)

}




n <- 8
ft <- '.pdf'
plot_yaxis<-"Depth"

#code if plots per page or file type specified (not implemented yet)
# if (is.null(args[2]) || is.na(args[2])) { #if nothing is specified, set defaults
#   n <- 8
#   ft <- '.pdf'
# } else if(is.null(args[3]) || is.na(args[3])) { #if nothing is specified for arg[3]
#   if(grepl('.', args[2], fixed = TRUE)) {
#     n <- 8
#     ft <- args[2] #args[2] is file type
#   } else if (!is.na(as.numeric(args[2]))){
#     n <- args[2] #args[2] is plots per page
#     ft <- '.pdf'
#   } else {
#     print('Invalid input. Setting plots per page and file type to default: 8 and '.pdf', respectively')
#     n <- 8
#     ft <- '.pdf'
#   }
# } else {
#   n <- args[2] #assume args[2] is plots per page
#   ft <- args[3] #assume args[3] is file type
# }

#img <- png::readPNG('./images-RP/watermark.png') #get watermark image

#merges all files located in 'mypath' into one dataframe
multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}

index.conv <- read.table('index_conv.txt', header = TRUE, stringsAsFactors = FALSE) #reads textfile containing names of reads
all.depth.csv <- multmerge('map_depth_allrefs')


print(paste("indelflag:",indel_flag))

if(indel_flag=="true"){

indel_info<-multmerge('indel_info_allrefs')
indel_info$indels<-(as.numeric(indel_info$insertion)+as.numeric(indel_info$deletetion))
indel_info[indel_info$depth==0,3]<-1

indel_info$indel_frac<-indel_info$indels/(as.numeric(indel_info$depth))
indel_info$color<-rep("not_good",NROW(indel_info))





#indel_info<-indel_info[indel_info$indel_frac>0.1,]
checker<-NROW(indel_info[(indel_info$insertion/indel_info$depth)>indel_cutoff,])
if(checker>0){
  
indel_info[(indel_info$insertion/(indel_info$depth))>indel_cutoff,]$color<- "gray"
}
checker<-NROW(indel_info[(indel_info$deletetion/indel_info$depth)>indel_cutoff,])
if(checker>0){
  
indel_info[(indel_info$deletetion/indel_info$depth)>indel_cutoff,]$color<-"black"
}
checker<-NROW(indel_info[(indel_info$deletetion/indel_info$depth)>indel_cutoff && (indel_info$insertion/indel_info$depth)>indel_cutoff ,])
if(checker>0){
indel_info[(indel_info$deletetion/indel_info$depth)>indel_cutoff && (indel_info$insertion/indel_info$depth)>indel_cutoff ,]$color<-"blue"
}
indel_info<-indel_info[indel_info$color!="not_good",]


}



##### Runs if user specifies normalization with -singlecopy flag
if(Normalized == 'true'){
  Normalizetable <- read.csv('normalized_table.csv', header = TRUE, stringsAsFactors = FALSE) #reads textfile containing names of reads
  names.all <- colnames(all.depth.csv)
  plot_yaxis<-"Normalized_coverage"
  for(x in 2:NCOL(all.depth.csv)){
    name <- names.all[x]
    name <- strsplit(name, '_')
    name <- name[[1]]
    name <- as.numeric(name[length(name)])

    normalvalue <- Normalizetable[name,2]
    all.depth.csv[,x] <- all.depth.csv[,x]/normalvalue
  }
}

##### end normalization



# all.depth.csv<-cbind(Position=all.depth.csv[,1],all.depth.csv[,2:NCOL(all.depth.csv)]/Normalized) #normalization
# all.depth.csv<-all.depth.csv[,1:NCOL(all.depth.csv)]/Normalized
# all.depth.csv$Position<-all.depth.csv$Position*Normalized

#args[1] <- length(colnames(all.depth.csv))-1 #testing --> number of graphs



#####calculates maximum depth based on all.depth.csv dataframe

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
if(color_flag=="true"){
  
  colors <- c('#440154FF', '#3B528BFF', '#21908CFF', '#5DC863FF', '#FDE725FF', '#FDE725FF') #sets color scheme for gradient
  cs <- scale_colour_gradientn(name = plot_yaxis, values = c(0, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = 'fill') #sets color gradient environment for gradient plots (horizontal and vertical)
  
  
}else{


  colors <- c('#6f4c9b', '#6059a9', '#5568b8', '#4e79c5', '#4d8ac6', 
              '#4e96bc', '#549eb3', '#59a5a9', '#60ab9e', '#69b190',
              '#77b77d', '#8cbc68', '#bebc48', '#d1b541', '#ddaa3c',
              '#e49c39', '#e78c35', '#e67932', '#e4632d', '#df4828', 
              '#da2222', '#da2222')
  cs <- scale_fill_gradientn(name = "Depth", values = c(0, .03, .06, .10, .11, 
                                                        .12, .13, .15, .17, .19, 
                                                        .22, .27, .30, .33, .40, 
                                                        .47, .53, .60, .67, .73, 
                                                        .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = 'fill') #sets color gradient environment for gradient plots (horizontal and vertical)
}
tf <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #removes gridlines
            plot.title = element_text(size = 10, face = 'bold'), axis.title = element_text(size = 6)) #formats plot title
tl <- theme(legend.text = element_text(size = 6)) #formats legend
cap <- labs(caption = 'This graph has no coverage.') #sets caption for low coverage plots
#wm <- ggpubr::background_image(img) #for watermark


########## Plotting Loop ##########
plots <- list()

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
  depth.column <- d[i]

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
    geom_bar(aes(fill = Depth), alpha = 1, stat = 'identity', width = 1.0)+
    cs+ theme_bw()+ #to remove grey background
    tf+ tl+ ggtitle(t) +labs(y=plot_yaxis) #sets plot title 

  #low coverage cases
  if(max(df1$Depth) < 1) {
    horizontalPlot <- horizontalPlot+ cap
  }

  
  
indel_ymin=0.08 #to allow overlaying annotate and the indel bar too 
indel_ymax=0
if (annote==TRUE){
  
  name <- names.all[i]
  name.first <- strsplit(name, '_')
  name.first <- name.first[[1]]
  name.first <- name.first[1:length(name.first)-1]
  name.first<- paste(name.first, collapse = '_')
  
  
  annotation <-annotation_file[annotation_file$ref==name.first,]
  
  
  if(NROW(annotation)>0){
    
  
  if(any(annotation$start <0) || any(annotation$end >(NROW(df1$Depth)+100))){
    
    print(paste("The annotation for",name.first,"is out bounds. Skipped"))
    
  }
  else{
    print("annotation exist")
    
    horizontalPlot <- horizontalPlot+ 
         annotate("text", x = annotation$start+0.5*(annotation$end-annotation$start), y = -(0.035*(max(df1$Depth))), label = annotation$annot, size=3)+
         annotate("rect", xmin=annotation$start, xmax=annotation$end, ymin=-(0.08*(max(df1$Depth))), ymax=0, alpha=.2,col="white")
    
    indel_ymin=0.18 #to allow overlaying annotate and the indel bar too 
    indel_ymax=0.10
    
      
      #annotate("text", x = annotation$start+0.5*(annotation$end-annotation$start), y = max(df1$Depth)+0.12*(max(df1$Depth)), label = annotation$annot, size=5)+
      #annotate("rect", xmin=annotation$start, xmax=annotation$end, ymin=max(df1$Depth)+0.06*(max(df1$Depth)), ymax=max(df1$Depth)+0.2*(max(df1$Depth)), alpha=.2)
    
  }
  }
  
  
  
  
  
}
  
  
  
  
  
  if(indel_flag=="true"){
    
    print(name)
    
    
    indel_info_cur<-indel_info[indel_info$ref==name,]
    
    if(NROW(indel_info_cur)>1){
      
    print("indel info exist")
    
    horizontalPlot<-horizontalPlot+ annotate("rect", xmin=indel_info_cur$pos, xmax=indel_info_cur$pos+0.001*NROW(df1$Depth), ymin=-(indel_ymin*(max(df1$Depth))), ymax=-(indel_ymax*(max(df1$Depth))), alpha=1,fill=indel_info_cur$color)
    
    }else{
      
      
      
      horizontalPlot<-horizontalPlot+  annotate("text", x = 1, y = -(indel_ymin*(max(df1$Depth))),label="No indels found")
      
    }
    
    
  }
  
  
  
  

  
  
  
  
  
  
  # annotPlot <- horizontalPlot+ 
  #   annotate("text", x = gff$start+0.5*(gff$end-gff$start), y = -100, label = gff$annot, size=2)+
  #   annotate("rect", xmin=gff$start, xmax=gff$end, ymin=-400, ymax=0, alpha=.2)
  
  
  
  
  
  
  
  
  
  
  
  
  #makes name of file nicer by removing extention at the end
  name.file <- strsplit(depth.column, '_')
  name.file <- name.file[[1]]
  name.file <- name.file[1:length(name.file)-1]
  name.file <- paste(name.file, collapse = '_')
  name.file <- strsplit(name.file, '.', fixed = TRUE)
  name.file <- name.file[[1]]
  name.file <- name.file[name.file != 'fasta']
  name.file <- name.file[name.file != 'fa']
  name.file <- name.file[name.file != 'txt']
  name.file <- paste(name.file, collapse = '.')

  #if last graph has been plotted, save pdf; else continuing plotting
  if(N == as.numeric(args[1])) {
    plots[[N]] <- horizontalPlot
    allplots <- ggpubr::ggarrange(plotlist = plots, nrow = n, ncol = 1, align = 'hv', common.legend = TRUE) #common.legend = TRUE creates a single legend for all graphs on a page; if you want a separate legend for each graph, set to FALSE
    #the.name = paste('./Test_plots/Horizontal_All_Combined', ft, sep = '') #testing
    the.name = paste('scaled_profiles_allrefs/', name.file, ft, sep = '')
    ggpubr::ggexport(allplots, filename = the.name, width = 25, height = 25)

    #reset variables
    allplots <- NULL
    plots <- list()
    N <- 1
  } else {
    plots[[N]] <- horizontalPlot
    N <- N + 1
  }
}

# NOTE: Thie warning message may appear:
# In UseMethod('depth') :
#   no applicable method for 'depth' applied to an object of class 'NULL'
# Apparently it is an 'overuse' of ggplot, which makes sense if there are a large number of plots produced.
# This has not been found to cause a problem in exporting the plots, although it may cause some issues not yet encountered.
##### end script 
