args = commandArgs(trailingOnly=TRUE)

multmerge = function(mypath){
  filenames=list.files(path=mypath, full.names=TRUE)
  datalist = lapply(filenames, function(x){read.csv(file=x,header=T)})
  Reduce(function(x,y) {merge(x,y,all = TRUE)}, datalist)
}
all_depth_cvs = multmerge("temp_cvs")

if(NCOL(all_depth_cvs)>2){


all_depth_cvs<-all_depth_cvs[,-1]
  


all_depth_cvs<-all_depth_cvs[, colSums(all_depth_cvs != 0) > 0]

if(NCOL(all_depth_cvs)>1){
  

num_rows=ncol(all_depth_cvs)
colnames(all_depth_cvs)

Cor_matrix = matrix(NA, num_rows, num_rows)
rownames(Cor_matrix)<-colnames(all_depth_cvs)
colnames(Cor_matrix)<-colnames(all_depth_cvs)

for (r in 1:nrow(Cor_matrix)) {
  for (c in 1:ncol(Cor_matrix)) {
  
  
    cor=cor.test(all_depth_cvs[,r],all_depth_cvs[,c],methods=c("spearman"))$estimate
    
    
    if(is.na(cor)){
      
      cor=0
    }
    
    Cor_matrix[r,c]<-cor
    
    
    
  }
  
  
}

matrix_name=paste(as.character(args[1]),"/correlation_matrix.csv",sep="")



write.csv(Cor_matrix,file=matrix_name)






index_conv<-read.table("Index_conv.txt",header = TRUE,stringsAsFactors=FALSE)

user_supplied<-read.table("user_provided.txt",header=TRUE,stringsAsFactors=FALSE)


all_cor <- data.frame(Corr=numeric(),
                 GROUPED=character(), 
                 stringsAsFactors=FALSE) 

row_counter=1
for (first in 1:ncol(all_depth_cvs)) {
  names_all<-colnames(all_depth_cvs)
  name<-names_all[first]
  name_first<-strsplit(name,"_")
  name_first<-name_first[[1]]
  name_first<-as.numeric(name_first[length(name_first)])
  Read1_first=index_conv[name_first,"Read1"]
  f=as.numeric(which(user_supplied$Read1==Read1_first))
  group_first=user_supplied[f,"Group"]
  #print(group_first)
  #print(f)
  #print(first)]
   number=as.numeric(first)
    for (second in number:ncol(all_depth_cvs)) {
    print(second)
    
    name<-names_all[second]
    name_second<-strsplit(name,"_")
    name_second<-name_second[[1]]
    name_second<-as.numeric(name_second[length(name_second)])
    Read1_second=index_conv[name_second,"Read1"]
    z=as.numeric(which(user_supplied$Read1==Read1_second))
    #print(z)
    group_second=user_supplied[z,"Group"]
    
   cor=cor.test(all_depth_cvs[,first],all_depth_cvs[,second],methods=c("spearman"))$estimate
   
   if(is.na(cor)){
     
     cor=0
   }
   
    
   # print(group_first)
    #print(group_second)
    if(group_first==group_second){
      
      
      group="within"
      
    }else{
      group="between"
      
      
    }
    
    
    all_cor[row_counter,]<-c(cor,group)
    
    
    
    
    
    
    
    
    
    row_counter=row_counter+1
    
  }
  
  
}





library(ggplot2)
 
db.3<-all_cor
db.3$Corr<-as.numeric(db.3$Corr)
The_plot<-ggplot(db.3,aes(x=Corr,group=GROUPED,fill=GROUPED))+scale_x_continuous(breaks = round(seq(min(db.3$Corr), max(db.3$Corr), by = 0.5),1)) +
  geom_histogram(position="identity",alpha=0.5,binwidth=0.05)+theme_bw()+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


      

Plot_name=paste(as.character(args[1]),"/Correlation_plot.png",sep="")

ggsave(as.character(Plot_name), The_plot, units = "mm", width = 175, height = 50)

}else{
  
  
  write("correlation analysis cant be done because there is only 1 non-zero value depth  with only!", stderr())
  
  print("correlation analysis cant be done because there is only 1 non-zero value depth  with only!")
  
  
}
}else{
  
  write("correlation Analysis cant be done with only one pair of read or a single unpaired read", stderr())
  
  print("correlation Analysis cant be done with only one pair of read or a single unpaired read")
  
  
}