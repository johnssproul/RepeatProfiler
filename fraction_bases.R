multi_poly_names <- read.table('multi_poly_names.txt', header = TRUE, stringsAsFactors = FALSE)
options(warn = -1) #warning messages ignored

fraction_table <- multi_poly_names

#initialize relevant columns
fraction_table$Read1 <- NA
fraction_table$Read2 <- NA
fraction_table$fraction_of_unmatched <- NA
fraction_table$Peaks_A <- ''
fraction_table$Peaks_T <- ''
fraction_table$Peaks_G <- ''
fraction_table$Peaks_C <- ''

index_conv <- read.table('Index_conv.txt', header = TRUE, stringsAsFactors = FALSE)

find_peaks <- function (x, m = 3){
shape <- diff(sign(diff(x, na.pad = FALSE)))
pks <- sapply(which(shape < 0), FUN = function(i){

z <- i-m+1
z <- ifelse(z > 0, z, 1)
w <- i+m+1
w <- ifelse(w < length(x), w, length(x))

if(all(x[c(z : i, (i + 2) : w)] <= x[i+1])) return(i+1) else return(numeric(0))})
  pks <- unlist(pks)
  pks
}

for (i in 1:NROW(multi_poly_names)) {
  name <- multi_poly_names[i,1]
  name_first <- strsplit(name, '_')
  name_first <- name_first[[1]]
  name_first <- as.numeric(name_first[length(name_first)])


  read1_first <- index_conv[name_first,1]
  read2_first <- index_conv[name_first,2]

  fraction_table[i,'Read1'] <- read1_first
  fraction_table[i,'Read2'] <- read2_first

  name_of_table_used <- paste('multi_poly/', multi_poly_names[i,1], '.txt', sep = '')
  multi_table <- read.table(name_of_table_used, header = TRUE)
  difference <- sum(multi_table$Depth)-sum(multi_table$CountMatch)
  fraction_table[i,'fraction_of_unmatched'] <- difference/sum(multi_table$Depth)
}

for (i in 1:NROW(multi_poly_names)) {
  name_of_table_used <- paste('multi_poly/', multi_poly_names[i,1], '.txt', sep = '')
  multi_table <- read.table(name_of_table_used, header = TRUE)
  m <- NROW(multi_table)*0.1

  for(t in 1:NROW(multi_table)){
    cut_off <- multi_table[t,2]*0.1

    #Base A
    if(multi_table[t,3] > cut_off){
      fraction_table[i,'Peaks_A'] <- paste(t, fraction_table[i,'Peaks_A'], sep = ' ', collapse = ' ')
    }

    #Base T
    if(multi_table[t,4] > cut_off){
      fraction_table[i,'Peaks_T'] <- paste(t, fraction_table[i,'Peaks_T'], sep = ' ', collapse = ' ')
    }

    #Base G
    if(multi_table[t,5] > cut_off){
      fraction_table[i,'Peaks_G'] <- paste(t, fraction_table[i,'Peaks_G'], sep = ' ', collapse = ' ')
    }

    #Base C
    if(multi_table[t,6]>cut_off){
      fraction_table[i,'Peaks_C'] <- paste(t, fraction_table[i,'Peaks_C'], sep = ' ', collapse = ' ')
    }
  }
}

### find common peaks and report them
num_rows <- NROW(fraction_table)

common_matrix <- matrix(NA, num_rows, num_rows)
rownames(common_matrix) <- fraction_table[,1]
colnames(common_matrix) <- fraction_table[,1]

common <- 0
#finding common peaks
for (r in 1:nrow(common_matrix)) {
  for (c in 1:ncol(common_matrix)) {
    v1 <- strsplit(fraction_table[r,'Peaks_A'], ' ')
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,'Peaks_A'], ' ')
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))

    v1 <- strsplit(fraction_table[r,'Peaks_T'], ' ')
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,'Peaks_T'], ' ')
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))

    v1 <- strsplit(fraction_table[r,'Peaks_G'], ' ')
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,'Peaks_G'], ' ')
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))

    v1 <- strsplit(fraction_table[r,'Peaks_C'], ' ')
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,'Peaks_C'], ' ')
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))
    common_matrix[r,c] <- common
    common <- 0

    if(r == c){
      common_matrix[r,c] <- 0
    }
  }
}

maxi <- max(common_matrix)

rownamess <- rownames(common_matrix)
if(maxi != 0){
  for (r in 1:nrow(common_matrix)) {
    for (c in r:ncol(common_matrix)) {
      if(common_matrix[r,c] != 0){
        name1 <- rownamess[r]
        name <- name1
        name_first <- strsplit(name, '_')
        name_first <- name_first[[1]]
        name_first <- as.numeric(name_first[length(name_first)])

        read1_first <- index_conv[name_first,1]
        read2_first <- index_conv[name_first,2]

      if(read1_first == read2_first){
        name2 <- rownamess[c]
        name <- name2
        name_first <- strsplit(name, '_')
        name_first <- name_first[[1]]
        name_first <- as.numeric(name_first[length(name_first)])

        read_for2 <- index_conv[name_first,1]
        stringg <- paste(name1, 'and', name2, 'have  ', common_matrix[r,c], 'common polymorphric postions', sep = ' ')
        cat(stringg, '\n')
        stringg <- paste('Reads involved are', read_for2, 'and', read1_first)
        cat(stringg, '\n \n')
        }else{
          name2 <- rownamess[c]
          name <- name2
          name_first <- strsplit(name, '_')
          name_first <- name_first[[1]]
          name_first <- as.numeric(name_first[length(name_first)])

          read_for2 <- index_conv[name_first,1]
          read2_for2 <- index_conv[name_first,2]
          stringg <- paste(name1, 'and', name2, 'have  ', common_matrix[r,c], 'common polymorphric postions', sep = ' ')
          cat(stringg, '\n' )
          stringg <- paste('ReadPair involved:', read1_first, ',', read2_first, 'AND', read_for2, read2_for2, sep = ' ')
          cat(stringg, '\n \n')
        }
      }
    }
  }
}else{
  cat('There are no closely related reads for this refrence or there is only 1 read/read pair. \n')
}

if(fraction_table$Read1 == fraction_table$Read2){
  fraction_table$Read2 <- NULL
  names(fraction_table)[names(fraction_table) == 'Read1'] <- 'Read'
}

fraction_table_towrite <- fraction_table

fraction_table_towrite$Peaks_A <- NULL
fraction_table_towrite$Peaks_T <- NULL
fraction_table_towrite$Peaks_G <- NULL
fraction_table_towrite$Peaks_C <- NULL

write.table(fraction_table_towrite, 'variation_analysis.tsv', row.names = FALSE)


########## Phylogenetic Stuff ##########
ref_size <- NROW(multi_table)
samples <- fraction_table[,1]
polyarray<-list()

for (r in 1:NROW(fraction_table)) {
  v <- replicate(ref_size, '-')

  #Base A
  v1 <- strsplit(fraction_table[r,'Peaks_A'], ' ')
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)

  if(NROW(v1) > 0){
    for (i in 1:NROW(v1)) {
      peak <- v1[[i]]

      if(v[[peak]] == '-'){
        v[[peak]] <- 'A'
      }else{
        v[[peak]] <- paste(v[[peak]], 'A', sep = ' ')
      }
    }
  }

  #Base T
  v1 <- strsplit(fraction_table[r,'Peaks_T'], ' ')
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)

  if(NROW(v1) > 0){
    for (i in 1:NROW(v1)) {
      peak <- v1[[i]]

      if(v[[peak]] == '-'){
        v[[peak]] <- 'T'
      }else{
        v[[peak]] <- paste(v[[peak]], 'T', sep = ' ')
      }
    }
  }

  #Base G
  v1 <- strsplit(fraction_table[r,'Peaks_G'], ' ')
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)

  if(NROW(v1) > 0){
    for (i in 1:NROW(v1)) {
      peak <- v1[[i]]

      if(v[[peak]] == '-'){
        v[[peak]] <- 'G'
      }else{
        v[[peak]] <- paste(v[[peak]], 'G', sep = ' ')
      }
    }
  }

  #Base C
  v1 <- strsplit(fraction_table[r,'Peaks_C'], ' ')
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)

  if(NROW(v1) > 0){
    for (i in 1:NROW(v1)) {
      peak <- v1[[i]]

      if(v[[peak]] == '-'){
        v[[peak]] <- 'C'
      }else{
        v[[peak]] <- paste(v[[peak]], 'C', sep = ' ')
      }
    }
  }

  print(r)
  polyarray[[r]] <- v
}

codes <- data.frame(codes = character(), meaning = character(), stringsAsFactors = FALSE)
codes[1,] <- c('A C', 'M')
codes[2,] <- c('A G', 'R')
codes[3,] <- c('A T', 'W')
codes[4,] <- c('C G', 'S')
codes[5,] <- c('C T', 'Y')
codes[6,] <- c('G T', 'K')
codes[7,] <- c('A C G', 'V')
codes[8,] <- c('A C T', 'H')
codes[9,] <- c('A G T', 'D')
codes[10,] <- c('C G T', 'B')
codes[11,] <- c('G A T C', 'N')

for (i in 1:NROW(polyarray)) {
 data<- polyarray[[i]]

 for (t in 1:NROW(data)) {
   v1 <- strsplit(data[t],' ')
   v1 <- v1[[1]]

   for(k in 1:NROW(codes)){
     v2 <- strsplit(codes[k,1], ' ')
     v2 <- v2[[1]]

     if(setequal(v1,v2)){
       data[t] <- codes[k,2]
     }
   }
 }

 polyarray[[i]] <- data
}

#saving the data in phylip format
onetime <- TRUE  #writing to the header only once in the phylip file

for (i in 1:NROW(polyarray)) {
  polydata <- paste(polyarray[[i]], collapse = '')

  #converting index back to name steps
  name <- samples[[i]]
  name_index <- strsplit(name, '_')
  name_index <- name_index[[1]]
  name_index <- as.numeric(name_index[length(name_index)])

  read1_name <- index_conv[name_index,1]
  read2_name <- index_conv[name_index,2]

  if(identical(read1_name, read2_name)){

    name_full <- samples[[i]]
    name_full <- strsplit(name_full, '_')
    name_full <- name_full[[1]]
    name_full <- name_full[1:length(name_full)-1]
    name_full <- paste(name_full, collapse = '_')
    name_full <- strsplit(name_full, '.', fixed = TRUE)
    name_full <- name_full[[1]]
    name_full <- name_full[name_full != 'fasta']
    name_full <- name_full[name_full != 'fa']
    name_full <- name_full[name_full != 'txt']
    name_full <- paste(name_full, collapse = '.')

    #prepare names in a visually appealing way by removing extentions and stuff like that
    name_of_sample <- strsplit(read1_name, '.', fixed = TRUE)
    name_of_sample <- name_of_sample[[1]]

    #this will remove extentions
    name_of_sample <- name_of_sample[name_of_sample != 'fq']
    name_of_sample <- name_of_sample[name_of_sample != 'fastq']
    name_of_sample <- name_of_sample[name_of_sample != 'gz']
    name_of_sample <- paste(name_of_sample, collapse = '.')
  }else{
    name_full <- samples[[i]]
    name_full <- strsplit(name_full, '_')
    name_full <- name_full[[1]]
    name_full <- name_full[1:length(name_full)-1]
    name_full <- paste(name_full, collapse = '_')
    name_full <- strsplit(name_full, '.', fixed = TRUE)
    name_full <- name_full[[1]]
    name_full <- name_full[name_full != 'fasta']
    name_full <- name_full[name_full != 'fa']
    name_full <- name_full[name_full != 'txt']
    name_full <- paste(name_full, collapse = '.')

    name_of_sample <- strsplit(read1_name, '_')
    name_of_sample <- name_of_sample[[1]]
    name_of_sample <- name_of_sample[1:length(name_of_sample)-1]
    name_of_sample <- paste(name_of_sample, collapse = '_')
  }

  filename <- paste(name_full, '.phy', sep = '')

  if(onetime == TRUE){
    header <- paste(NROW(samples), ref_size,sep = ' ')
    cat(c(header, '\n'), file = filename, append = TRUE)
    onetime <- FALSE
  }

  entry <- paste(name_of_sample, polydata, sep = ' ')
  cat(c(entry, '\n'), file = filename, append = TRUE)
}
