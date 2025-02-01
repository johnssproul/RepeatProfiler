##Feb 01 2025 -- Updated to include dashes in .phy file and encode variants as nucleotide. .phy file can either be analyzed as molecular morphological characters (i.e., morphology data), or nucleotide data
#if analyzed as the former, sites with multiple variant peaks will be evaluated as "A peak and T peak" during analysis. If analyzed as nucleotide data, sites with multiple variant peaks will be encoded as "A Peak or T peak".

##### This script (called in 'repeatprof') takes variant information from mpileup (after it has been summarized by pileup_basecount.py), 
##### calculates the fraction of variants at each position, and outputs a phylip file that encodes the patterns of variants as molecular morphological characters

##### initializes some variables and tables
multi_poly_names <- read.table("multi_poly_names.txt", header = TRUE, stringsAsFactors = FALSE)
options(warn = -1)

fraction_table <- multi_poly_names

fraction_table$Read1 <- NA
fraction_table$Read2 <- NA
fraction_table$fraction_of_unmatched <- NA
fraction_table$Peaks_A <- ""
fraction_table$Peaks_T <- ""
fraction_table$Peaks_G <- ""
fraction_table$Peaks_C <- ""
fraction_table$ReferenceBase <- NA

perecentagecutoff <- 0.1 #changing this value will allow smaller peaks to be encoded in .phy output. With the default setting of 0.1, a variant peak is only encoded if it is at least 10% of total coverage depth at that site.

#assigns index based on read name
index_conv <- read.table("index_conv.txt", header = TRUE, stringsAsFactors = FALSE)


for (i in 1:NROW(multi_poly_names)) {
  name <- multi_poly_names[i,1]
  name_first <- strsplit(name, "_")
  name_first <- name_first[[1]]
  name_first <- as.numeric(name_first[length(name_first)])

  Read1_first <- index_conv[name_first,1]
  Read2_first <- index_conv[name_first,2]

  fraction_table[i,"Read1"] <- Read1_first
  fraction_table[i,"Read2"] <- Read2_first

  name_of_table_used <- paste("multi_poly/", multi_poly_names[i,1], ".txt", sep = "")

  multi_table <- read.table(name_of_table_used, header = TRUE)

  difference <- sum(multi_table$Depth)-sum(multi_table$CountMatch)

  fraction_table[i,"fraction_of_unmatched"] <- difference/sum(multi_table$Depth)
  #fraction_table[i, "ReferenceBase"] <- paste(multi_table$ReferenceBase, collapse = " ")
}

for (i in 1:NROW(multi_poly_names)) {
  name_of_table_used <- paste("multi_poly/", multi_poly_names[i,1], ".txt", sep = "")
  
  multi_table <- read.table(name_of_table_used, header = TRUE)
  
  m <- NROW(multi_table) * perecentagecutoff  # Not used later in the code

  for (t in 1:NROW(multi_table)) {
    cut_off <- multi_table[t,2] * perecentagecutoff  # 10% of read depth at position t

    # Update ReferenceBase storage
    fraction_table[i, "ReferenceBase"] <- paste(multi_table$ReferenceBase, collapse = " ")
    cat("Updated ReferenceBase for position ", t, ": ", fraction_table[i, "ReferenceBase"], "\n")

    if (multi_table[t,3] > cut_off) {  # Base A
      fraction_table[i,"Peaks_A"] <- paste(t, fraction_table[i,"Peaks_A"], sep = " ", collapse = " ")
    }

    if (multi_table[t,4] > cut_off) {  # Base T
      fraction_table[i,"Peaks_T"] <- paste(t, fraction_table[i,"Peaks_T"], sep = " ", collapse = " ")
    }

    if (multi_table[t,5] > cut_off) {  # Base G
      fraction_table[i,"Peaks_G"] <- paste(t, fraction_table[i,"Peaks_G"], sep = " ", collapse = " ")
    }

    if (multi_table[t,6] > cut_off) {  # Base C
      fraction_table[i,"Peaks_C"] <- paste(t, fraction_table[i,"Peaks_C"], sep = " ", collapse = " ")
    }
  }
}

#message("PancakePancakePancakePancakePancakePancake")
#message(fraction_table)

##find common peaks and report them
num_rows=NROW(fraction_table)

common_matrix = matrix(NA, num_rows, num_rows)
rownames(common_matrix)<-fraction_table[,1]
colnames(common_matrix)<-fraction_table[,1]

common<-0

for (r in 1:nrow(common_matrix)) {
  for (c in 1:ncol(common_matrix)) {
    v1 <- strsplit(fraction_table[r,"Peaks_A"], " ")
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,"Peaks_A"], " ")
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))

    v1 <- strsplit(fraction_table[r,"Peaks_T"], " ")
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,"Peaks_T"], " ")
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))

    v1 <- strsplit(fraction_table[r,"Peaks_G"], " ")
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,"Peaks_G"], " ")
    v2 <- v2[[1]]
    v2 <- as.numeric(v2)

    common <- common+length(intersect(v2,v1))

    v1 <- strsplit(fraction_table[r,"Peaks_C"], " ")
    v1 <- v1[[1]]
    v1 <- as.numeric(v1)

    v2 <- strsplit(fraction_table[c,"Peaks_C"], " ")
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
        name_first <- strsplit(name, "_")
        name_first <- name_first[[1]]
        name_first <- as.numeric(name_first[length(name_first)])

        Read1_first <- index_conv[name_first,1]
        Read2_first <- index_conv[name_first,2]

        if(Read1_first == Read2_first){
          name2  <- rownamess[c]
          name <- name2
          name_first <- strsplit(name, "_")
          name_first <- name_first[[1]]
          name_first <- as.numeric(name_first[length(name_first)])

          Read_for2 <- index_conv[name_first,1]
          stringg <- paste(name1, "and", name2, "have  ", common_matrix[r,c], "common polymorphric postions", sep = " ")
          cat(stringg, "\n")
          stringg <- paste("Reads involved are", Read_for2, "and", Read1_first)
          cat(stringg, "\n \n")
        } else {
          name2 <- rownamess[c]
          name <- name2
          name_first <- strsplit(name, "_")
          name_first <- name_first[[1]]
          name_first <- as.numeric(name_first[length(name_first)])

          Read_for2 <- index_conv[name_first,1]
          Read2_for2 <- index_conv[name_first,2]
          stringg <- paste(name1, "and", name2, "have  ", common_matrix[r,c], "common polymorphric postions", sep = " ")
          cat(stringg, "\n" )

          stringg <- paste("ReadPair involved:", Read1_first, ",", Read2_first, "AND", Read_for2, Read2_for2, sep = " ")
          cat(stringg, "\n \n")
        }
      }
    }
  }
}else{
  cat("there is no closely related reads for this reference or there is only 1 read/read pair","\n")
}

cat("Contents of fraction_table$Read1:\n:")
print (fraction_table$Read1)

cat("Contents of fraction_table$Read2:\n:")
print (fraction_table$Read2)

if(all(fraction_table$Read1 == fraction_table$Read2)){
  fraction_table$Read2 <- NULL

  names(fraction_table)[names(fraction_table) == 'Read1'] <- 'Read'
}

fraction_table_towrite <- fraction_table

fraction_table_towrite$Peaks_A <- NULL
fraction_table_towrite$Peaks_T <- NULL
fraction_table_towrite$Peaks_G <- NULL
fraction_table_towrite$Peaks_C <- NULL

#write.table(fraction_table_towrite, "variation_analysis.tsv", row.names = FALSE)

########## PHYLOGENTIC STUFF ##########

#we use morpholigical characters to incode the bases A,T,G,C as 0,1,2,3. into an array of strings, so for example postion 1 has variants A,T,G it will encode it as "0 1 2" 
# this is later translated into its corropsonding morpholigcal character using codes defined in codes dataframe

Ref_size <- NROW(multi_table)
samples <- fraction_table[,1]

#message(NROW(fraction_table))
#message("PancakePancakePancakePancakePancakePancake")


Polyarray <- list()

# Process each row of fraction_table
for (r in 1:NROW(fraction_table)) {
  # Start with the ReferenceBase for each position
  v <- fraction_table[r, "ReferenceBase"]
  message("Start processing ReferenceBase for row ", r, ": ", v, "\n")
  v <- strsplit(gsub(" ", "", fraction_table[r, "ReferenceBase"]), "")[[1]]
  message("After splitting ReferenceBase into vector: ", v, "\n")
  v_copy <- v  # Copy the vector before processing each base

  # Process Base A (Peaks_A)
  v1 <- strsplit(fraction_table[r, "Peaks_A"], " ")
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)
  #message("Processing A peaks, initial list: ", v1, "\n")
  
  if (length(v1) > 0) {
    for (i in 1:length(v1)) {
      peak <- v1[i]
      #message("Processing A peak at position ", peak, ", current base in v: ", v[[peak]], "\n")
      if (v[[peak]] == v_copy[peak]) {  # Check value at same position in ReferenceBase
        v[[peak]] <- "0"  # Replace with code for A
        #message("Replacing with 0 at position ", peak, "\n")
      } else {
        v[[peak]] <- paste(v[[peak]], "0", sep = " ")  # Append code for A
        #message("Appending 0 at position ", peak, "\n")
      }
    }
  }
  message("Post processing A peaks for row ", r, ": ", v, "\n")

  # Process Base T (Peaks_T)
  v1 <- strsplit(fraction_table[r, "Peaks_T"], " ")
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)
  message("Processing T peaks, initial list: ", v1, "\n")

  if (length(v1) > 0) {
    for (i in 1:length(v1)) {
      peak <- v1[i]
      #message("Processing A peak at position ", peak, ", current base in v: ", v[[peak]], "\n")
      if (v[[peak]] == v_copy[peak]) {  # Check value at same position in ReferenceBase
        v[[peak]] <- "1"  # Replace with code for T
        #message("Replacing with 0 at position ", peak, "\n")
      } else {
        v[[peak]] <- paste(v[[peak]], "1", sep = " ")  # Append code for T
        #message("Appending 0 at position ", peak, "\n")
      }
    }
  }
  message("Post processing T peaks for row ", r, ": ", v, "\n")

  # Process Base G (Peaks_G)
  v1 <- strsplit(fraction_table[r, "Peaks_G"], " ")
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)
  message("Processing G peaks, initial list: ", v1, "\n")

  if (length(v1) > 0) {
    for (i in 1:length(v1)) {
      peak <- v1[i]
      #message("Processing A peak at position ", peak, ", current base in v: ", v[[peak]], "\n")
      if (v[[peak]] == v_copy[peak]) {  # Check value at same position in ReferenceBase
        v[[peak]] <- "2"  # Replace with code for G
        #message("Replacing with 0 at position ", peak, "\n")
      } else {
        v[[peak]] <- paste(v[[peak]], "2", sep = " ")  # Append code for G
        #message("Appending 0 at position ", peak, "\n")
      }
    }
  }
  message("Post processing G peaks for row ", r, ": ", v, "\n")

  # Process Base C (Peaks_C)
  v1 <- strsplit(fraction_table[r, "Peaks_C"], " ")
  v1 <- v1[[1]]
  v1 <- as.numeric(v1)
  message("Processing C peaks, initial list: ", v1, "\n")

  if (length(v1) > 0) {
    for (i in 1:length(v1)) {
      peak <- v1[i]
      #message("Processing A peak at position ", peak, ", current base in v: ", v[[peak]], "\n")
      if (v[[peak]] == v_copy[peak]) {  # Check value at same position in ReferenceBase
        v[[peak]] <- "3"  # Replace with code for C
        #message("Replacing with 0 at position ", peak, "\n")
      } else {
        v[[peak]] <- paste(v[[peak]], "3", sep = " ")  # Append code for C
        #message("Appending 0 at position ", peak, "\n")
      }
    }
  }
  message("Post processing C peaks for row ", r, ": ", v, "\n")

  # Store processed result in Polyarray
  Polyarray[[r]] <- v
}

# Output Polyarray
message("Generated Polyarray")
#message(Polyarray)



##### Codes variant peaks as IUPAC ambiguities
codes <- data.frame(codes = character(), meaning = character(), stringsAsFactors = FALSE)
codes[1,] <- c("0 3", "M") # i.e., variant peaks at A and C  -- if analyzed as morphological data, this means A and C, if DNA sequence data it will be interpred as A or C
codes[2,] <- c("0 2", "R") # i.e., variant peaks at A and G -- if analyzed as morphological data, this means A and G, if DNA sequence data it will be interpred as A or G
codes[3,] <- c("0 1", "W") # i.e., variant peaks at A and T -- if analyzed as morphological data, this means A and T, if DNA sequence data it will be interpred as A or T
codes[4,] <- c("3 2", "S") # i.e., variant peaks at C and G -- if analyzed as morphological data, this means C and G, if DNA sequence data it will be interpred as C or G
codes[5,] <- c("3 1", "Y") # i.e., variant peaks at C and T -- if analyzed as morphological data, this means C and T, if DNA sequence data it will be interpred as C or T
codes[6,] <- c("2 1", "K") # i.e., variant peaks at G and T -- if analyzed as morphological data, this means G and T, if DNA sequence data it will be interpred as G or T
codes[7,] <- c("0 3 2", "V") # i.e., variant peaks at A and C and G -- if analyzed as morphological data, this means A and C and G, if DNA sequence data, replace ands with ors
codes[8,] <- c("0 3 1", "H") # i.e., variant peaks at A and C and T -- if analyzed as morphological data, this means A and C and T, if DNA sequence data, replace ands with ors
codes[9,] <- c("0 2 1", "D") # i.e., variant peaks at A and G and T -- if analyzed as morphological data, this means A and G and T, if DNA sequence data, replace ands with ors
codes[10,] <- c("3 2 1", "B")  # i.e., variant peaks and C and G and T -- if analyzed as morphological data, this means C and G and T, if DNA sequence data, replace ands with ors
codes[11,] <- c("2 0 1 3", "N")  # i.e., variant peaks at G and A and T and C -- if analyzed as morphological data, this means G and A and T and C, if DNA sequence data, replace ands with ors
codes[12,] <- c("0", "A")  # A i.e., variant peak at A
codes[13,] <- c("1", "T")  # T i.e., variant peak at T
codes[14,] <- c("2", "G")  # G i.e., variant peak at G
codes[15,] <- c("3", "C")  # C i.e., variant peak at C

# Ambiguous stuff
for (i in 1:NROW(Polyarray)) {
  data <- Polyarray[[i]]

  for (t in 1:NROW(data)) {
    v1 <- strsplit(data[t], " ")
    v1 <- v1[[1]]

    for (k in 1:NROW(codes)) {
      v2 <- strsplit(codes[k, 1], " ")
      v2 <- v2[[1]]

      if (setequal(v1, v2)) {
        data[t] <- codes[k, 2]
      }
    }
  }

  Polyarray[[i]] <- data
}

# Saving the data in Phylip format
onetime <- TRUE  # Makes writing to the header only once in the Phylip file

for (i in 1:NROW(Polyarray)) {
  polydata <- paste(Polyarray[[i]], collapse = "")

  # Converting index back to name steps
  name <- samples[[i]]
  name_index <- strsplit(name, "_")
  name_index <- name_index[[1]]
  name_index <- as.numeric(name_index[length(name_index)])

  Read1_name <- index_conv[name_index, 1]
  Read2_name <- index_conv[name_index, 2]

  if (identical(Read1_name, Read2_name)) {
    name_full <- samples[[i]]
    name_full <- strsplit(name_full, "_")
    name_full <- name_full[[1]]
    name_full <- name_full[1:length(name_full) - 1]
    name_full <- paste(name_full, collapse = "_")
    name_full <- strsplit(name_full, ".", fixed = TRUE)
    name_full <- name_full[[1]]
    name_full <- name_full[name_full != "fasta"]
    name_full <- name_full[name_full != "fa"]
    name_full <- name_full[name_full != "txt"]
    name_full <- paste(name_full, collapse = ".")

    # Prepare names in a visually appealing way by removing extensions and stuff like that
    name_of_sample <- strsplit(Read1_name, ".", fixed = TRUE)
    name_of_sample <- name_of_sample[[1]]

    # Remove extensions
    name_of_sample <- name_of_sample[name_of_sample != "fq"]
    name_of_sample <- name_of_sample[name_of_sample != "fastq"]
    name_of_sample <- name_of_sample[name_of_sample != "gz"]

    name_of_sample <- paste(name_of_sample, collapse = ".")
  } else {
    name_full <- samples[[i]]
    name_full <- strsplit(name_full, "_")
    name_full <- name_full[[1]]
    name_full <- name_full[1:length(name_full) - 1]
    name_full <- paste(name_full, collapse = "_")
    name_full <- strsplit(name_full, ".", fixed = TRUE)
    name_full <- name_full[[1]]
    name_full <- name_full[name_full != "fasta"]
    name_full <- name_full[name_full != "fa"]
    name_full <- name_full[name_full != "txt"]
    name_full <- paste(name_full, collapse = ".")

    name_of_sample <- strsplit(Read1_name, "_")
    name_of_sample <- name_of_sample[[1]]
    name_of_sample <- name_of_sample[1:length(name_of_sample) - 1]
    name_of_sample <- paste(name_of_sample, collapse = "_")
  }

  filename <- paste(name_full, ".phy", sep = "")

  if (onetime == TRUE) {
    header <- paste(NROW(samples), Ref_size, sep = " ")
    cat(c(header, "\n"), file = filename, append = TRUE)
    onetime <- FALSE
  }

  entry <- paste(name_of_sample, polydata, sep = " ")

  cat(c(entry, "\n"), file = filename, append = TRUE)
}
