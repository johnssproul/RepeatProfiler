args = commandArgs(trailingOnly = TRUE)


if(identical(as.character(args[1]),"-p") || identical(as.character(args[1]),"-u") ){
fofn1<-readLines(file("fofn1.txt", "r"))
fofn2<-readLines(file("fofn2.txt", "r"))

user_supplied<-data.frame(Read1=character(),Read2=character(),Group=character(),stringsAsFactors = FALSE)


for( i in 1:NROW(fofn1)){
  
  first_read=strsplit(fofn1[i],split="[//|/]")
  first_read=first_read[[1]]
  first_read=first_read[NROW(first_read)]
  
  second_read=strsplit(fofn2[i],split="[//|/]")
  second_read=second_read[[1]]
  second_read=second_read[NROW(second_read)]
  
  
  user_supplied[i,1]<-first_read
  user_supplied[i,2]<-second_read
  
  user_supplied[i,3]<-"temporary"
  
  
  
  
  
}


if(identical(user_supplied$Read1,user_supplied$Read2)){
  
  user_supplied$Read2 <- NULL
 
   
}

write.table(user_supplied,"user_provided.txt",row.names = FALSE, quote =FALSE,sep = "\t")
cat ("Success!\n")
cat("user_provided.txt has been created in the current directory using provided reads\n")
cat("replace temporary (it is a placeholder) with your desired groups\n")
cat("After that type repeatprof pre-corr -v in the directory you have the user_provided.txt to view your file please and check if it is still in the right format\n")


}



if(identical(as.character(args[1]),"-v")){
  user_supplied<-read.table("user_provided.txt",header=TRUE,stringsAsFactors = FALSE)
  
  col_names<-colnames(user_supplied)
  if(is.element("Read1",col_names) && is.element("Group",col_names)){
  
  print("it is in correct format. You can go on with profiling with -corr flag  now ")
  
  print(user_supplied)
  }else{
    
    print("Wrong Headers. It should be Read1  Group for unpaired reads or  Read1 Read2 Group for paired reads")
  
    }
  
  
  
}
