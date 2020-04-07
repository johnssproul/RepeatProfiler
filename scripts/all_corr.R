print('Starting correlation analysis')
args <- commandArgs(trailingOnly = TRUE)
#.libPaths(as.character(args[1])) #brew stuff

library(ggplot2)
ft<-".png"

Normalized <- as.character(args[2]) #normalize stuff
print(paste('CorrNormalized', Normalized))

multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x,y) {merge(x, y, all = TRUE)}, datalist)
}

map_depth_allrefs <- multmerge('map_depth_allrefs')
index.conv <- read.table('Index_conv.txt', header = TRUE, stringsAsFactors = FALSE)

#normalization codes
if(Normalized=="true"){
  Normalizetable <- read.csv('normalized_table.csv', header = TRUE, stringsAsFactors = FALSE) #reads textfile containing names of reads
  names.all <- colnames(map_depth_allrefs)

   for(x in 2:NCOL(map_depth_allrefs)){
    
    name<-names.all[x]
    name <- strsplit(name, '_')
    name <- name[[1]]
    name <- as.numeric(name[length(name)])
    

    normalvalue <- Normalizetable[name,2]
    print(normalvalue)
    
    map_depth_allrefs[,x] <- map_depth_allrefs[,x]/normalvalue
  }
}
###

user_supplied <- read.table('user_groups.txt', header = TRUE, stringsAsFactors = FALSE)

#intalize the all_corr table
all_corr <- data.frame(groups = as.character(), stringsAsFactors = FALSE)
groups <- unique(user_supplied$Group)
groupsxothers <- paste(groups, 'xOthers', sep = '')#doing cross group correlation
allgroups <- append(groups, groupsxothers, after = length(groups)) #append vector group with the x others vector
all_corr <- cbind(allgroups, all_corr$groups)
all_corr <- as.data.frame(all_corr)
names(all_corr)[names(all_corr) == 'allgroups'] <- 'groups'
#initialize dataframe containing all correlations for plotting
all_species <- NULL
all_groups <- NULL
all_correlation <-NULL
all_counter <- 1
#

number_of_samples <- NROW(user_supplied)
###

if(NCOL(map_depth_allrefs) > 2){
  map_depth_allrefs <- map_depth_allrefs[,-1] #remove position column
  intial_col <- NCOL(map_depth_allrefs)

  while(NCOL(map_depth_allrefs) > 0){
    current_cvs_samples <- map_depth_allrefs[,1:number_of_samples]
    current_cvs_samples <- na.omit(current_cvs_samples) #deletesNA values caused by other references positions
    current_cvs_samples <- current_cvs_samples[, colSums(current_cvs_samples != 0) > 0] #remove columns containing only zeroes
    map_depth_allrefs <- map_depth_allrefs[,-(1:number_of_samples)]
    df <- data.frame(matrix(ncol = NROW(allgroups), nrow = 0)) #initialize the table to produce boxplots
    colnames(df) <- allgroups
    rowcounter <- 0

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
          ###

          #find the name of the reference
          name_full <- all_names[r]
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
          ###

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
              all_corr[which(all_corr$groups == group_row),name_full] <- all_corr[which(all_corr$groups == group_row),name_full]+cor
              rowcounter <- rowcounter+1

              df[rowcounter,which(all_corr$groups == group_row)] <- cor
            }
          }
        }
      }

      #start for cross correlation analysis
      print('start cross corr')

      for (x in 1:NROW(groupsxothers)){
        thegroup <- strsplit(groupsxothers[x], 'x', fixed = TRUE)
        thegroup <- thegroup[[1]]

        thegroup <- thegroup[1:length(thegroup)-1]
        thegroup <- paste(thegroup, collapse = 'x')

        print(groupsxothers[x])
        comparison_counter <- 0

        if(NCOL(current_cvs_samples) > 1){
          for (r in 1:NCOL(current_cvs_samples)) {
            all_names <- colnames(current_cvs_samples)
            name_row <- all_names[r]
            name_row <- strsplit(name_row, '_')
            name_row <- name_row[[1]]
            name_row <- as.numeric(name_row[length(name_row)])

            group_row <- user_supplied[name_row,'Group']
            group_row<-as.character(group_row)

            if(identical(group_row,thegroup)){
              print('new sample')

              for (c in 1:NCOL(current_cvs_samples)) {

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
                ###

                #in this block the code will find the name of the reference
                name_full <- all_names[r]
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
                ###

                cor <- cor.test(current_cvs_samples[,r], current_cvs_samples[,c], methods = c('spearman'))$estimate

                if(is.na(cor)){
                  cor <- 0
                }

                if(r != c){
                  if(!(identical(group_col, group_row))){
                    print(paste(group_row, 'x', group_col, sep = ' '))

                    all_corr[which(all_corr$groups == groupsxothers[x]),name_full] <- all_corr[which(all_corr$groups == groupsxothers[x]),name_full]+cor
                    comparison_counter <- comparison_counter+1

                    rowcounter <- rowcounter+1
                    df[rowcounter,which(all_corr$groups == groupsxothers[x])] <- cor
                  }
                }
              }
            }
          }
        }

        print(comparison_counter)

        all_corr[which(all_corr$groups == groupsxothers[x]),name_full] <- all_corr[which(all_corr$groups == groupsxothers[x]),name_full]/comparison_counter
      } # end of cross correlation analysis

      print(name_full)
      df <- df[,order(colnames(df),decreasing = FALSE)]
      df <- as.data.frame(df)

      for(i in 1:length(colnames(df))) {
        for(j in 1:length(df[[i]])) {
          if(!is.na(df[[i]][j])) {
            all_species[all_counter] <- name_full
            all_groups[all_counter] <- colnames(df)[i]
            all_correlation[all_counter] <- df[[i]][j]
            all_counter <- all_counter+1
          }
        }
      }

      all <- data.frame(all_species, all_groups, all_correlation)

      pathtostoredf <- paste('correlation_analysis/correlation_data/', name_full, '.csv', sep = '')
      write.csv(df, file = pathtostoredf, row.names = FALSE)

      #plot_title <- paste('correlation_analysis/', name_full, 'corrbarplot.pdf', sep = '_') #testing
      plot_title <- paste('correlation_analysis/correlation_boxplots_by_reference/',name_full, '_boxplot.pdf', sep = '')
      pdf(plot_title, width = 15)

      boxplot(df, na.rm = TRUE, main = name_full,
              xlab = 'Group Comparison Made',
              ylab = 'Correlation Value',
              boxwex = 0.8,
              #horizontal = TRUE, #delete for vertical boxplots
              col = 'darkgoldenrod1', border = 'firebrick')

      dev.off()
      
########## start histogram plotting ########## 
      colnamestochange <- colnames(current_cvs_samples)
      
      for(x in 1:NCOL(current_cvs_samples)){
        nametochange <-colnamestochange[x]
        
        name.second <- strsplit(nametochange, '_',fixed = TRUE)
        name.second <- name.second[[1]]
        name.second <- as.numeric(name.second[length(name.second)])
        
        readname <- index.conv[name.second,'Read1']
        z <- as.numeric(which(user_supplied$Read1 == readname))
        groupname <- user_supplied[z,'Group']
        
        if(NCOL(user_supplied) == 3){ # THIS MEANS THE DATA IS READ PAIRED 
          print("paired")
          readname <- strsplit(readname,"_")
          readname <- readname[[1]]
          readname <- readname[1:length(readname)-1]
          readname <- paste(readname,collapse="_")
        } else if (NCOL(user_supplied) == 2) {
          readname <- strsplit(readname,".",fixed = TRUE)
          readname <- readname[[1]]
          
          #this will remove extentions 
          readname <- readname[readname != "fq"]
          readname <- readname[readname != "fastq"]
          readname <- readname[readname != "gz"]
          
          readname <- paste(readname,collapse=".")
        }
        
        nametochange <- strsplit(nametochange, '_')
        nametochange <- nametochange[[1]]
        
        nametochange[length(nametochange)] <- paste(readname,groupname,sep = "_")
        
        nametochange <- paste(nametochange,collapse = "_")
        
        print(readname)
        names(current_cvs_samples)[x] <- as.character(nametochange)
      }
    
      #drawing historgram
      num.rows <- ncol(current_cvs_samples)
      cor.matrix <- matrix(NA, num.rows, num.rows)
      rownames(cor.matrix) <- colnames(current_cvs_samples)
      colnames(cor.matrix) <- colnames(current_cvs_samples)
      
      #fill correlation matrix with respective correlations
      for (r in 1:nrow(cor.matrix)) {
        for (c in 1:ncol(cor.matrix)) {
          cor <- cor.test(current_cvs_samples[,r], current_cvs_samples[,c], methods = c('spearman'))$estimate
          
          if(is.na(cor)){
            cor <- 0
          }
          
          cor.matrix[r,c] <- cor
        }
      }
      
      #save cor.matrix to .csv file
      #matrix.name <- './Test_plots/cor.csv' #testing
      matrix.name <- paste("correlation_analysis",'/correlation_data/',name_full,'_matrix.csv', sep = '')
      write.csv(cor.matrix, file = matrix.name)
      
      
      #prepare dataframe of correlations based on groups
      all.cor <- data.frame(Correlation = numeric(), Grouping = character(), stringsAsFactors = FALSE)
      
      row.counter <- 1
      
      #loops through all reads listed in user_supplied.txt and does correlation test within and between specified groupings
      for (first in 1:NCOL(current_cvs_samples)) {
        names.all <- colnamestochange #colnames(all.depth.cvs)
        name <- names.all[first]
        name.first <- strsplit(name, '_')
        name.first <- name.first[[1]]
        name.first <- as.numeric(name.first[length(name.first)])
        
        read1.first <- index.conv[name.first,'Read1']
        f <- as.numeric(which(user_supplied$Read1 == read1.first))
        group.first <- user_supplied[f, 'Group']
        
        number <- as.numeric(first)
        
        for (second in number:ncol(current_cvs_samples)) {
          name <- names.all[second]
          name.second <- strsplit(name, '_')
          name.second <- name.second[[1]]
          name.second <- as.numeric(name.second[length(name.second)])
          
          read1.second <- index.conv[name.second,'Read1']
          z <- as.numeric(which(user_supplied$Read1 == read1.second))
          group.second <- user_supplied[z,'Group']
          
          cor <- cor.test(current_cvs_samples[,first], current_cvs_samples[,second], methods = c('spearman'))$estimate
          
          if(is.na(cor)){
            cor <- 0
          }
          
          if(group.first == group.second){
            group <- 'Within'
          }else{
            group <- 'Between'
          }
          
          all.cor[row.counter,] <- c(cor, group)
          
          row.counter <- row.counter+1
        }
      }
      
      #makes all data in Correlation column numeric
      all.cor$Correlation <- as.numeric(all.cor$Correlation)
      
      t <- paste('Correlation Plot of ', name_full, sep = '') #title
      
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
      #plot.name <- paste('./Test_plots/Correlation_plot', ft, sep = '') #testing
      plot.name <- paste("correlation_analysis",'/correlation_histograms/',name_full, ft, sep = '')
      ggsave(as.character(plot.name), correlationPlot, units = 'mm', width = 175, height = 50)
      cat('file saved to',  plot.name, '\n')
#end of histogram plots      
    }else{
      cat('Correlation analysis and profile generation skipped for one or more references skipped due to zero-depth values.\n', file = 'R_all_correlation_errors.txt', append = TRUE)
      print('Correlation analysis and profile generation skipped for one or more references skipped due to zero-depth values')
    }

    print('new loop')
  }
  
  #this part is to get the average of each filed where we summed the correlation
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

    all_corr[which(all_corr$groups == current_group),2:NCOL(all_corr)] <- all_corr[which(all_corr$groups == current_group),2:NCOL(all_corr)]/unique_comparision
  }
}else{
  cat('Correlation analysis cannot be done in a run that lacks multiple samples. \n',  file = 'R_all_correlation_errors.txt', append = TRUE)
  print('Correlation analysis cannot be done in a run that lacks multiple samples.')
}

all_corr[is.na(all_corr)] <- 'Correlation coefficient cannot be calculated cannot be done in a run that lacks multiple samples'

all_corr <- all_corr[order(all_corr$groups),]
all_corr <- as.data.frame(all_corr)

write.csv(all_corr, 'correlation_analysis/correlation_summary.csv',row.names = FALSE)

########## Plotting All References by Groups Plots ##########
for (i in 1:length(groups)) {
  data <- subset(all, (grepl(groups[i], all$all_groups)))
  t <- paste(groups[i], 'Correlation for References', sep = ' ')
  file <- paste('correlation_analysis/correlation_boxplots_by_group/', groups[i], '_group', '_boxplot.pdf', sep = '')

  plot <- ggplot(data = data, aes(x = all_species, y = all_correlation, fill = all_groups))+
    geom_boxplot(data = data, position = 'dodge2', width = 0.7, outlier.size = 0.2, colour = 'gray25', size = 0.2)+
    scale_fill_manual(name = 'Groups', values = c('darkorchid2', 'seagreen3'))+
    #guides(fill = guide_legend(reverse = TRUE))+ #horizontal boxplots
    xlab('')+ ylab('Correlation')+
    theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
                      plot.title = element_text(size = 6, face = 'bold'),
                      axis.title = element_text(size = 6), axis.text=element_text(size=6))+ #formats plot title
    theme(axis.text.x = element_text(angle = 90, hjust = 1), #flips reference names to be readable
          legend.text = element_text(size = 6))+ #formats legend
    #coord_flip()+ #horizontal boxplots
    ggtitle(t)

  
  ggsave(as.character(file), plot, width = 8, height = 8)
}

print('Correlation analysis finished.')
