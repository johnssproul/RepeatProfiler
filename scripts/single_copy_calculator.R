args <- commandArgs(trailingOnly = TRUE)
cat(file="singcopy_Warrnings.txt")
multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x,y) {merge(x, y, all = TRUE)}, datalist)
}

all.depth <- multmerge('single_cvs')
The.summary <- read.table('The_summary.txt', header = TRUE, stringsAsFactors = FALSE)

read_lengths<-read.table("read_lengths.txt",header = TRUE)
#initialize data frame
The.summary$Ref.Length <- NA
The.summary$Average.coverage <- NA
The.summary$Average.coverage <- NA
The.summary$max.coverage <- NA

index.for.summary <- 1

#loop to fill in initialized  data
for(i in 2:ncol(all.depth)){
  v <- as.vector(all.depth[,i])

  #reference length
  ref.length <- sum(!is.na(v))
  The.summary[index.for.summary,7] <- ref.length

  #average coverage
  names.all <- colnames(all.depth)
  name <- names.all[i]
  name.first <- strsplit(name, '_')
  name.first <- name.first[[1]]
  name.first <- as.numeric(name.first[length(name.first)])
  
  read_length <- as.numeric(read_lengths[name.first,2])
  
   bases_remove=read_length/2
   print(bases_remove)
   v<-na.omit(v)
   print(length(v))
   
   if(length(v) > 2*bases_remove){
   v<-v[1:(length(v)-bases_remove)]
   v<-v[bases_remove:length(v)]
   print("Hey it is working ")
   print("base_removal_done")
   
     
   }else{
     print("problemmmmmmmmmmmmmmmmmmm!")
     cat(paste(The.summary[i-1,1],"wasnt used in normalization because it shorter than twice the read length",read_length,"\n"),append = TRUE,file="singlecopy_warnings.txt")
     
     
  }
   The.summary[index.for.summary,8] <- 0
   
  if(length(v)!=0){
  sum.coverage <- sum(as.numeric(v), na.rm = TRUE)
  average.coverage <- sum.coverage/as.numeric(The.summary[index.for.summary,7])
  The.summary[index.for.summary,8] <- average.coverage
}
  #max coverage
   The.summary[index.for.summary,9] <- 0
   
   if(length(v)!=0){
     
  maximum <- max(v, na.rm = TRUE)
  The.summary[index.for.summary,9] <- maximum

   }
   index.for.summary <- index.for.summary+1
   
  }

#handles single reads
if(all(The.summary$Read1 == The.summary$Read2)){
  The.summary$Read2<-NULL
  names(The.summary)[names(The.summary) == 'Read1'] <- 'Read'
}

thenormal <- mean(The.summary$Average.coverage)

if(thenormal == 0){
  thenormal <- 1
}

Backupsummary <- The.summary

Normalized_dataframe <- data.frame(Sample = character(), NormalizedValue = character(), stringsAsFactors = FALSE)

Backupsummary <- Backupsummary[order(Backupsummary$Sample_index),]

refnumber <- as.numeric(args[1])

counter <- 1
while (NROW(Backupsummary) > 0) {
  currentable <- Backupsummary[1:refnumber,]

  Backupsummary <- Backupsummary[-(1:refnumber),]

  #print(NROW(Backupsummary))
  average <- mean(currentable$Average.coverage)

  if(average == 0){
    average <-  1
  }

  Normalized_dataframe[counter,2] <- average

  Normalized_dataframe[counter,1] <- counter

  counter <- counter+1
}

write.csv(Normalized_dataframe, "normalized_table.csv", row.names = FALSE)
write.table(The.summary,file = "Single_summary.csv", sep = ",",col.names = FALSE, row.names = FALSE)
cat(thenormal)
