#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library (ggplot2)

index_conv<-read.table("Index_conv.txt",header = TRUE,stringsAsFactors=FALSE)


multmerge = function(mypath){
  filenames=list.files(path=mypath, full.names=TRUE)
  datalist = lapply(filenames, function(x){read.csv(file=x,header=T)})
  Reduce(function(x,y) {merge(x,y,all = TRUE)}, datalist)
}

The_path=getwd()
all_depth_cvs = multmerge("temp_cvs")

vector_of_averages<- c()
refrencce_length<-NROW(all_depth_cvs)


name<-args[1]
name_first<-strsplit(name,"_")
name_first<-name_first[[1]]
name_first<-as.numeric(name_first[length(name_first)])


Read1_first=index_conv[name_first,1]
Read2_first=index_conv[name_first,2]

if(Read1_first!=Read2_first){
  
  Title=paste(args[1],"                 ","Read1:",Read1_first,"    Read2:",Read2_first,sep = "")
}else if(Read1_first==Read2_first){
  
  Title=paste(args[1],"                 ","Read:",Read1_first)
  
  
}




for (i in 2:NCOL(all_depth_cvs)) {
 v<-as.vector(all_depth_cvs[,i])
 
 sum_coverage<-sum(as.numeric(v), na.rm = TRUE)
 
 
 vector_of_averages[i-1]<-sum_coverage/refrencce_length
 
  
  
}
  
data<- summary(vector_of_averages)


The_midpoint=as.numeric(data[5])




Depth_column=make.names(args[1])


#Df1<-read.table("pileup_counted.txt",header=TRUE,fill = TRUE)
#args[1]="TIRANT_I_LTR_Gypsy.fa_1"
Df2<-subset(all_depth_cvs,select = c("Position",Depth_column))

colnames(Df2)[2] <- "Depth"



###################### Plot1 is working below ##########################


print('Plot1')

#for (i in 2:ncol(db.new2)){
# print(sp.names2[i])

#png(filename = "DepthPlot1.png", width=2200, height=300)

Plot1<-ggplot(data=Df2, aes(x=Position, y=Depth))+
  geom_bar(aes(color=Depth, fill=Depth), alpha = 1, stat="identity")+
  
  #This uses the midpoint of the data to exstablish the reference point for the gradient.
  scale_color_gradient2(low = "blue", mid = "green", high = "red",
                        midpoint = The_midpoint/2)+
  scale_fill_gradient2(low = "blue", mid = "green", high = "red",
                       midpoint = The_midpoint/2)+
  #midpoint = max(Df2[2])/2)+
  #to remove gray background
  theme_bw()+
  #To remove gridlines:
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + ggtitle(Title)

###########
#This is a cool way to make the color gradient way prettier, but it may not let us specify a midpoint that puts all plots on the same scale. Need to check.
#Plot1+scale_color_gradientn(colours = c("blue", "green3", "yellow", "orange", "red")) #rainbow(5))
###########

print(Plot1)
#dev.off()

Plot1name=paste(as.character(args[1]),"/X1.png",sep="")

ggsave(as.character(Plot1name), Plot1, units = "mm", width = 175, height = 50)

Plot1

#}


############################## Good above ############################

#defines a function for vals needed by Plot2
vals.fun<-function(y){
  seq(0, y, by=20)
}


################### Plot2 code (vert color ramp) #######################

print('Plot2')


vals <- lapply(Df2[[2]], vals.fun) ##the syntax 'Df2[[i]]' took forever to get right. I kept trying to do things like db.new2$[i] but you don't use square bracketws with a dollar sign.
vals
y <- unlist(vals)
mid <- rep(Df2$Position, lengths(vals))
d2 <- data.frame(x = mid - 0.4,
                 xend = mid + 0.4,
                 y = y,
                 yend = y)

# print(d2)

#Writes a png file named by the species name associated with each iteration of the loop
#png(filename = "DepthPlot2.png", width=2200, height=300)


#Uses d2 generated above to plot a vertical gradient profile
Plot2<-ggplot(data = d2, aes(x = x, xend = xend, y = y, yend = yend, color = y)) +
  geom_segment(size = 2) +
  scale_color_gradient2(low = "blue", mid = "green", high = "red", 
                        #midpoint = 5000)+
                        #to calculate midpoint from current data vector
                        midpoint = The_midpoint/2)+
  #midpoint = max(db.new2)/2)+
  scale_fill_gradient2(low = "blue", mid = "green", high = "red",
                       #midpoint = 5000)+
                       #to calculate midpoint from current data vector
                       midpoint = The_midpoint/2)+
  
  #midpoint = max(db.new2)/2)+
  
  #to calculate midpoint relative to whole data set
  # midpoint = max(d2)/2)
  
  theme_bw()+
  #To remove gridlines:
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ ggtitle(Title)

print(Plot2)
#dev.off()
Plot2
#}

Plot2name=paste(as.character(args[1]),"/X2.png",sep="")


ggsave(as.character(Plot2name), Plot2, units = "mm", width = 175, height = 50)

###  ### I tried to make plot 3 smoother by extending the window to 25. The window size should really be calculated individually for each reference based on the total length of the reference in order to keep graphics consistent looking
############################## Prep for plot 3 same as beginning of the script, but it makes larger bins of data to make for smoother lines on pdf###############################


#defines fun.split function that partitions the data into bins of size 10. Bin size can be increased or decreased based on reference length
Df3<-Df2[2]
fun.split.100<- function(x) {
  split(x, ceiling(seq_along(x)/25))
}

#use lapply to loop through each vector in Df2 and execute the function 
#fun.split. This will split each vector into bins with the specified value in each #bin.

Df4<-lapply(Df3, fun.split.100)
print(Df4)

#This next bit loops through the bins in Df2.out and returns a mean for each #bin

#makes an object that consists of the names in Df2.out, which are the species names
sp.names3 <- names(Df4)

#makes an empty list the same length as sp.names, not sure what rep means
mean.list2 <- as.list(rep(NA, length(sp.names3)))

#Sets names in mean.list to same as those in Df2.out
names(mean.list2) <- names(Df4)

#fills mean.list with info from Df2.out (I think)

for (i in 1:length(Df4)) {
  mean.list2[[i]] <- sapply(Df4[[i]],mean)
}

#Convert mean.list to a dataframe:
db<-as.data.frame(mean.list2, row.names=NULL)
db
#
###This works around the fact that the above three lines of code make a data frame that breaks the plot.
#By writing to a file and re-reading, it fixes the issue...need to find a more elegant solution.
#write.csv(db.new, file="db.new.csv")

write.csv(db, file="db.2.csv")
db.2<-read.csv("db.2.csv", header=TRUE)

#Renames new column to be "x"
names(db.2)[1]<-paste("Position")


###################### Plot 3 is below ##########################

# sp.names2<-names(db.new5)
print('Plot3')


# for (i in 2:ncol(db.new5)){
#   print(sp.names2[i])

#pdf uses file = instead of the png convention filename =
#pdf(file ="DepthPlot3.pdf", width=900, height=300)

Plot3<-ggplot(data=db.2, aes(x=Position, y=Depth))+
  #geom_line(aes(color=sp1), alpha = 1/2, stat="identity")+
  geom_area(fill="royalblue3")+
  #to remove gray background
  theme_bw()+
  #To remove gridlines:
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + ggtitle(Title)

#This uses the midpoint of the data to exstablish the reference point for the gradient.
#scale_color_gradient2(low = "blue", mid = "green", high = "red",
#midpoint = max(db.new2$sp1)/2)
#could have done
#midpoint = 5000)

print(Plot3)
#dev.off()
Plot3

Plot3name=paste(as.character(args[1]),"/X3.png",sep="")

ggsave(as.character(Plot3name), Plot3, units = "mm", width = 175, height = 50)

#}

########################## good above ################################
