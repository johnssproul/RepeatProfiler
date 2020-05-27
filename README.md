
# RepeatProfiler

A tool for studying repetitive DNA dynamics using low-coverage, short-read data. RepeatProfiler automates generation and visualization of repeat profiles from low-coverage sequence data and allows statistical comparison of profile attributes. The pipeline maps reads to consensus sequences of one or more repeat of interest, generates visually enhanced read depth/copy number profiles for each repeat, and facilitates comparison across profiles within and among samples. Output enables standardized visualization of profiles, and comparative analysis of profile shape within and among user-defined groups, and prepares input files for phylogenetic analysis signal arising from variants within repeat profiles. RepeatProfiler is developed specifically to facilitate study of repetitive DNA dynamics over short evolutionary time scales in groups with limited genomic resources; however, it may be useful in any application where extracting signal from repetitive sequences is useful.


# Features

  - Facilitates data visualization of repeat profiles using short-read data
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
docker exec <container ID> bash repeatprof
```

For more information about how to use RepeatProfiler with Docker see the [repeatprof repository] on Docker hub.

#### Manual Installation
As an alternative to homebrew you can clone this repository for the latest program version and install the dependencies separately. 
```
git clone https://github.com/johnssproul/RepeatProfiler/
```
Required dependencies are:
 - bowtie2 (v2.3.5.1 or newer)
 - samtools
 - python2
 - R
 - R packages: ggplot2, ggpubr, scales, reshape2
You can install required R packages by running this command:  
```sh
echo "install.packages(c('ggplot2','ggpubr','scales','reshape2','png'), repos=\"https://cran.rstudio.com\")" | R --no-save
```
After dependencies are installed, move to the unzipped directory containing the program in the terminal and run the following command to check that the program is working. The words “REPEAT PROFILER” should print to the screen.  

```sh 
bash repeatprof 
```

# Getting started


##### Required Input

To generate profiles, you need two input types: (1) reference sequence(s) to analyze, and (2) short-read sequence data from one or more samples.

1. Reference sequence(s) to analyze (FASTA format).
 - Multi-fasta files are supported. Valid file extensions are '.fa', '.fasta', and 
'.txt'

2. Sequence data (FASTQ format)
 - Paired or unpaired reads are supported. Valid extensions are '.fastq', '.fq'. Compressed reads ‘i.e., .fastq.gz’ also supported.
 - For paired reads, the last string before the file extension should be ‘_1’ for Read1 and ‘_2’ for Read2 (alternatively ‘_R1’ and ‘_R2’ may be used). For example: ‘SampleName_1.fastq.gz’ and ‘SampleName_2.fastq.gz’.




##### Generating profiles:

a sample profile command with mandatory flags explained 
```sh
repeatprof profile <'-p' for paired-end reads or '-u' for single-end> <path to reference sequence> <path of the folder containing reads> [optional flags] 
```

an example of a functional example command (explanations omitted).

```sh
repeatprof profile -p Refs.fa /RepeatProfilerData/Test1
```

Explanation: 
- 'repeatprof'  calls the program
- 'profile'  the command that directs program to generate profiles (see other command options below) 
- '-p'  indicates the input reads are paired 
- 'Refs.fa'  specifies the FASTA files containing reference sequences (located in the current directory in this example, alternatively a path can be provided)
- '/RepeatProfilerData/Test1'  specifies the path of the directory containing input read files

#### SAMPLE DATA 

Download the sample input data set provided [here]. 

1- Unzip and navigate into the downloaded folder an enter the command: 
```sh
repeatprof profile -p reference.fa  <enter full path of current directory>

```
2- check if no errors generated and program ran smoothly this means you have it correctly set up



###### Commands: 
| Command                        | usage                                                                                                                                                           |
|------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| profile                     | Primary analysis command. This command should be followed by read type (i.e., '-p' or -u' for paired-end or single-end respecitively), the name of the fasta file containing reference sequences (or the path if that file is not in the current directory), the path to the input reads, and any optional flags.                                                                |
|pre-corr                                | Auto-generates the base user_groups.txt file required for correlation analysis (see -corr optional flag below).                                                              |
| clean    | In the event of a failed run, this command will clean the remnants of the run from the current directory.                             |



###### Optional flags: 
| optional flag                        | usage                                                                                                                                                           |
|------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| -h                     | Displays help menu.
| -o <folder_path>                     | Directs output folder to the specified folder. Default is the current directory.                                                                 |
| -corr                                | Runs a correlation analysis of profile shape among user-defined groups. If this flag is used ensure the user_groups.txt is present in the working directory (but see next). See below for instructions on preparing the user_groups.txt file.                                                              |
| -corr <file_path>    | Use this to run correlation analysis when user_groups.txt is not in the current directory.      
| -t                                   | Sets the number of threads for multi-processor systems. Default is 4.                                                            |
| -k                                   | Use this flag to keep bam files in the final output folder.                                                            |
| -vertical                            | Generates color-scaled profiles with a vertical color gradient. Default is a horizontal gradient.                                 |                          
| -singlecopy                                | Normalizes read coverage of all samples relative to single-copy genes. This flag is useful when it is useful to compare relative abundance of repeats across samples. When this flag is used, the user needs to provide one or more references of single-copy genes in the FASTA file that contains reference sequences. Single-copy genes must be indicated in that file by appending the FASTA header with '_singlecopy'.                   |
| -rmdup                                   | Uses SAMtools to remove PCR duplicates from read mapping output (left off by default as reads from repetitive loci may be incorrectly assigned as PCR duplicates).                                                            |
| --<bowtie_setting>                     | Allows user to change Bowtie 2 mapping parameters. Valid arguments include '--very-fast-local', '--fast-local', '--sensitive-local', '--very-sensitive-local', '--very-fast', '--fast', '--sensitive', '--very-sensitive'. In addition to these Bowtie 2 presets, any valid full bowtie command string may be entered. Default is '--very-sensitive-local'.                                                                                                              |



 
##### Note: Don't include the <> when typing paths . It is just for illustration here. Also make sure all paths passed into the command have no blank spaces. By default the program looks for input files in the current directory so if only file names are provided it will assume the files are in the current directory. 


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
#### Correlation analysis
If you are making profiles for multiple samples and want to compare profile shape across samples using the correlation analysis feature (i.e., the -corr flag). This command is designed for cases when multiple samples per category are present (e.g., multiple individuals per species) such that -within group correlation values can be compared to -between group values. The -corr flag requires that you provide an input text file (user_groups.txt) that assigns your samples to groups. The user can generate this file manually, or use the program to auto-generate the base user_groups.txt file using this command:
```sh
repeatprof pre-corr <'-u' for unpaired reads or '-p' for paired reads> <path reads folder>
```

After running this command the user_groups.txt will be generated based on your input reads and you can simply replace the placeholder 'TEMPORARY' with your own group numbers such that each sample belonging to a given group has the same number in the 'group' column. You can run this command to view the file and verify that it is in the correct format.
```sh
repeatprof pre-corr -v   
```
(Note: you need to have your edited user_groups.txt in the same directory in which you are running the above command.)

&nbsp;
&nbsp;

# Ouptut

In this section, we walk through a sample output/outputs generated by the sample input data [here]. We will cover:

**What is in the output folder section**
- what each file means
 - How are the graphs generated and scaled
 - How is the phylip file generated


## What is in the output folder
After running your data or sample data linked above, you will find this 
folder in your current directory  or the directory you specified:

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo_of_the_folder.PNG)

The time stamp refers to the  time you started the run. Opening, the folder you will find 2 folder, outpt and temp. temp contains program intermidates, so can help us trace errors if anything broke and you submitted an issue. 
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo2.PNG)

Output folder is where the program output is. Opening it, you can find 

Here you can see  *(refname)_output* which contain all the analysis for this reference.We will get to that soon.


Next thing you will find is ReadMe file.It will look something like this 
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo1.PNG)

This read me tell you what indexes that you will see later when we go to the the specific refrences _output file means.  In short, we refer to your reads paired or unpaired in an index. This makes it easier to name the files and manage output. We convert it back to your read name when analyzing graphs and summary tables. This is just for the folders.  

One of the important outputs is the Run_summar.csv table. It contains very useful info about the refrence length you used, average coverage for reads, percent coverage, base_coverage,etc. It look like this and as you notice we have the reads for you allowing  easy scanning  of the table. 

Since The run had single copy genes for normalization, there will be some info about single copy genes at the bototm of the table

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo10.PNG)

Each row represt the refrence and the read used, so if you had for example 4 pairs of reads/4 unpaired reads, you will have 4 rows with the same refrence name and each row will contain the corrsoponding attributes shown 


The folder called plots_single_copy contains coverage plots for each single copy gene inputed. This helps in vizualizing the abudance of the single_copy genes provided for normalization

The folder called map_depth_allrefs contains depth per postion for every sample per reference. 



Lets say we will go the first folder which is refrence named Ref1_DmelR1_output.  This reference is D.mel R1 element 

You will find  the folder look like this 

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo3.PNG)

First thing you will notice is these sub folders. Each subfolder belong to the sample (this can be either read or read pair) for this specific reference sequence. The indexes which we talked about earlier. We will go into the subfolders later.

Now, next thing you will notice  is *scaled_profiles.pdf* file . 

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/phtoto6.PNG)
=
Each of these graph represent the coverage of the read/read pair when mapped to that  specfic refrence we opened its folder.  They are all based on a single color scale. That means by just quick looking at the graph you can tell which parts of the refrence sequence (refrence sequence base position is on x axis ) has the highest (red)/lowest(blue)  coverage. This  can tell you a lot about this read and refrence sequence. How/where this sequence enriched in that species reads compared to the other species reads. Color scaling accross different reads will help you in a great way to vizualize differences  among very large group of data.


Next pdf in the output folder is the *variant_profiles.pdf*
These plots has the variation(mismatches) in  among all the reads for this specific refrences. They have been put together for your convience to compare. 


![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo7.PNG)


For example, by investigating this pdf, user can tell which regions of the reference has common mismatches between samples 


Opening one of the sub folders will look like this
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo5.PNG)

it contain  the same plots we looked at earlier but indvidully. Keep in mind they are still scaled among all reads, so its main use if you wanted to use a high quality indvidual graph.A text file that contains the information per every position in the refrence sequence. It contains the depth of every postion/mismatches of A/mismatches of T/mismatches of C//mismatches of G/. 





Now  lets go back and check what is in the Phylip file and what does it mean  

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo8.PNG)


Based on the variation plots explained earlier, we were able to capture phylogentic informative sites from these plots. We analysed each plot indivudaly and recored the bases that had high mis match coverage over 10% from the actual coverage. We also accounted for ambigous sites.

 This phylip files are most informative for long refrence sequences (1000+) bases. You can run this phylip file in your favorite tree software. We use iq-tree. Check the detalied tutorial on the website for on how to choose which phylip files to get most accurate relationships between the samples  *upcoming*
 

 
 Back to  main output folder, You will find a table called
 *References_summary_base_coverage*.
 ![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo1A.PNG)
 
This tells you the mean base coverage between all samples for a reference (max value is 1). It is helpful you can discard references with low mean base coverage from phylogentic analysis as their phylip files will not be very imformative 

The folder called *scaled_profiles_allrefs* contains coverage plots scaled based on entire run not just a single reference


#####  Correlation analysis output

4 output folders are outputed in Correlation analysis.

*First folder*: correlation_boxplots_by_group
This folder contains boxplots for each group you inputed in your user_groups.txt. The boxplots show how does a group vary among all references used in the run. Each group has its own plot.

*Second folder*: correlation_boxplots_by_reference
 This folder contains boxplots that compare profile shape within and between user-defined groups, organized by reference.

*Third folder*: correlation_data
 This folder contains correlation matrices for each reference. The matrices shows all the correlation values among all samples for a reference. Each refrence has its own matrix.

*Fourth folder*:correlation_histograms
 This folder contains histograms of within, and between group correlation values for each reference.

*Last file*: correlation_summary.csv
  This table contains average values of within and between each group correlation value for each reference. It summarizes information for all correlation done in the run

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo2A.png)



**Troubleshooting**

If you get a formatting error related to reference sequences, check that the file is in FASTA format, and that it has Unix LF (an empty line at the end of the file -- this is standard among all linux and macOS text files.)

   
    
    
    





















[//]: # 
   [.zip]: <https://github.com/johnssproul/RepeatProfiler/releases/download/0.9/RepeatProfiler-v0.9-source.zip>
   [repeatprof repository]: <https://hub.docker.com/r/durberg7/repeatprof>
   [here]: <https://github.com/johnssproul/RepeatProfiler/releases/download/0.96/sample_data.zip>
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



