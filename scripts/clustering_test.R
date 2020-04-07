depth_data<-read.table("depth_counts.txt",header = TRUE)

depth_data<-depth_data[depth_data$CountMatch!=depth_data$Depth,]

depth_data$difference<-(depth_data$Depth-depth_data$CountMatch)


depth_data$var_sig<-ifelse(depth_data$difference>=depth_data$Depth*0.1,"nice","bad")
depth_data<-depth_data[depth_data$var_sig=="nice",]

depth_data$difference<-(depth_data$difference)/depth_data$Depth
rownamestostore<-row.names(depth_data)
depth_data<-data.frame(variants=depth_data[,8])
row.names(depth_data)<-rownamestostore

groups<-data.frame(pos=as.vector(row.names(depth_data)),similar_0.2_with=as.vector(rep("",NROW(depth_data))),stringsAsFactors=FALSE)


distance_matrix<-as.matrix(dist(depth_data,method = "minkowski"),rowna)

positions<-colnames(distance_matrix)
for (i in 1:NROW(distance_matrix)){
  for (j in 1:NROW(distance_matrix)) {
    

    distance=distance_matrix[i,j]
    if (distance<0.001)
    {
      
      
      
     groups[i,"similar_0.2_with"] <- paste(positions[j], groups[i,"similar_0.2_with"], sep = " ", collapse = " ")
      
      
      
      
      
      
    }
    
    
    
    
    
  }
  
}

unique_clusters<-as.data.frame(unique(groups[,2]))


groups[groups$pos=="823","similar_0.2_with"]








clusters<-data.frame(Cluster_name=seq(1,NROW(unique_clusters)),cluster=unique_clusters,stringsAsFactors = FALSE)

the_depths<-NULL
for (i  in 1:NROW(clusters)) {
 
  the_cluster_analysis<-clusters[i,2]
  the_cluster_analysis<-strsplit(as.character(the_cluster_analysis)," ")
  the_cluster_analysis<-the_cluster_analysis[[1]]
  
  the_depths<-append(the_depths,depth_data[row.names(depth_data)%in%the_cluster_analysis,1])
  
  
  
   
}



plot(the_depths,main=paste("clusters"))


#testing the sorting method

depth_data<-depth_data[order(depth_data$variants),]



r1<-c(1.4,1.6)
r2<-c(1.5,1.0)

dist(rbind(r1,r2),method = "euclidean")
dist(rbind(r1,r2),method = "manhattan")
dist(rbind(r1,r2),method = "maximum")


age<-c(13, 15,
16, 16, 19, 20, 20, 21, 22, 22, 25, 25, 25, 25, 30, 33, 33, 35, 35, 35, 35, 36, 40, 45, 46,
52, 70)
