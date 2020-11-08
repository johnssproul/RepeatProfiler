library(ggplot2)
library(grid)
library(gtable)
setwd("C:\\Users\\durbe\\Documents\\Repos\\RepeatProfiler\\scripts")
df1 <- read.table("./depth_counts1.txt", header=T)

max <- max(df1$Depth)

gff <- data.frame(annot=rep(c("label1", "label2")),
                  start=c(100, 300),
                  end=c(210, 420))

tf <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
            plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6)) #formats plot title
tl <- theme(legend.text = element_text(size = 6)) #formats legend

#### COLOR PALETTES
# first and second
# colors <- c('blue4', 'springgreen2', 'yellow', 'orange', 'red', 'red')
colors <- c('#440154FF', '#3B528BFF', '#21908CFF', '#5DC863FF', '#FDE725FF', '#FDE725FF') #viridis

# qualitative
# colors <- c('#4477AA', '#66CCEE', '#228833', '#CCBB44', '#EE6677', '#EE6677') #bright v1
# colors <- c('#4477AA', '#228833', '#CCBB44', '#EE6677', '#AA3377', '#AA3377') #bright v2
# 
# colors <- c('#0077BB', '#33BBEE', '#009988', '#EE7733', '#CC3311', '#CC3311') #vibrant v1
# colors <- c('#0077BB', '#009988', '#EE7733', '#CC3311', '#EE3377', '#EE3377') #vibrant v2
# 
# colors <- c('#332288', '#117733', '#999933', '#DDCC77', '#CC6677', '#CC6677') #muted
# 
# colors <- c('#BBCCEE', '#CCEEFF', '#CCDDAA', '#EEEEBB', '#FFCCCC', '#FFCCCC') #pale
# 
# colors <- c('#222255', '#225555', '#225522', '#666633', '#663333', '#663333') #dark
# 
# colors <- c('#77AADD', '#44DDFF', '#BBCC33', '#EEDD88', '#EE8866', '#EE8866') #light v1
# colors <- c('#77AADD', '#44DDFF', '#BBCC33', '#EEDD88', '#FFAABB', '#FFAABB') #light v2
# 
# #diverging
# colors <- c('#364B9A', '#98CAE1', '#EAECCC', '#FEDA8B', '#DD3D2D', '#DD3D2D') #sunset
# 
# colors <- c('#762A83', '#C2A5CF', '#F7F7F7', '#ACD39E', '#187837', '#187837') #PRGn
# 
# #sequential
# colors <- c('#662506', '#CC4C02', '#EC7014', '#FB9A29', '#FEE391', '#FEE391') #YlOrBr
# 
# colors <- c('#1965B0', '#4EB265', '#F7F056', '#F1932D', '#DC050C', '#DC050C') #rainbow v1
# colors <- c('#882E72', '#1965B0', '#F7F056', '#F1932D', '#DC050C', '#DC050C') #rainbow v2
# 
# colors <- c('#46353A', '#805770', '#9A709E', '#9B8AC4', '#88A5DD', '#88A5DD') #iridescent v1
# colors <- c('#46353A', '#9B8AC4', '#7BBCE7', '#C2E3D2', '#F5F3C1', '#F5F3C1') #iridescent v2
# 
# #alternative
# colors <- c('purple4', 'blue2', 'springgreen2', 'yellow', 'orange', 'orange')
# colors <- c('blue2', 'purple4', 'yellow', 'orange', 'red', 'red')

cs <- scale_fill_gradientn(name = "Depth", values = c(0, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = 'fill') #sets color gradient environment for gradient plots (horizontal and vertical)

#rainbow - choppy
colors <- c('#6f4c9b', '#4e79c5', '#16be54', '#ddaa3c', '#e67932', '#da2222', '#da2222')
cs <- scale_fill_gradientn(name = "Depth", values = c(0, .10, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = 'fill') #sets color gradient environment for gradient plots (horizontal and vertical)

#rainbow - smooth
colors <- c('#6f4c9b', '#6059a9', '#5568b8', '#4e79c5', '#4d8ac6', 
            '#4e96bc', '#549eb3', '#59a5a9', '#60ab9e', '#69b190',
            '#77b77d', '#8cbc68', '#bebc48', '#d1b541', '#ddaa3c',
            '#e49c39', '#e78c35', '#e67932', '#e4632d', '#df4828', 
            '#da2222', '#da2222')
cs <- scale_fill_gradientn(name = "Depth", values = c(0, .03, .06, .10, .11, 
                                                      .12, .13, .15, .17, .19, 
                                                      .22, .27, .30, .33, .40, 
                                                      .47, .53, .60, .67, .73, 
                                                      .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = 'fill') #sets color gradient environment for gradient plots (horizontal and vertical)

#plot
horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
  geom_bar(aes(fill = Depth), alpha = 1, stat = 'identity', width = 1.0)+
  cs+ theme_bw()+ #to remove grey background
  tf+ ggtitle("Original - removed Green") +labs(y="Depth") #sets plot title


horizontalPlot

# VARIANT PLOTS
base.counts <- read.table('depth_counts.txt', header = TRUE)
head(base.counts[1])

#creates new dataframe based on base.counts, but not including depth column
base.countsRed <- base.counts[1:6]
head(base.countsRed)

#makes a stacked bar chart based on: https://stackoverflow.com/questions/21236229/stacked-bar-chart
#melt takes data with the same position and stacks it as a set of columns into a single column of data
base.countsRed.m <- reshape2::melt(base.countsRed, id.vars = 'Position')
head(base.countsRed.m)
colnames(base.countsRed.m)[2] <- 'Bases'
colnames(base.countsRed.m)[3] <- 'Depth'

length(base.countsRed.m$Bases)
polymorphPlot <- ggplot(base.countsRed.m, aes(x = Position, y = Depth))+
  geom_bar(aes(fill = Bases, alpha = Bases), stat = 'identity', width = 1.0)+
  scale_fill_manual(values = c('grey65', 'red', 'blue', 'yellow', 'green'))+
  scale_alpha_manual(values = c(0.35, 1.0, 1.0, 1.0, 1.0))+
  theme_bw()+ #to remove grey background
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6))+
  theme(legend.text = element_text(size = 6))+ #formats legend
  ggtitle("Original")

polymorphPlot


## ANNOTATIONS
annotPlot <- horizontalPlot+ 
  annotate("text", x = gff$start+0.5*(gff$end-gff$start), y = -100, label = gff$annot, size=2)+
  annotate("rect", xmin=gff$start, xmax=gff$end, ymin=-400, ymax=0, alpha=.2)
