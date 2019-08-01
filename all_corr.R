cat("Full correlation analysis is starting... \n")

multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x,y) {merge(x, y, all = TRUE)}, datalist)
}

all_depth_cvs <- multmerge('all_depth_cvs')
user_supplied <- read.table('user_provided.txt', header = TRUE, stringsAsFactors = FALSE)

#intalize the all_corr table
all_corr <- data.frame(groups = as.character())
groups <- unique(user_supplied$Group)
all_corr <- cbind(groups,all_corr$groups)
all_corr <- as.data.frame(all_corr)
number_of_samples <- NROW(user_supplied)

if(NCOL(all_depth_cvs) > 2){
  all_depth_cvs <- all_depth_cvs[,-1] #remove position column
  intial_col <- NCOL(all_depth_cvs)

  while(NCOL(all_depth_cvs)>0){
    current_cvs_samples <- all_depth_cvs[,1:number_of_samples]
    current_cvs_samples <- na.omit(current_cvs_samples) #this deletes  NA values caused by other refrences positions
    current_cvs_samples <- current_cvs_samples[, colSums(current_cvs_samples != 0) > 0] #remove columns containing only zeroes
    all_depth_cvs <- all_depth_cvs[,-(1:number_of_samples)]

    #check if at least 2 columns remain
    if(NCOL(current_cvs_samples) > 1){
      for (r in 1:NCOL(current_cvs_samples)) {
        for (c in r:NCOL(current_cvs_samples)) {
          #get the number of groups
          all_names <- colnames(current_cvs_samples)
          name_row <- all_names[r]
          name_row <- strsplit(name_row, '_')
          name_row <- name_row[[1]]
          name_row <- as.numeric(name_row[length(name_row)])

          group_row <- user_supplied[name_row,'Group']

          name_col <- all_names[c]
          name_col <- strsplit(name_col, '_')
          name_col <- name_col[[1]]
          name_col <- as.numeric(name_col[length(name_col)])

          group_col <- user_supplied[name_col,'Group']

          #find the name of the refrence
          name_full <- all_names[r]
          name_full <- strsplit(name_full, "_")
          name_full <- name_full[[1]]
          name_full <- name_full[1:length(name_full)-1]
          name_full <- paste(name_full, collapse = "_")
          name_full <- strsplit(name_full,".",fixed = TRUE)
          name_full <- name_full[[1]]
          name_full <- name_full[name_full != "fasta"]
          name_full <- name_full[name_full != "fa"]
          name_full <- name_full[name_full != "txt"]
          name_full <- paste(name_full, collapse = ".")

          if(!(any(colnames(all_corr) == name_full)))  {
            all_corr$place_holder <- 0
            names(all_corr)[names(all_corr) == 'place_holder'] <- name_full
          }

          cor <- cor.test(current_cvs_samples[,r], current_cvs_samples[,c], methods = c('spearman'))$estimate

          if(is.na(cor)){
            cor <- 0
          }

          if(identical(group_col, group_row)){
            if (r != c){
              print(group_col)
              all_corr[which(all_corr$groups == group_row), name_full] <- all_corr[which(all_corr$groups == group_row), name_full]+cor
            }
          }
        }
      }
    }else{
      cat("Correlation analysis for one of the refrences couldn't be done because there is only 1 sample with non-zero depth values for this reference .\n", file = "R_all_correlation_errors.txt", append = TRUE)
      print("Correlation analysis for one of the refrences couldn't be done because there is only 1 sample with non-zero depth values for this reference.")
    }
  #print("new loop")
  }

  #get the average of each filed where we summed the correlation
  for (i in 1:NROW(groups)) {
    unique_comparision <- 0
    current_group <- groups[i]
    print(current_group)

    for (r in 1:NROW(which(user_supplied$Group == current_group))) {
      for (c in r:NROW(which(user_supplied$Group == current_group))) {
        if(r != c){
          unique_comparision <- unique_comparision+1
        }
      }
    }
    print(unique_comparision)
    all_corr[which(all_corr$groups == current_group),2:NCOL(all_corr)]<- all_corr[which(all_corr$groups == current_group),2:NCOL(all_corr)]/unique_comparision
  }
}else{
  cat("Correlation analysis cannot be done with only one pair of reads or a single unpaired read or a single refrence with 1 pair of read or a single unpaired read. \n",  file = "R_all_correlation_errors.txt", append = TRUE)
  print("Correlation analysis cannot be done with only one pair of reads or a single unpaired read.")
}

all_corr[is.na(all_corr)] <- "No correlation coefficient calculated due to lack of enough samples."
write.csv(all_corr, "full_correlation_analysis.csv", row.names = FALSE)
print("Full correlation analysis finished.")
