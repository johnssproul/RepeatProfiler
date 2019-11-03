library(ggplot2)

dir <- paste('/Volumes/Seagate/repeatprofiler/RP_test/normalization/')
setwd(dir)

species <- list.dirs(path = '.', full.names = FALSE, recursive = FALSE)

########## Prepare data ########## 
for (k in 1:length(species)) {
  if(grepl('dmel', species[k])){ #|| grepl('lividulum', species[k])) {
    dirs <- paste(dir, species[k], sep = '/')
    bp <- list.dirs(path = dirs, full.names = FALSE, recursive = FALSE)
    for (l in 1: length(bp)) {
      if(grepl('450', bp[l]) || grepl('900', bp[l])) {
        dirsbp <- paste(dirs, bp[l], sep = '/')
        print(dirsbp)
        
        Reads <- NULL
        Avg.Coverage <- NULL
        StDev <- NULL
        Reference <-NULL
        
        a.reads <- NULL
        a.coverage <- NULL
        a.reference <- NULL
        
        names <- list.dirs(path = dirsbp, full.names = FALSE, recursive = FALSE)
        k <- 0
        
        for (i in 1:length(names)) {
          names.read <- strsplit(names[i], '_')[[1]][2]
          Reads[i] <- as.numeric(strsplit(names.read, 'M')[[1]][1])
    
          path <- paste(dirsbp, names[i], 'The_summary_final.csv', sep = '/')
          df <- read.csv(path, header = TRUE, sep = ',')
          df <- na.omit(df)
          Avg.Coverage[i] <- mean(df$Average.coverage)
          StDev[i] <- sd(df$Average.coverage)
          Reference[i] <- paste(max(df$Ref.Length), 'bp', sep = '')
          
          for(j in 1:length(df$Average.coverage)) {
            a.reads[k] <- Reads[i]
            a.coverage[k] <- df$Average.coverage[j]
            a.reference[k] <- Reference[i]
            k <- k+1
          }
        }
        
        #if(grepl('450', dirsbp) && grepl('lividulum', dirsbp)) {
        #  liv450 <- data.frame(Reads = Reads, Avg.Coverage = Avg.Coverage, StDev = StDev, Length = Reference)
        #  a.liv450 <- data.frame(Reads = a.reads, Avg.Coverage = a.coverage, Length = a.reference)
        #} 
        
        if(grepl('450', dirsbp) && grepl('dmel', dirsbp)) {
          dmel450 <- data.frame(Reads = Reads, Avg.Coverage = Avg.Coverage, StDev = StDev, Length = Reference)
          a.dmel450 <- data.frame(Reads = a.reads, Avg.Coverage = a.coverage, Length = a.reference)
        } 
        
        #if(grepl('900', dirsbp) && grepl('lividulum', dirsbp)) {
        #  liv900 <- data.frame(Reads = Reads, Avg.Coverage = Avg.Coverage, StDev = StDev, Length = Reference)
        #  a.liv900 <- data.frame(Reads = a.reads, Avg.Coverage = a.coverage, Length = a.reference)
        #} 
        
        if(grepl('900', dirsbp) && grepl('dmel', dirsbp)) {
          dmel900 <- data.frame(Reads = Reads, Avg.Coverage = Avg.Coverage, StDev = StDev, Length = Reference)
          a.dmel900 <- data.frame(Reads = a.reads, Avg.Coverage = a.coverage, Length = a.reference)
        } 
      }
    }
  }
}

#Loess curve
a.dmel900 <- subset(a.dmel900, Reads < 12)
a.dmel450 <- subset(a.dmel450, Reads < 12)
a.dData <- rbind(a.dmel900, a.dmel450)

drosophilaCurve <- ggplot()+
  geom_point(data = a.dData, aes(x = Reads, y = Avg.Coverage, group = Length, colour = Length), size = 1)+
  geom_smooth(data = a.dmel900, aes(x = Reads, y = Avg.Coverage), method = 'loess', colour = 'black')+
  geom_smooth(data = a.dmel450, aes(x = Reads, y = Avg.Coverage), method = 'loess', colour = 'deepskyblue2')+
  
  scale_colour_manual(values = c('deepskyblue2', 'black'))+
  #scale_y_continuous(minor_breaks = seq(0, 26, by = 1), breaks = seq(0, 16, by = 2), limits = c(-0.5, 16), expand = c(0,0))+
  #scale_x_reverse()+
  
  theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                    panel.grid.major.y = element_line(colour = 'gray90'), panel.grid.minor.y = element_line(colour = 'gray95'))+
  labs(title = 'Drosophila', x = 'Reads (M)', y = 'Avg. Coverage')

drosophilaCurve
ggsave('/Volumes/Seagate/repeatprofiler/graphs/drosophilaCurve.pdf', drosophilaCurve, height = 5, width = 10)


#error bars
dmel900 <- subset(dmel900, Reads < 12)
dmel450 <- subset(dmel450, Reads < 12)
dData <- rbind(dmel900, dmel450)

drosophilaBars <- ggplot()+
  geom_line(data = dData, aes(x = Reads, y = Avg.Coverage, group = Length, colour = Length), size = 1)+
  geom_errorbar(data = dmel450, aes(x = Reads, ymin = Avg.Coverage-StDev, ymax = Avg.Coverage+StDev), width = 1, colour = 'black', size = 0.8)+
  geom_errorbar(data = dmel900, aes(x = Reads, ymin = Avg.Coverage-StDev, ymax = Avg.Coverage+StDev), width = 1, colour = 'deepskyblue2', size = 0.8)+
  
  scale_colour_manual(values = c('deepskyblue2', 'black'))+
  #scale_y_continuous(minor_breaks = seq(0, 26, by = 1), breaks = seq(0, 16, by = 2), limits = c(-0.5, 16), expand = c(0,0))+
  #scale_x_reverse()+
  
  theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                    panel.grid.major.y = element_line(colour = 'gray90'), panel.grid.minor.y = element_line(colour = 'gray95'))+
  labs(title = 'Drosophila', x = 'Reads (M)', y = 'Avg. Coverage')

drosophilaBars
ggsave('/Volumes/Seagate/repeatprofiler/graphs/drosophilaBars.pdf', drosophilaBars, height = 5, width = 10)

########## Bembidion Data ########## 
liv900 <- subset(liv900, Reads < 12)
liv450 <- subset(liv450, Reads < 12)

a.liv900 <- subset(a.liv900, Reads < 12)
a.liv450 <- subset(a.liv450, Reads < 12)

bData <- rbind(liv900, liv450)
a.bData <- rbind(a.liv900, a.liv450)

bembidion <- ggplot()+
  geom_line(data = bData, aes(x = Reads, y = Avg.Coverage, group = Length, colour = Length, linetype = Length), size = 1)+
  geom_errorbar(data = liv450, aes(x = Reads, ymin = Avg.Coverage-StDev, ymax = Avg.Coverage+StDev), width = 1, colour = 'firebrick2', size = 0.8)+
  geom_errorbar(data = liv900, aes(x = Reads, ymin = Avg.Coverage-StDev, ymax = Avg.Coverage+StDev), width = 1, colour = 'deepskyblue2', size = 0.8)+
  
  scale_colour_manual(values = c('deepskyblue2', 'firebrick2'))+
  
  scale_x_continuous(breaks = seq(0, 27, by = 5), limits = c(-0.5, 27), expand = c(0,0))+
  scale_y_continuous(minor_breaks = seq(0, 8, by = 1), breaks = seq(0, 8, by = 2), limits = c(-0.5, 8), expand = c(0,0))+
  theme_bw()+ theme(panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank(),
                    panel.grid.major.y = element_line(colour = 'gray90'), panel.grid.minor.y = element_line(colour = 'gray95'))+
  labs(title = 'Bembidion', x = 'Reads (M)', y = 'Avg. Coverage')

ggsave('bembidion.pdf', bembidion, height = 5, width = 10)
