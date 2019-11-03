library(ggplot2, stringr)
library(gridExtra)

setwd('/Volumes/Seagate/repeatprofiler/RP_test/normalization/')

data <- read.csv('/Volumes/Seagate/repeatprofiler/RP_test/graphs/all_graphs.csv', header = TRUE, sep = ',')
data$Reference <- factor(data$Reference, 
                         levels = c('Ancestral.fa', 'derived_200.fa', 'derived_400.fa', 'derived_600.fa', 'derived_800.fa', 'derived_1000.fa',
                                    'derived_1200.fa', 'derived_1400.fa', 'derived_1600.fa', 'derived_1800.fa', 'derived_2000.fa'))


####### All Reads #######
all <- ggplot(data = data, aes(x = Pairwise.Id, y = Mapped))+
  geom_point(size = 0.9)+
  geom_line(aes(x = Pairwise.Id, y = 0), linetype = 'dotted')+
  geom_smooth(method = 'loess', colour = 'deepskyblue2')+
  scale_x_reverse()+
  theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                    panel.grid.major.y = element_line(colour = 'gray90'), panel.grid.minor.y = element_line(colour = 'gray95'))+
  ylab('Relative Percent Mapped')+ xlab('Pairwise Sequence Identity')+ ggtitle('Sequece Divergence')

all


ggsave('ETSand28SS.pdf', all, width = 5, height = 4)


####### Facet - 2 Axis ####### 
plot2axisF <- ggplot(data = data, aes(x = Reference))+
  geom_line(aes(y = Pairwise.Id), group = 1, colour = 'blue')+
  geom_line(aes(y = Perc..Mapped*100), group = 1, colour = 'orange')+
  scale_y_continuous(name = 'Pairwise Identity',
                     sec.axis = sec_axis(~./100, name = 'Percent Mapped', 
                                         labels = function(b){
                                           paste0(round(b*100, 0), '%')
                                         }))+
  facet_grid(Read ~ Type)+
  theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(axis.text.x = element_text(angle = 90, hjust = 1), axis.title = element_blank())

plot2axisF
ggsave('plot2axisF.pdf', plot2axisF)


####### Facet - 1 Axis #######
graph1axis <- function(d, name) {
  pairwise.id <- ggplot(data = d, aes(x = Reference))+
    geom_line(aes(y = Pairwise.Id), group = 1, colour = 'blue')+
    theme_bw()+ theme(axis.text.x = element_blank(), axis.title = element_blank(),
                      panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    ggtitle('Pairwise Identity')
  
  percent <- ggplot(data = d, aes(x = Reference))+
    geom_line(aes(y = Perc..Mapped), group = 1, colour = 'orange')+
    theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    theme(axis.text.x = element_text(angle = 90, hjust = 1), axis.title = element_blank())+
    ggtitle('Percent Mapped')
  
  plot1axis <- grid.arrange(pairwise.id, percent, ncol = 1, nrow = 2, heights = c(1,1.5), top = name)
}

plot1axis <- function(d, t, name) {
  df <- subset(data, Read == d)
  df <- subset(df, Type == t)
  graph1axis(df, name)
}

ggsave('dsim_ETS.pdf', plot1axis('dsim', 'ETS', 'dsim_ETS'))
ggsave('dsim_28S.pdf', plot1axis('dsim', '28S', 'dsim_28S'))

ggsave('dsech_ETS.pdf', plot1axis('dsech', 'ETS', 'dsech_ETS'))
ggsave('dsech_28S.pdf', plot1axis('dsech', '28S', 'dsech_28S'))

ggsave('dmel_ETS.pdf', plot1axis('dmel', 'ETS', 'dmel_ETS'))
ggsave('dmel_28S.pdf', plot1axis('dmel', '28S', 'dmel_28S'))

ggsave('dmau_ETS.pdf', plot1axis('dmau', 'ETS', 'dmau_ETS'))
ggsave('dmau_28S.pdf', plot1axis('dmau', '28S', 'dmau_28S'))

