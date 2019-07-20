args = commandArgs(trailingOnly = TRUE)
#args[1] <- 'temp_cvs' #path-specific

cat('Plotting correlation', args[1], '... \n')

.libPaths(as.character(args[2])) # brew stuff

library(ggplot2)


#code if file type specified
ft <- '.png'

# if(is.null(args[3]) || is.na(args[3])) {
#   ft <- '.png'
# } else if (grepl('.', args[3], fixed = TRUE)){
#   ft <- args[3]
# } else {
#   print('Invalid input. Setting file type to default: ".png"')
# }

#merges all files located in 'mypath' into one dataframe
multmerge = function(mypath){
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x,y) {merge(x, y, all = TRUE)}, datalist)
}

#multimerge files in temp_cvs directory
all.depth.cvs = multmerge('temp_cvs')

#check if there is more than 1 read to do correlation analysis
if(NCOL(all.depth.cvs) > 2){
  all.depth.cvs <- all.depth.cvs[,-1] #remove position column
  all.depth.cvs <- all.depth.cvs[, colSums(all.depth.cvs != 0) > 0] #remove columns containing only zeroes

  #check if at least 2 columns remain
  if(NCOL(all.depth.cvs) > 1){
    #prepare correlation matrix
    num.rows = ncol(all.depth.cvs)
    colnames(all.depth.cvs)
    cor.matrix = matrix(NA, num.rows, num.rows)
    rownames(cor.matrix) <- colnames(all.depth.cvs)
    colnames(cor.matrix) <- colnames(all.depth.cvs)

    #fill correlation matrix with respective correlations
    for (r in 1:nrow(cor.matrix)) {
      for (c in 1:ncol(cor.matrix)) {
        cor = cor.test(all.depth.cvs[,r], all.depth.cvs[,c], methods = c('spearman'))$estimate

        if(is.na(cor)){
          cor = 0
        }

        cor.matrix[r,c] <- cor
      }
    }

    #save cor.matrix to .csv file
    #matrix.name = './Test_plots/cor.csv' #path-specific
    matrix.name = paste(as.character(args[1]),'/correlation_matrix.csv', sep = '')
    write.csv(cor.matrix, file = matrix.name)

    #get names of reads and grouping information
    index.conv <- read.table('Index_conv.txt', header = TRUE, stringsAsFactors = FALSE)
    user.supplied <- read.table('user_provided.txt', header = TRUE, stringsAsFactors = FALSE)

    #prepare dataframe of correlations based on groups
    all.cor <- data.frame(Correlation = numeric(), Grouping = character(), stringsAsFactors = FALSE)

    row.counter = 1

    #loops through all reads listed in user_supplied.txt and does correlation test within and between specified groupings
    for (first in 1:ncol(all.depth.cvs)) {
      names.all <- colnames(all.depth.cvs)
      name <- names.all[first]
      name.first <- strsplit(name, '_')
      name.first <- name.first[[1]]
      name.first <- as.numeric(name.first[length(name.first)])

      read1.first = index.conv[name.first,'Read1']
      f = as.numeric(which(user.supplied$Read1 == read1.first))
      group.first = user.supplied[f, 'Group']

      number = as.numeric(first)

      for (second in number:ncol(all.depth.cvs)) {
        name <- names.all[second]
        name.second <- strsplit(name, '_')
        name.second <- name.second[[1]]
        name.second <- as.numeric(name.second[length(name.second)])

        read1.second = index.conv[name.second,'Read1']
        z = as.numeric(which(user.supplied$Read1 == read1.second))
        group.second = user.supplied[z,'Group']

        cor = cor.test(all.depth.cvs[,first], all.depth.cvs[,second], methods = c('spearman'))$estimate

        if(is.na(cor)){
          cor = 0
        }

        if(group.first == group.second){
          group = 'Within'
        }else{
          group = 'Between'
        }

        all.cor[row.counter,] <- c(cor, group)

        row.counter = row.counter+1
      }
    }

    #makes all data in Correlation column numeric
    all.cor$Correlation <- as.numeric(all.cor$Correlation)

    #sets title
    t <- paste('Correlation Plot of ', args[1], sep = '')

    #creates stacked histogram object of correlations
    correlationPlot <- ggplot(all.cor, aes(x = Correlation, group = Grouping, fill = Grouping, color = Grouping))+
      scale_x_continuous(breaks = round(seq(min(all.cor$Correlation), max(all.cor$Correlation), by = 0.5), 1))+
      geom_histogram(position = 'stack', alpha = 0.5, binwidth = 0.05)+
      scale_colour_manual(values = c('darkorchid', 'seagreen4'))+
      scale_fill_manual(values = c('darkorchid', 'seagreen4'))+
      theme_bw()+
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
            plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6))+ #formats plot title
      ylab('Count')+
      ggtitle(t)

    #correlationPlot #testing

    #saves correlation plot to plot.name
    #plot.name = paste('./Test_plots/Correlation_plot', ft, sep = '') #path-specific
    plot.name = paste(as.character(args[1]), '/Correlation_plot', ft, sep = '')
    ggsave(as.character(plot.name), correlationPlot, units = 'mm', width = 175, height = 50)
    cat('file saved to',  plot.name, '\n')

#error reporting messages
  }else{
    cat('Correlation analysis cannot be done because there is only 1 read with non-zero depth values.\n', file = " R_correlation_errors.txt",append = TRUE)
    print('Correlation analysis cannot be done because there is only 1 read with non-zero depth values.')
  }
}else{
  cat('Correlation analysis cannot be done with only one pair of reads or a single unpaired read. \n',  file = " R_correlation_errors.txt",append = TRUE)
  print('Correlation analysis cannot be done with only one pair of reads or a single unpaired read.')
}
