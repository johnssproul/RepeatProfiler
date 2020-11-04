library(ggplot2)
library(grid)
library(gtable)
setwd("C:\\Users\\durbe\\Documents\\Repos\\RepeatProfiler\\scripts")
df1 <- read.table("./depth_counts.txt", header=T)

max <- max(df1$Depth)

gff <- data.frame(annot=rep(c("label1", "label2")),
                  start=c(100, 300),
                  end=c(210, 420))

tf <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #to remove gridlines
            plot.title = element_text(size = 6, face = 'bold'), axis.title = element_text(size = 6)) #formats plot title
tl <- theme(legend.text = element_text(size = 6)) #formats legend

#### COLOR PALETTES
colors <- c('blue4', 'springgreen2', 'yellow', 'orange', 'red', 'red')

# colors <- c('#440154FF', '#3B528BFF', '#21908CFF', '#5DC863FF', '#FDE725FF', '#FDE725FF') #sets color scheme for gradient
# colors <- c('#1965B0', '#4EB265', '#F7F056', '#F1932D', '#DC050C', '#DC050C') 
# colors <- c('#4477AA', '#66CCEE', '#228833', '#CCBB44', '#EE6677', '#EE6677') 

cs <- scale_fill_gradientn(name = "Depth", values = c(0, .20, .40, .60, .80, 1.0), colours = colors, limits = c(0, max), guide = 'colourbar', aesthetics = 'fill') #sets color gradient environment for gradient plots (horizontal and vertical)


horizontalPlot <- ggplot(data = df1, aes(x = Position, y = Depth))+
  geom_bar(aes(fill = Depth), alpha = 1, stat = 'identity', width = 1.0)+
  cs+ theme_bw()+ #to remove grey background
  tf+ ggtitle("Bright: Color-Blind") +labs(y="Depth") #sets plot title

horizontalPlot


## ANNOTATIONS
annotPlot <- horizontalPlot+ 
  annotate("text", x = gff$start+0.5*(gff$end-gff$start), y = -100, label = gff$annot, size=2)+
  annotate("rect", xmin=gff$start, xmax=gff$end, ymin=-400, ymax=0, alpha=.2)
