multmerge = function(mypath){
  filenames=list.files(path=mypath, full.names=TRUE)
  datalist = lapply(filenames, function(x){read.csv(file=x,header=T)})
  Reduce(function(x,y) {merge(x,y,all = TRUE)}, datalist)
}

all_depth = multmerge("all_depth_cvs")

The_summary=read.table("The_summary.txt",header=TRUE,stringsAsFactors = FALSE)



The_summary$Ref_Length <- NA
The_summary$Average_coverage <- NA
The_summary$Average_coverage <- NA
The_summary$max_coverage <- NA




index_for_summary=1


#this loop is to fill the reference length

for(i in 2:ncol(all_depth)){
  
  v<-as.vector(all_depth[,i])
  
  ref_length<-sum(!is.na(v))
  
  

  The_summary[index_for_summary,7]<-ref_length
  
  
  index_for_summary<- index_for_summary+1
  
  
}





index_for_summary=1
#this loop is to fill the Average coverage
for(i in 2:ncol(all_depth)){
  
  v<-as.vector(all_depth[,i])
  
  sum_coverage<-sum(as.numeric(v), na.rm = TRUE)


  average_coverage=sum_coverage/as.numeric(The_summary[index_for_summary,7])
  
  
  
  The_summary[index_for_summary,8]<- average_coverage
  
  
  index_for_summary<- index_for_summary+1
  
  
}


index_for_summary=1

#this loop is to fill the max coverage
for(i in 2:ncol(all_depth)){
  
  v<-as.vector(all_depth[,i])
  
  maximum<-max(v,na.rm = TRUE)
  
  The_summary[index_for_summary,9]<-maximum
  
  
  index_for_summary<- index_for_summary+1
  
  
}

 if(all(The_summary$Read1==The_summary$Read2)){
   
   The_summary$Read2<-NULL
   
   names(The_summary)[names(The_summary) == 'Read1'] <- 'Read'
   
   
 }



write.csv(The_summary,file="The_summary_final.csv",row.names = FALSE)


