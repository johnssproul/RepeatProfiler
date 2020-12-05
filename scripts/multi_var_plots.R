##### This script (called in repeatprof) runs after all individual variant plots have been made and produces a combined PDFs with all variant plots from the run (one for each reference).
##### The code is similar to var_plots.R, but that script outputs a single plot per PDF.

args <- commandArgs(trailingOnly = TRUE)

##### print statements and defining variables

cat('Saving combined variation plots... \n')

#.libPaths(as.character(args[1])) #brew stuff

library(ggplot2)





annotation_file <- as.character(args[2]) #annotation file path
indel_flag<-as.character(args[3])


indel_cutoff<-as.numeric(as.character(args[4]))

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
  
}


multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T, check.names = FALSE)})
  Reduce(function(x, y) {merge(x, y, all = TRUE)}, datalist)
}




if(indel_flag=="true"){
  
  indel_info<-multmerge('temp_indel_cvs')
  indel_info$indels<-(as.numeric(indel_info$insertion)+as.numeric(indel_info$deletetion))
  indel_info[indel_info$depth==0,3]<-1
  
  indel_info$indel_frac<-indel_info$indels/as.numeric(indel_info$depth)
  indel_info$color<-rep("not_good",NROW(indel_info))
  
  
  #indel_info<-indel_info[indel_info$indel_frac>indel_cutoff,]
  checker<-NROW(indel_info[(indel_info$insertion/indel_info$depth)>indel_cutoff,])
  if(checker>0){
    
    indel_info[(indel_info$insertion/indel_info$depth)>indel_cutoff,]$color<- "gray"
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












n <- 8
ft <- '.pdf'

#code if plots per page or file type specified
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

#objects for handling low coverage plots
#img <- png::readPNG('./images-RP/watermark.png')
#wm <- ggpubr::background_image(img) #for watermark
cap <- labs(caption = 'This graph has no coverage.') #sets caption for low coverage plots

index.conv <- read.table('index_conv.txt', header = TRUE, stringsAsFactors=FALSE) #reads textfile containing names of reads

#reads textfile containing names indexed samples
#multi.poly.names <- read.table('./erecta_CL9_TR_1_x_6687_0nt.fa_output/multi_poly_names.txt', header = TRUE, stringsAsFactors = FALSE) #testing
multi.poly.names <- read.table('multi_poly_names.txt', header = TRUE, stringsAsFactors = FALSE)

plots <- list()

########## Plotting Loop ##########
for (i in 1:NROW(multi.poly.names)) {
  print(i)

  #gets names of reads and stores as objects to be used for title
  name <- multi.poly.names[i,1]
  name.first <- strsplit(name, '_')
  name.first <- name.first[[1]]
  name.first <- as.numeric(name.first[length(name.first)])

  read1.first <- index.conv[name.first,1]
  read2.first <- index.conv[name.first,2]

  if(read1.first != read2.first){
    t <- paste(multi.poly.names[i,1], '   Read1: ', read1.first, '   Read2: ', read2.first, sep = '')
  }else if(read1.first == read2.first){
    t <- paste(multi.poly.names[i,1], '   Read: ', read1.first, sep = '')
  }

  name.of.table.used <- paste('multi_poly/', multi.poly.names[i,1], '.txt', sep = '')

  #creates dataframe of counts for bases
  base.counts <- read.table(name.of.table.used, header = TRUE)
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

  length(base.countsRed.m$variable)

  polymorphPlot <- ggplot(base.countsRed.m, aes(x = Position, y = Depth, fill = Bases, alpha = Bases))+
    geom_bar(stat = 'identity', width = 1.0)+
    scale_fill_manual(values = c('grey', 'red', 'blue', 'yellow', 'green'))+
    scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
    theme_bw()+ #to remove grey background
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          plot.title = element_text(face = 'bold'))+ #to remove gridlines and format title
    ggtitle(t)

  #low coverage cases
  if(max(base.counts$Depth) < 1) {
    polymorphPlot <- polymorphPlot+ cap
  }
  
  indel_ymin=0.08 #to allow overlaying annotate and the indel bar too 
  indel_ymax=0
  
  if (annote==TRUE){
    print("annotation exists")
    
    name.first <- strsplit(name, '_')
    name.first <- name.first[[1]]
    name.first <- name.first[1:length(name.first)-1]
    name.first<- paste(name.first, collapse = '_')
    
    
    annotation <-annotation_file[annotation_file$ref==name.first,]
    if(NROW(annotation)>0){
      
      if(any (annotation$start <0) || any(annotation$end >(NROW(base.countsRed.m$Depth)+100))){
        
        print(paste("The annotation for",name.first,"is out bounds. Skipped"))
        
      }
      else{
        polymorphPlot <- polymorphPlot+ 
          annotate("text", x = annotation$start+0.5*(annotation$end-annotation$start), y = -(0.035*(max(base.countsRed.m$Depth))), label = annotation$annot, size=3)+
          annotate("rect", xmin=annotation$start, xmax=annotation$end, ymin=-(0.08*(max(base.countsRed.m$Depth))), ymax=0, alpha=.2,col="white")
        indel_ymin=0.18 #to allow overlaying annotate and the indel bar too 
        indel_ymax=0.10
        
        
      }
    }
    
  }
  
  if(indel_flag=="true"){
    
    print(name)
    
    
    indel_info_cur<-indel_info[indel_info$ref==name,]
    
    if(NROW(indel_info_cur)>1){
      
      print("indel info exists")
      
      polymorphPlot<-polymorphPlot+ annotate("rect", xmin=indel_info_cur$pos, xmax=indel_info_cur$pos+0.0008*NROW(base.countsRed.m$Depth), ymin=-(indel_ymin*(max(base.countsRed.m$Depth))), ymax=-(indel_ymax*(max(base.countsRed.m$Depth))), alpha=1,fill=indel_info_cur$color)
      
    }else{
      
      
      
      polymorphPlot<-polymorphPlot+  annotate("text", x = 1, y = -(indel_ymin*(max(base.countsRed.m$Depth))),label="No indels found")
      
    }
    
    
  }
  
  
  
  
  
  
  
  
  
  
  

  plots[[i]] <- polymorphPlot
}

##### uses ggpubr to standardize multiple output plots on PDFs
allplots <- ggpubr::ggarrange(plotlist = plots, nrow = n, ncol = 1, align = 'hv', common.legend = TRUE) #common.legend = TRUE creates a single legend for all graphs on a page; if you want a separate legend for each graph, set to FALSE
#file <- paste('./Test_plots/Variation_Reference_Combined', ft, sep = '') #testing
file <- paste('variant_profiles', ft, sep = '')
ggpubr::ggexport(allplots, filename = file, width = 25, height = 25)

##### end script
