##### This script (called within 'repeatprof') takes in the output from the whole run and generates a table with of statistics.
print("running depth_analyser")

args <- commandArgs(trailingOnly = TRUE)
multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x,y) {merge(x, y, all = TRUE)}, datalist)
}

all.depth <- multmerge('map_depth_allrefs')
The.summary <- read.table('The_summary.txt', header = TRUE, stringsAsFactors = FALSE)
The.summary <- The.summary[order(The.summary$Reference),] 


Normalized <- as.character(args[1]) #normalize stuff


getmode <- function(v) {
  v<-na.omit(v)
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

#initialize data frame
The.summary$Ref.Length <- NA
The.summary$Average.coverage <- NA
The.summary$Average.coverage <- NA
The.summary$max.coverage <- NA

index.for.summary <- 1
The.summary$percent_mapped<-The.summary$percent_mapped*100

#loop to fill in initialized data frame
for(i in 2:ncol(all.depth)){
  v <- as.vector(na.omit(all.depth[,i]))

  #reference length
  ref.length <- sum(!is.na(v))
  The.summary[index.for.summary,7] <- ref.length

  #average coverage
  sum.coverage <- sum(as.numeric(v), na.rm = TRUE)
  average.coverage <- sum.coverage/as.numeric(The.summary[index.for.summary,7])
  The.summary[index.for.summary,8] <- average.coverage
  
  
  #max coverage
  maximum <- max(v, na.rm = TRUE)
  The.summary[index.for.summary,9] <- maximum
  
  #median_coverage
  mediana <- median(v, na.rm = TRUE)
  The.summary[index.for.summary,10] <- mediana
  colnames(The.summary)[10]<-"median"
  #mode
  moda <- getmode(v)
  The.summary[index.for.summary,11] <- moda
  colnames(The.summary)[11]<-"mode"
  
  #base propotion that has coverage 
  
 propotion= length(which(v>=1))/NROW(v)
 
 The.summary[index.for.summary,12] <- propotion
 
 colnames(The.summary)[12]<-"propotion_bases_with_coverage"
 
  
  #
  
  index.for.summary <- index.for.summary+1
}

#handles summary of single-end read runs
if(all(The.summary$Read1 == The.summary$Read2)){
  The.summary$Read2 <- NULL
  names(The.summary)[names(The.summary) == 'Read1'] <- 'Read'
}


###for runs that include normalization (-corr flag) this block adds normalized values to the summary table
if(Normalized == 'true'){
  Normalizetable <- read.csv('normalized_table.csv', header = TRUE, stringsAsFactors = FALSE) #reads textfile containing names of reads
  names.all <- colnames(all.depth)
   
  
  for(x in 2:NCOL(all.depth)){
    name <- names.all[x]
    name <- strsplit(name, '_')
    name <- name[[1]]
    name <- as.numeric(name[length(name)])
    
    normalvalue <- Normalizetable[name,2]
    v<-all.depth[,x]
    if(length(v) >200){
      v[(length(v)-74):length(v)]<- NA
      v[1:75]<- NA
      
    }
    all.depth[,x] <- v/normalvalue
  }
}

#normalized column 
The.summary$normalized_average_coverage<-NA
index.for.summary <- 1


for(i in 2:ncol(all.depth)){
  v <- as.vector(all.depth[,i])
  

  #average coverage
  sum.coverage <- sum(as.numeric(v), na.rm = TRUE)
  average.coverage <- sum.coverage/as.numeric(The.summary[index.for.summary,which(colnames(The.summary)=="Ref.Length")])
  The.summary[index.for.summary,which(colnames(The.summary)=="normalized_average_coverage")] <- average.coverage
  
  index.for.summary <- index.for.summary+1
}

# write summary table output 

References_summary_base_coverage<-aggregate(The.summary$propotion_bases_with_coverage,by=list(References=The.summary$Reference),mean)
colnames(References_summary_base_coverage)[2]<-"mean_base_coverage"

References_summary_base_coverage<-References_summary_base_coverage[order(References_summary_base_coverage$mean_base_coverage),]

write.csv(References_summary_base_coverage,"base_coverage_summary.csv",row.names = FALSE)


write.csv(The.summary, file = 'Run_summary.csv', row.names = FALSE)
