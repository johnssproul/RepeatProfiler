args = commandArgs(trailingOnly=TRUE)
print("this is ALL_RP_GRAPHS SCRIPT")


library (ggplot2)

library(gridExtra)
multmerge = function(mypath){
  filenames=list.files(path=mypath, full.names=TRUE)
  datalist = lapply(filenames, function(x){read.csv(file=x,header=T,check.names = FALSE)})
  Reduce(function(x,y) {merge(x,y,all = TRUE)}, datalist)
}
all_depth_cvs = multmerge("all_depth_cvs")


index_conv<-read.table("Index_conv.txt",header = TRUE,stringsAsFactors=FALSE)


vector_of_averages<- c()

for (i in 2:NCOL(all_depth_cvs)) {
  v<-as.vector(all_depth_cvs[,i])
  
  v<-na.omit(v)
  sum_coverage<-sum(as.numeric(v), na.rm = TRUE)
  
  
  vector_of_averages[i-1]<-sum_coverage/(NROW(v))
  
  
  
}

data<- summary(vector_of_averages)


The_midpoint=as.numeric(data[5])



Plots_list<-list()

N=1
for(i in 2:NCOL(all_depth_cvs)){
  names_all<-colnames(all_depth_cvs)
  name<-names_all[i]
  name_first<-strsplit(name,"_")
  name_first<-name_first[[1]]
  name_first<-as.numeric(name_first[length(name_first)])
  
  
  Read1_first=index_conv[name_first,1]

  
  
  
  Read2_first=index_conv[name_first,2]
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  d<-colnames(all_depth_cvs)
  
  Depth_column=d[i]
  if(Read1_first!=Read2_first){
  
  Title=paste(d[i],"                 ","Read1:",Read1_first,"    Read2:",Read2_first,sep = "")
  }else if(Read1_first==Read2_first){
    
    Title=paste(d[i],"                 ","Read:",Read1_first)
    
    
  }
  
  #Df1<-read.table("pileup_counted.txt",header=TRUE,fill = TRUE)
  #args[1]="TIRANT_I_LTR_Gypsy.fa_1"
  Df2<-subset(all_depth_cvs,select = c("Position",Depth_column))
  Df2<-na.omit(Df2)
  
  colnames(Df2)[2] <- "Depth"
  
    Plot1<-ggplot(data=Df2, aes(x=Position, y=Depth))+
    geom_bar(aes(color=Depth, fill=Depth), alpha = 1, stat="identity")+
    
    #This uses the midpoint of the data to exstablish the reference point for the gradient.
    scale_color_gradient2(low = "blue", mid = "green", high = "red",
                          midpoint = The_midpoint/2)+
    scale_fill_gradient2(low = "blue", mid = "green", high = "red",
                         midpoint = The_midpoint/2)+
    #midpoint = max(Df2[2])/2)+
    #to remove gray background
    theme_bw()+
    #To remove gridlines:
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + ggtitle(Title)
  
  ###########
  #This is a cool way to make the color gradient way prettier, but it may not let us specify a midpoint that puts all plots on the same scale. Need to check.
  #Plot1+scale_color_gradientn(colours = c("blue", "green3", "yellow", "orange", "red")) #rainbow(5))
  ###########
  
  print(Plot1)
  #Plot1name=paste(d[i],".png",sep="")
    
 # ggsave(as.character(Plot1name), Plot1, units = "mm", width = 175, height = 50)
  
  
  if(N==as.numeric(args[1]))
    
  {
    
    Plots_list[[N]]<-Plot1
    
    All_plots<-do.call(grid.arrange,c(Plots_list,ncol=1))
    
    the_name=paste("all_graphs_scaled/",Depth_column,".pdf",sep = "")
    
    ggsave(the_name, All_plots, width = 25, height = 25, units = "in",limitsize = TRUE)
    
    
  All_plots<-NULL  
  Plots_list <- list()
    
    N=1

  }else{
    
    Plots_list[[N]]<-Plot1
    
    N=N+1
  }
    
    
  
    
  
  

  
  
}




