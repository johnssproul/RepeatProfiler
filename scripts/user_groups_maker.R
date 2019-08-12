##### This script (called in 'repeatprof') partially automates the generation of the user_group.txt input file required by the -corr flag.

args <- commandArgs(trailingOnly = TRUE)

#argument is -p or -u
if(identical(as.character(args[1]), '-p') || identical(as.character(args[1]), '-u')){
  fofn1 <- readLines(file('fofn1.txt', 'r'))
  fofn2 <- readLines(file('fofn2.txt', 'r'))
  user.supplied <- data.frame(Read1 = character(), Read2 = character(), Group = character(), stringsAsFactors = FALSE)

  #get names of reads from fofn*.txt files
  for( i in 1:NROW(fofn1)){
    first.read <- strsplit(fofn1[i], split = '[//|/]')
    first.read <- first.read[[1]]
    first.read <- first.read[NROW(first.read)]

    second.read <- strsplit(fofn2[i], split = '[//|/]')
    second.read <- second.read[[1]]
    second.read <- second.read[NROW(second.read)]

    user.supplied[i,1] <- first.read
    user.supplied[i,2] <- second.read
    user.supplied[i,3] <- 'temporary'
  }

  #set read2 null if it is identica to read1
  if(identical(user.supplied$Read1, user.supplied$Read2)){
    user.supplied$Read2 <- NULL
  }

  write.table(user.supplied,'user_groups.txt',row.names = FALSE, quote = FALSE, sep = '\t')

  cat ('user_groups.txt has been created in the current directory.
    Replace TEMPORARY (it is a placeholder) with your desired group designations for each sample such that each member of a given group has the same number in that column.
    The command repeatprof pre-corr -v checks that the format is still correct, and allows you to view your file.')
}

#argument is -v
if(identical(as.character(args[1]), '-v')){
  user.supplied <- read.table('user_groups.txt', header = TRUE, stringsAsFactors = FALSE)

  col.names <- colnames(user.supplied)
  if(is.element('Read1',col.names) && is.element('Group',col.names)){
    print('correct format detected, file ready for correlation analysis (-corr flag) ')
    print(user.supplied)
  }else{
    print('Headers in incorrect format. For unpaired reads headers should be: |Read1|Group| For paired reads use: |Read1|Read2|Group| \n')
  }
}
