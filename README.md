
# Repeat Profiler (This README is in the early draft stages of construction)

A tool for generating, visualizing, and comparative analysis of repetitive DNA profiles from short-read data. This tool automates the generation of repetitive DNA profiles from short-read sequence data and one or more reference sequences. Output enables standardized visualization of profiles, and comparative analysis of profile shape within and among user-defined groups, and prepares input files for phylogenetic analysis signal arising from variants within repeat profiles. RepeatProfiler is developed specifically to facilitate study of repetitive DNA dynamics over short evolutionary time scales in groups lacking genomic resources; however, it may be useful in any application where extracting signal from repetitive sequences is needed.


# Features:

  - Facilitates data visualization of repeat profiles using short read data
  - Produces publication quality graphs in R that simplify visual comparison of profiles. 
  - Provides summary statistics related to repeat abundance, etc.
  - Conducts comparative analysis of profiles shape across and within user specified groups
  - Enables comparative study of variation within repeats through phylogenetic analysis


### Installation

#### Homebrew
The easiest way to setup RepeatProfiler with all of its dependencies is through the package manager [Homebrew]. If you don’t have homebrew, it is available for installation on [linux/WSL] and on [macOS].

After homebrew is installed, run this command:
```
brew install HounerX/homebrew-repo/repeatprof
```

To test if the installation was successful, try calling the program at the command line using:

```sh
repeatprof
```

#### Docker
If Docker software is installed, pull the Docker image contanining RepeatProfiler run the command:

```
docker pull durberg7/repeatprof
```

To test if the installation was successful, try calling the program at the command line using:

```sh
docker exec <container ID> ./repeatprof
```

For more information about how to use RepeatProfiler with Docker see the [repeatprof repository] on Docker hub.

#### Manual Installation
As an alternative to homebrew you can download [.zip] of the latest program version and install the dependencies separately. 
Required dependencies are:
 - bowtie2
 - samtools
 - python2
 - R
 - R packages: ggplot2, ggpubr, scales, reshape2
you can install required R packages by running this command:  
```sh
echo "install.packages(c('ggplot2','ggpubr','scales','reshape2'), repos=\"https://cran.rstudio.com\")" | R --no-save
```
After dependencies are installed, move to the unzipped directory containing the program in the terminal and run the following command to check that the program is working. The words “REPEAT PROFILER” should print to the screen.  

```sh 
bash repeatprof 
```

# Getting started


##### Required Input

To generate profiles, you need two input types: (1) one or more reference sequence, and (2) short-read sequence data from one or more samples.

1. Reference sequences
- One or more reference sequence of repeats in FASTA format (LINK example)
- For tips on obtaining reference sequences for groups that lack repeat reference libraries see “TBD section” below (or LINK to full tutorial)

2. Sequence data
- Read files should be in FASTQ format.
- Files should end in the ‘.fastq’, or compressed ‘.fastq.gz’ extension (‘.fq’ instead of ‘.fastq’  is also supported).
- Input reads may be paired, or unpaired. If paired data are used, the last string before the file extension should be ‘_1’ for Read1 and ‘_2’ for Read2 (alternatively ‘_R1’ and ‘_R2’ may be used). An example of an acceptable name for the file name for the file containing Read1 reads would be: ‘SampleName_1.fastq.gz’. The file containing Read2 data should replace the ‘_1’ with ‘_2’, but be identical otherwise as in: ‘SampleName_2.fastq.gz’
-A full list of supported input final strings and extensions is shown in the table below:

|  Input |format   | format  | format  |format   | format  | format  | format|
|---|---|---|---|---|---|---|---|
| Paired Reads   | _R1.fastq | _R1.fastq.gz | _R1.fq | _1.fastq | _1.fastq.gz | _1.fq | _1.fq.gz |   
|                | _R2.fastq | _R2.fastq.gz | _R2.fq | _2.fastq | _2.fastq.gz | _2.fq | _2.fq.gz |   
| Unpaired Reads | .fq.gz    | .fastq.gz    | .fq    | .fastq   | .fastq      | .fq   | .fq.gz   |   
| Reference      | .fa       | .fasta       | .txt   |          |             |       |          |                



Review the sample input data set provided [here]. Also make sure all your files has Unix LF which means an empty line at the end of the file. This is standard among all linux and macOS text files


##### Generating profiles:

a sample profile command with mandatory flags explained 
```sh
repeatprof profile <-p for paired reads or -u for unpaired> <the reference sequence path > <path of the folder containing reads> [optional flags] 
```

an example of a functional example command (explanations omitted).

```sh
repeatprof profile -p Refs.fa /RepeatProfilerData/Test1
```

Explanation: 
- 'repeatprof' calls the program
- 'profile' the command that directs program to generate profiles (see other command options below) 
- '-p' indicates the input reads are paired 
- 'Refs.fa' specifies the FASTA files containing reference sequences (located in the current directory in this example, alternatively a path can be provided) 
– '/RepeatProfilerData/Test1' gives the path of the directory containing input read files


###### Optional flags: 
| optional flag                        | usage                                                                                                                                                           |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -o <folder_path>                     | This will direct the final output folder to the specified folder. Default: Current directory                                                                 |
| -corr                                | this flag to make the correlation analysis. user_provided.txt is needed for the  correlation graph                                                              |
| -usrprov <user_provided.txt path> | use this to provide path of user_provided.txt explained above. Default is current directory. look  below on how to prepare the user_provided.txt and what it is |
| --very-sensitive                     | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --very-fast                          | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --local                              | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --fast                               | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --very-fast-local                    | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --fast-local                         | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --sensitive                          | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --very-sensitive                     | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --very-sensitive-local               | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| --sensitive-local                    | bowtie alignment setting. Default:--very-sensitive                                                                                                              |
| -k                                   | use this flag if you want to keep the sorted bam files of the alignments in the final output folder                                                             |


 
##### Note: Don't include the <> when typing paths . It is just for illustration here. Also make sure all paths passed into the command have no blank. In addition, Default is  current directory means that if you didn't enter this flag it will just assume you have the input in the current directory 


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
##### Preparing user_provided.txt for -corr 
Lets say you want to make a profiles for reads you prepared and want them to include correlation graphs which shows how similar/different   reads mapping depth are, but also some of these reads belong to a group (A) for example and other (B), so first 
run this command:
```sh
repeatprof pre-corr < -u for unpaired reads  or -p paired reads  > <path reads folder>
```

after running this command a  user_provided.txt will be generated based on your reads and all you have to do is to replace the placeholder 'temporary' with your own groups then run this command to verify that it is in the correct format and view the file
```sh
repeatprof pre-corr -v   
```
you need to have your edited user_provided.txt in the same directory you are running this command in.

##### Now you are all set for generating profiles with nice looking correlation groups graph and using the tool  . GOOD JOB !
&nbsp;
&nbsp;
In case you terminated the run, you can use this command to clean up intermediate files created by the tool if you want 
```sh
repeatprof clean   
```
# Understanding the output---In-depth Tutorial 
In this section, I will walk you through a sample output/outputs generated by the sample input data [here]. We will cover:

**What is in the output folder section**
- what each file means
 - How are the graphs generated and scaled
 - How is the phylip file generated

**How to get the most out of the tool**

 - How to find good repeat reference sequence if you don’t have any based on your reads
 
 - How to use the phylip formatted file correctly and get the most out of the trees you generate. 
 
 - How to get the most out of the tool and your data 








## What is in the output folder
After running your data or sample data linked above, you will find this 
folder in your current directory  or the directory you specified:

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo_of_the_folder.PNG)

The time  refers to the  time you started the run. Opening, the folder you will find this 

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo2.PNG)

Here you can see your refrence name folder _outputn which contain all the analysis for this refrence We will get to that soon. This is done incase you run the analysis with multi-fasta sequence file. We also keep your refrences in single fasta files in Refrences_used folder. 


Next thing you will find is ReadMe file.It will look something like this 
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo1.PNG)

This read me tell you what indexes that you will see later when we go to the the specific refrences _output file means.  In short, we refer to your reads paired or unpaired in an index. This makes it easier to name the files and manage output. Dont worry we convert it back to your read name when analyzing graphs and summary tables. This is just for the folders.  

One of the important outputs is the summary_final.csv table. It contains very useful info about the refrence length you used, average coverage for reads, percent coverage, etc. It look like this and as you notice we have the reads for you allowing  easy scanning  of the table.

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo10.PNG)

As you can tell, each row represt the refrence and the read used, so if you had for example 4 pairs of reads/4 unpaired reads, you will have 4 rows with the same refrence name and each row will contain the corrsoponding attributes shown 


Before going into the refrence_wide_color_scaled_graphs, lets go into a refrence _output folder and explain it then we will come back to this. It makes more sense this way. 

Now the real features of the tool will show. Prepare haha!

Lets say we will go the first folder which is refrence named CL3_TR_1_x_53_0nt

You will find  the folder look like this 

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo3.PNG)

First thing you will notice is these sub folders. Each subfolder belong to the read/readpair this refrence sequence was run against. The indexes which we talked about earlier. We will go into the subfolders later.

Now, next thing you will notice  is combined_horizontal_colored.pdf file. It look something like this and it contains graphs as many as your read/readpairs. Now i will explain what does this graphs mean.

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/phtoto6.PNG)


Each of these graph represent the coverage of the read/read pair when mapped to that  specfic refrence we opened its folder.  They are all based on a single color scale. That means by just quick looking at the graph you can tell which parts of the refrence sequence (refrence sequence base position is on x axis ) has the highest (red)/lowest(blue)  coverage. This  can tell you a lot about this read and refrence sequence. How/where this sequence enriched in that species reads compared to the other species reads. Color scaling accross different reads will help you in a great way to vizualize differences  among very large group of data.


Next pdf in the _output folder is the combined_variation plots.pdf
These plots has the variation(polymorphisim) in  among all the reads for this specific refrences. They have been put together for your convience to compare. 


![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo7.PNG)


For example in this example you can see that sample 001 and 002 which are same species share huge common polymorphric base A  at the some postion this is shown by huge Red bar. 

There are a a lot of more info in this plot than to just compare them by eye, so we will later explain the phylip file that we generate later, but before that  lets get back to the individual sample sub folders 


Opening one of the sub folders  folders will look like this
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo5.PNG)

it contain  the same plots we looked at earlier but indvidully. Keep in mind they are still scaled among all reads, so its main use is if you are interested in a specific graph you can simply its subfolder an get it. Also there is a solid colored version(not scaled) and a vertical colored scaled which is an alternative way to look at it, but most importantly you have the horizontal color scaled that you saw earlier and a text file that contains the information per every position in the refrence sequence. It contains the depth of every postion/mismatches of A/mismatches of T/mismatches of C//mismatches of G/. 





Now  lets go back and check what is in the Phylip file and what does it mean  

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo8.PNG)


Based on the variation plots explained earlier, we were able to capture phylogentic informative sites from these plots. We analysed each plot indivudaly and recored the bases that had high mis match coverage over 10% from the actual coverage. We also accounted for ambigous sites.

 This phylip files are most informative for long refrence sequences (1000+) bases. You can run this phylip file in your favorite tree software. We use iq-tree. 
 
 The best way to use this is to run many tests and choose correct refrence sequence corrosponding on what you want to test out. We will have a full guide soon on how we got the most of out of this with many tests and examples and support why this way works if used the correct way.
 
 
 Back to _output folder, You will find a table called variation analysis. 
 
 
 ![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo9.PNG)
 
 
 
 
 This also captures its information from the graphs. It contain fraction of bases that didnt match for each read/read pair for this refrence. Looking at this table, can tell you which graphs have the most  phylogentic positions, and you can make decsions based on that.




## How to get the most out of the tool     
    
    
    





















[//]: # 
   [.zip]: <https://github.com/johnssproul/RepeatProfiler/releases/download/0.9/RepeatProfiler-v0.9-source.zip>
   [repeatprof repository]: <https://hub.docker.com/r/durberg7/repeatprof>
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



