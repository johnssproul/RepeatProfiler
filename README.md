# Repeat Profiler 

A tool for generating, visualizing, and comparing repetitive DNA profiles. This tool helps to generate solid comparitive DNA profiles based on just short sample reads  and repeat reference  sequences.


# Features:

 - Facilitates data visualization of repeat profiles using short read data
  - Produces publication quality graphs in R that simplify visual comparison of profiles. 
  - Outputs a table with summary statistics
  - Conducts correlation analysis of profiles shape across specified groups
  - Enables phylogenetic analysis using variation  present in profiles and generate phylip files



### Installation
The easiest way to setup repeat profiler with all of its dependencies is through [Homebrew]. If you dont have homebrew yet, install it via on  [linux/WSL] and on [macOS]

After install homebrew succesfully, run this command:
```
brew install HounerX/homebrew-repo/repeatprof
```

To test installation was succesful, try calling the program using...

```sh
repeatprof
```

### Alternative Installation
If you dont like homebrew you can download [.zip] of the latest program version 

Make sure you have the  correct dependencies  if you are going with Alternative Installation:
 - bowtie2
 - samtools
 - python2
 - R
 - R packages: ggplot2,ggpubr,scales,reshape2
you can install requeired R packages by running this command  
```sh
echo "install.packages(c('ggplot2','ggpubr','scales','reshape2'), repos=\"https://cran.rstudio.com\")" | R --no-save
```
After that you go to this directory in the terminal and run check it is working using  

```shbash 
bash repeatprof 
```


# Getting started:


##### Generating a  profile:

To generate a profile you need refrence sequence/sequences in fasta format  for and  paired or unpaired short sequence reads  

a sample command 

```sh
repeatprof profile <-p for paired reads or  -u for unpaired> <the refrence sequence path > <path of the folder containing reads> [opitonal flags] 
```

the refrence sequence needs to be in fasta format with any extention of .fa/.fasta/.txt

The reads need to be in a folder and you u need to provide the path of the folder and The tool will detect any read of formats supported:
Paired reads: _R1.fastq _R1.fastq.gz _R1.fq  _R1.fq.gz  _1.fastq _1.fastq.gz _1.fq  _1.fq.gz <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _R2.fastq _R2.fastq.gz _R2.fq  _R2.fq.gz  _2.fastq _2.fastq.gz _2.fq  _2.fq.gz <br>
Unpaired reads:  .fastq &nbsp;  .fastq.gz &nbsp;.fq &nbsp;  .fq.gz&nbsp;  .fastq.gz  &nbsp;  .fq

review the sample input data set provided [here]. Also make sure all your files has Unix LF which means an empty line at the end of the file. This is standard among all linux and macOS text files

Also you can treat paired reads as unpaired by using the flag -u instead of -p. In case, if thats what you want. It will just look for the extention instead of _1/ _2/_R1/_R2 and the extention 

###### Opitonal flags: 
&nbsp;&nbsp;&nbsp;&nbsp;Optional flags can be used in any order after the madantory flags lisited above.

`-o <folder_path>` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   This will direct the final output folder  to the specified  folderr. Default: Current directory

`-corr`  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   type this flag to make the correlation analysis. user_provided.txt is needed for the &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  correlation graph. 

`-usrprov <path of user_provided.txt>`  use this to provide path of user_provided.txt explained above. Default is current directory. look  below on how to prepare the user_provided.txt and what it is. 

Type one of these 9 alignment settings for bowtie2. Default is `--very-sensitive` <br>
`--very-fast` <br>
`--local`<br>
`--fast`<br>
`--very-fast-local`<br>
`--fast-local`   <br>
`--sensitive` <br>
`--very-sensitive`<br>
`--very-sensitive-local`  
`--sensitive-local`<br>

`-k`  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    use this flag if you want to keep the sorted bam files of the alignments in the final output folder

 
 
##### Note: Dont include the <> when typing paths . It is just for illustration here. Also make sure all paths passed into the command have no blank. In addition, Default is  current directory means that if you didnt enter this flag it will just assume you have the input in the current directory 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
##### Prepearing user_provided.txt for -corr 
Lets say you want to make a profiles for reads you prepeared and want them to include correlation graphs which shows how similiar/different   reads mapping depth are, but also some of these reads belong to a group (A) for example and other (B), so first 
run this command:
```sh
repeatprof pre-corr < -u for unpaired reads  or -p paired reads  > <path reads folder>
```

after running this command a  user_provided.txt will be generated based on your reads and all you have to do is to replace the placeholder 'temporary' with your own groups then run this command to verfiy that it is in the correct format and view the file
```sh
repeatprof pre-corr -v   
```
you need to have your edited user_provided.txt in the same directory you are running this command in.

##### Now you are all set for generating profiles with nice looking correlation groups graph and using the tool  . GOOD JOB !
&nbsp;
&nbsp;
In case you terminated the run, you can use this command to clean up intermidate files created by the tool if you want 
```sh
repeatprof clean   
```
# Understanding the output---In-depth Tutorial 




[//]: # 
   [.zip]: <https://github.com/johnssproul/RepeatProfiler/releases/download/0.9/RepeatProfiler-v0.9-source.zip>
   [here]: <https://github.com/johnssproul/RepeatProfiler/releases/download/0.9/sample_input.zip>
   [Homebrew]: <https://brew.sh/>
   [linux/WSL]: <https://docs.brew.sh/Homebrew-on-Linux>
   [macOS]: <https://brew.sh/>
   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
