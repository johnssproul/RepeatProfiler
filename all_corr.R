print('Full correlation analysis is starting')
args <- commandArgs(trailingOnly = TRUE)
#args[1] <- 'false' #path-specific

library(ggplot2)


Normalized <- as.character(args[1]) #normalize stuff
print(paste('CorrNormalized', Normalized))

multmerge <- function(mypath){
  filenames <- list.files(path = mypath, full.names = TRUE)
  datalist <- lapply(filenames, function(x){read.csv(file = x, header = T)})
  Reduce(function(x,y) {merge(x, y, all = TRUE)}, datalist)
}

all_depth_cvs <- multmerge('all_depth_cvs')

#normalization codes
if(Normalized == 'true'){
  Normalizetable <- read.csv('normalized_table.csv', header = TRUE, stringsAsFactors = FALSE) #reads textfile containing names of reads
  names.all <- colnames(all_depth_cvs)

  for(x in 2:NCOL(all_depth_cvs)){
    name <- names.all[x]
    name <- strsplit(name, '_')
    name <- name[[1]]
    name <- as.numeric(name[length(name)])

    normalvalue <- Normalizetable[name,2]

    all_depth_cvs[,x] <- all_depth_cvs[,x]/normalvalue
  }
}
###

user_supplied <- read.table('user_provided.txt', header = TRUE, stringsAsFactors = FALSE)

#intalize the all_corr table
all_corr <- data.frame(groups = as.character(), stringsAsFactors = FALSE)
groups <- unique(user_supplied$Group)
groupsxothers <- paste(groups, 'xOthers', sep = '')#doing cross group correlation
allgroups <- append(groups, groupsxothers, after = length(groups)) #append vector group with the x others vector
all_corr <- cbind(allgroups, all_corr$groups)
all_corr <- as.data.frame(all_corr)
names(all_corr)[names(all_corr) == 'allgroups'] <- 'groups'
#initialize stdev dataframe
stdev_species <- NULL
stdev_groups <- NULL
stdev_se <- NULL
stdev_counter <- 1
#

number_of_samples <- NROW(user_supplied)
###

if(NCOL(all_depth_cvs) > 2){
  all_depth_cvs <- all_depth_cvs[,-1] #remove position column
  intial_col <- NCOL(all_depth_cvs)

  while(NCOL(all_depth_cvs) > 0){
    current_cvs_samples <- all_depth_cvs[,1:number_of_samples]
    current_cvs_samples <- na.omit(current_cvs_samples) #deletesNA values caused by other refrences positions
    current_cvs_samples <- current_cvs_samples[, colSums(current_cvs_samples != 0) > 0] #remove columns containing only zeroes
    all_depth_cvs <- all_depth_cvs[,-(1:number_of_samples)]
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

          #find the name of the refrence
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

                #in this block the code will find the name of the refrence
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
        stdev_species[stdev_counter] <- name_full
        stdev_groups[stdev_counter] <- colnames(df)[i]
        stdev_se[stdev_counter] <- sd(df[[i]], na.rm = TRUE)
        stdev_counter <- stdev_counter+1
      }

      stdev <- data.frame(stdev_species, stdev_groups, stdev_se)

      pathtostoredf <- paste('corrbarplots/', name_full, '.csv', sep = '')
      write.csv(df, file = pathtostoredf, row.names = FALSE)

      #plot_title <- paste('corrbarplots/', name_full, 'corrbarplot.pdf', sep = '_') #path-specific
      plot_title <- paste(name_full, 'corrbarplot.pdf', sep = '_')
      pdf(plot_title, width = 15)

      boxplot(df, na.rm = TRUE, main = name_full,
              xlab = 'Correlation Value',
              ylab = 'Group Comparision made',
              boxwex = 0.8,
              horizontal = TRUE, #delete for vertical boxplots
              col = 'darkgoldenrod1', border = 'firebrick')

      dev.off()
    }else{
      cat('Correlation analysis and plot for one of the refrences couldnt be done because  there is only 1 sample with non-zero depth values for this reference .\n', file = 'R_all_correlation_errors.txt', append = TRUE)
      print('Correlation analysis and plot for one of the refrences couldnt be done because  there is only 1 sample with non-zero depth values for this reference')
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
  cat('Correlation analysis cannot be done with only one pair of reads or a single unpaired read or a single refrence with 1 pair of read or a single unpaired read. \n',  file = 'R_all_correlation_errors.txt', append = TRUE)
  print('Correlation analysis cannot be done with only one pair of reads or a single unpaired read.')
}

all_corr[is.na(all_corr)] <- 'No correlation coefficient calculated due to lack of enough samples'

all_corr <- all_corr[order(all_corr$groups),]
all_corr <- as.data.frame(all_corr)

write.csv(all_corr, 'full_correlation_analysis.csv',row.names = FALSE)

########## Plotting All References Graph ##########
#prepare separate data frames (between and within) that contain correlation and standar deviation for plotting
b_correlation <- NULL
b_group <- NULL
b_species <- NULL
b_se <- NULL
b_counter <- 1
w_correlation <- NULL
w_group <- NULL
w_species <- NULL
w_se <- NULL
w_counter <- 1

for(i in 2:length(colnames(all_corr))) {
  for (j in 1:length(rownames(all_corr))) {
    if(grepl("Others", levels(all_corr$groups)[j])) {
      b_correlation[b_counter] <- all_corr[j,i]
      b_group[b_counter] <- levels(all_corr$groups)[j]
      b_species[b_counter] <- colnames(all_corr[i])
      b_counter <- b_counter+1
    } else {
      w_correlation[w_counter] <- all_corr[j,i]
      w_group[w_counter] <- levels(all_corr$groups)[j]
      w_species[w_counter] <- colnames(all_corr[i])
      w_counter <- w_counter+1
    }
  }
}

between <- data.frame(b_species, b_group, b_correlation)
within <- data.frame(w_species, w_group, w_correlation)

colnames(stdev) <- c("Species", "Groups", "SE")
colnames(between) <- c("Species", "Groups", "Correlation")
colnames(within) <- c("Species", "Groups", "Correlation")

between <- merge(between, stdev)
within <- merge(within, stdev)
###

#aesthetics of plots
errorbars <- geom_errorbar(aes(ymin = Correlation-SE, ymax = Correlation+SE), width = .2, position = position_dodge(.9))
text <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
              plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6), axis.text=element_text(size=6)) #formats plot title


#plot shows only correlation within groups for all references (with error bars)
withinPlot <- ggplot(within, aes(x = Species, y = Correlation, fill = Groups))+
  geom_bar(stat = 'identity', position = 'dodge', width = 0.8)+ errorbars+ #error bar command
  scale_fill_brewer(palette="Pastel1")+
  theme_bw()+ text+ coord_flip()+
  ggtitle("Within Correlation for References")

#withinPlot #for testing

ggsave(as.character("corrbarplots/Within_corrbarplot.pdf"), withinPlot, width = 8, height = 8)
cat('file saved to',  "corrbarplots/Within_corrbarplot.pdf", '\n')

#plot shows only correlation between groups for all references (with error bars)
betweenPlot <- ggplot(between, aes(x = Species, y = Correlation, fill = Groups))+
  geom_bar(stat = 'identity', position = 'dodge', width = 0.8)+ errorbars+ #error bar command
  scale_fill_brewer(palette="Dark2")+
  theme_bw()+ text+ coord_flip()+
  ggtitle("Between Correlation for References")

#betweenPlot #for testing

ggsave(as.character("corrbarplots/Between_corrbarplot.pdf"), betweenPlot, width = 8, height = 8)
cat('file saved to',  "corrbarplots/Between_corrbarplot.pdf", '\n')

#plot shows combined correlation for both within and between groups but no error bars
correlationPlot <- ggplot(NULL, aes(x = Species, y = Correlation, fill = Groups))+
  geom_bar(data = within, aes(x = Species, y = Correlation, fill = Groups), stat = 'identity', position = 'dodge', width = 0.8)+
  geom_bar(data = between, aes(x = Species, y = Correlation, fill = Groups), stat = 'identity', position = 'dodge', width = 0.8)+
  scale_fill_brewer(palette="Spectral")+
  theme_bw()+ text+ coord_flip()+
  ggtitle("Correlation for References")

#correlationPlot #for testing

ggsave(as.character("corrbarplots/Full_corrbarplot.pdf", width = 8, height = 8), correlationPlot)
cat('file saved to',  "corrbarplots/Full_corrbarplot.pdf", '\n')

print('Full correlation analysis finished.')

