
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
The easiest way to setup RepeatProfiler with all of its dependencies is through the package manager [Homebrew]. If you don’t have Homebrew, it is available for installation on [linux/WSL] and on [macOS].

After Homebrew is installed, run this command:
```
brew install HounerX/homebrew-repo/repeatprof
```

Note that the Homebrew installation can take some time, so you may need to be patient. To test if the installation was successful, try calling the program at the command line using:

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
As an alternative to Homebrew and Docker you can clone this repository for the latest program version and install the dependencies separately. 
```
git clone https://github.com/johnssproul/RepeatProfiler/
```
Required dependencies are:
 - bowtie2 (v2.3.5.1 or newer)
 - samtools
 - GNU parallel
 - python (2 and 3)
 - R
 - R packages: ggplot2, ggpubr, scales, reshape2
 You can install required R packages by running this command:  
```sh
echo "install.packages(c('ggplot2','ggpubr','scales','reshape2','png'), repos=\"https://cran.rstudio.com\")" | R --no-save
```
After dependencies are installed, move to the unzipped directory containing the program in the terminal and run the following command to check that the program is working. (The words “REPEAT PROFILER” should print to the screen.)  

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
 - Paired-end or single-end reads are supported. Valid extensions are '.fastq', '.fq'. Compressed reads ‘i.e., .fastq.gz’ also supported.
 - For paired reads, the last string before the file extension should be ‘_1’ for Read1 and ‘_2’ for Read2 (alternatively ‘_R1’ and ‘_R2’ may be used). For example: ‘SampleName_1.fastq.gz’ and ‘SampleName_2.fastq.gz’.




##### Generating profiles:

Here is a sample profile command with mandatory flags explained: 
```sh
repeatprof profile <'-p' for paired-end reads or '-u' for single-end> <path to reference sequence> <path of the folder containing reads> [optional flags] 
```

Here is an example of a functional example command (explanations omitted):

```sh
repeatprof profile -p Refs.fa /RepeatProfilerData/Test1
```

Explanation: 
- 'repeatprof'  calls the program
- 'profile'  the command that directs program to generate profiles (see other command options below) 
- '-p'  indicates the input reads are paired 
- 'Refs.fa'  specifies the FASTA file containing reference sequences (located in the current directory in this example, alternatively a path can be provided)
- '/RepeatProfilerData/Test1'  specifies the path of the directory containing input read files

#### SAMPLE DATA 

Download the sample input data set provided [here]. 

1- Unzip and navigate into the downloaded folder an enter the command: 
```sh
repeatprof profile -p reference.fa  <enter full path of current directory>

```
2- If it runs without errors, everything should set up correctly



###### Commands: 
| Command                        | usage                                                                                                                                                           |
|------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| profile                     | Primary analysis command. This command should be followed by read type (i.e., '-p' or -u' for paired-end or single-end respecitively) or '-bam' if bam files are provided instead of reads. Then the name of the fasta file containing reference sequences (or the path if that file is not in the current directory), the path to the input reads (or bam files), and any optional flags.                                                                |
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
| --<bowtie_setting>                     | Allows user to change among Bowtie 2 preset parameters. Valid arguments include '--very-fast-local', '--fast-local', '--sensitive-local', '--very-sensitive-local', '--very-fast', '--fast', '--sensitive', '--very-sensitive'. Default is '--very-sensitive-local'. If changing Bowtie2 settings beyond these presets, use the next flag|
| -bowtieflag ""                   | Use this flag to enter more complex Bowtie2 settings. Any valid Bowtie2 command can be entered between the quotes. For example:   -bowtieflag "--sensitive-local --no-mixed"|
| -indel <cut_off>  | Use this flag to detect and annotate the plots for indels. the cut off is 0.10 by default. User can provide a custom cutoff between 1 and 0. For example: -indel 0.5
| -bed <bed file full directory> | Use this flag and provide FULL path to bed file that contains annotations to the references you are analyzing to annotate the plots. 




 
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
 - Examples of output
 - Explanation of how graphs are generated and color scale applied
 - Explanation of the phylip file produced for phylogenetic analysis


## What is in the output folder?
After a successful run you will find this 
folder in your current directory (or the output directory you specified using '-o'):

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo_of_the_folder.PNG)

The directory name includes a time stamp of when the run was started. In the directory you will find 3 folders (mapping_log_files not shown here), the primary output folder with a time stamp and 'temp'. The 'temp' folder contains program intermediate files that can help us trace errors if there's an issue you can't track down on your own. The 'mapping_log_files' folder (not shown) has the logfile from Bowtie2 which can be useful for troubleshooting problems with your input references, reads, or non-default mapping parameters.  
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo2.PNG)

The time-stamped folder has the bulk of the program output: 

Here there will be one folder for each refrence named *(refname)_output* which have output related to that reference. We will get to that soon.


Next, you will find a ReadMe file. It will look something like this 
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo1.PNG)

This read me tells you how internal index numbers used by the pipeline correspond to your input samples. These indexes appear on reference-specific output folders. For example in a folder named 'refname_output_001', the '001' indicates this folder has output for the first set of sample reads processed by the pipeline. 

Output also includes the Run_summary.csv table. It contains useful info about the references you used (e.g., length), average coverage, percent coverage, etc. Since this run included the '-singlecopy' flag which normalizes coverage based on single-copy genes, there will be some info about single copy genes at the bottom of the table.

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo10.PNG)

In this table each row summarizes results of mapping reads from a given sample to a single reference seqeuence. So if you had a run with reads from four samples, and four reference sequences, this table would include 16 rows, with four for each reference sequence corresponding to each of the four samples that were mapped.


The folder called plots_single_copy is only generated if the '-singlecopy' normalization flag is used. It has coverage profiles for each single copy gene. This (as well as the Run_summary.csv table) helps confirm that read mapping patterns on single-copy genes are in line with expectations and leading to reasonable normalized estimates (e.g., they don't show some unexpectedly high coverage region that could skew estimates). 

The folder called map_depth_allrefs has some raw output with depth per postion for every sample within a reference sequence. 



Now take a look at the next level of folders by opening the folder named 'Ref1_DmelR1_output'. In this run, Ref1 is a sequence of the R1 non-LTR retrotransposon in Drosophila melanogaster. 

The contents of this folder look like this: 

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo3.PNG)

The first thing to notice are the numbered subfolders which each contain output (including profiles) for each sample (i.e., set of reads) included in the run. As mentioned earlier, the numbers appended to folder names are internal indexes that correspond to input sample reads. We will go into the subfolders later.

Next you will notice the *scaled_profiles.pdf* file . 

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/phtoto6.PNG)
=
This file groups color-enhanced profiles for all samples into the same PDF. All profiles are shown on the same relative color scale, which makes it easy to scan profiles of all samples for this reference to note interesting patterns. Any single profile shown can be found as a single PDF in the sub-folders mentioned above that are indexed by sample.


Another summary PDF in this directory is *variant_profiles.pdf*. This file contains variant-enhanced profiles for all samples within this reference. These profiles show base-pair resolution of variants relative to the reference sequence across samples, which can also reveal interesting patterns when compared across samples. Again, files with individual profiles for each sample are available in the sample-specific subfolders in this directory. 


![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo7.PNG)


This director also has a PHYLIP-formatted file:  

![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo8.PNG)


This file summarizes signatures in variant-enhanced profiles by encoding abundant variants at each site as molecular-morphological characters (details on this process are provided in out paper on RepeatProfiler). This file can be directly fed into phylogenetic software and analyzed as morphological data. We commonly do this using IQ-TREE. This approach leverages the statistical framework of phylogenetic analysis to groups samples based on signal from variant profiles.


Now let's look in one of the sample-specific subfolders:
![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo5.PNG)

These subfolders contain same plots we looked at earlier but stored as indifidual PDFs. Although they are not grouped with all other samples, they still show the same standardized color scale used in the 'scaled_profiles' file shown above. Another PDF file contains a simplified version of the profiles (an area plot instead of a bar plot) -- we include this as a smaller, but still vector-based file that may be useful for some visual display purposes. This folder also includes a text file with raw output of depth of every postion and variants relative to the reference sequence. 


 
Back to the main output folder, You will find a table called *References_summary_base_coverage*.
 ![](https://github.com/johnssproul/RepeatProfiler/raw/master/pics_readme/photo1A.PNG)
 
This file reports the average fraction of bases with at least 1X coverage for each reference sequence. We have used this file in runs that include many (i.e., hundreds) of repeat reference sequences to help us filter out low-coverage repeats.

The folder called *scaled_profiles_allrefs* contains color-enhanced profiles for the entire run (i.e., all reference sequences) that are shown on the same color scale. This is similar to the 'scaled_profiles.pdf' file found in the output folders for each reference sequence, except that the color scale is set based on the maximum coverage for all profiles in the run, instead of the maximum observed within a reference sequence. Scanning the PDFs in this folder is a good way to identify interesting patterns across repeats. 


#####  Correlation analysis output

Four output folders are generaged by the correlation analysis (i.e., '-corr' flag).

*First folder*: correlation_boxplots_by_group
 This folder contains boxplots for each group defined in user_groups.txt. The boxplots combine correlation values across all repeat references used in the run. Each group has its own plot.

*Second folder*: correlation_boxplots_by_reference
 This folder contains boxplots that show correlation of profile shape within and between user-defined groups for individual repeat references in the run.

*Third folder*: correlation_data
 This folder contains correlation matrices for each reference. The matrices shows all the correlation values among all samples for a reference. Each refrence has its own matrix.

*Fourth folder*:correlation_histograms
 This folder contains histograms of within and between-group correlation values for each reference.

*Last file*: correlation_summary.csv
 This table contains average values of within and between each group correlation value for each reference. It summarizes information for all correlation done in the run.

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



