| [Installation](./readme.md)| [Tutorial](./tutorial.md) | [Application](uses.md) |
# Getting started

### Required Input data:

To generate profiles, you need two input types: (1) one or more reference sequence, and (2) short-read sequence data from one or more samples.

1. Reference sequences
- One or more reference sequence of repeats in [FASTA format]
- For tips on obtaining reference sequences for groups that lack repeat reference libraries see “TBD section” below (or LINK to full tutorial) ???

2. Sequence data
- Read files should be in FASTQ format.
- Files should end in the '.fastq', or compressed '.fastq.gz' extension ('.fq' and '.fq.gz' are also supported).
- Input reads may be paired, or unpaired. 
  - If paired data are used, the last string before the file extension should be '_1' for Read1 and '_2' for Read2 (alternatively '_R1' and '_R2' may be used). 
  - ex. ‘SampleName_1.fastq.gz’ and ‘SampleName_2.fastq.gz’
  
###### Supported Final Strings and File Formats

|  Input |   |   |   |   |   |   |   |
|---|---|---|---|---|---|---|---|
| Paired Reads   | _R1.fastq | _R1.fastq.gz | _R1.fq | _1.fastq | _1.fastq.gz | _1.fq | _1.fq.gz |   
|                | _R2.fastq | _R2.fastq.gz | _R2.fq | _2.fastq | _2.fastq.gz | _2.fq | _2.fq.gz |   
| Unpaired Reads | .fq.gz    | .fastq.gz    | .fq    | .fastq   | .fastq      | .fq   | .fq.gz   |   
| Reference      | .fa       | .fasta       | .txt   |          |             |       |          |                

Review the sample input data set provided [here]. Also make sure all your files have Unix LF - ie. an empty line at the end of the file. This is standard among all linux and macOS text files


### Generating Profiles

General Command:
```sh
repeatprof profile <-p for paired reads or -u for unpaired> <the reference sequence path > <path of the folder containing reads> [optional flags]
```

Functional Command:
```sh
repeatprof profile -p Refs.fa /RepeatProfilerData/Test1
```

Explanation:
- 'repeatprof' is the program
- 'profile' is the command that directs the program to generate profiles
- '-p' indicates the input reads are paired
- 'Refs.fa' specifies the FASTA files containing reference sequences (located in the current directory in this example)
– '/RepeatProfilerData/Test1' specifies the path of the directory containing input read files


###### Optional Flags for Profile:

| Flag| Usage |
|-------------------------------------|---|
| -o <folder_path>                    | direct the final output folder to the specified folder. Default: current directory |
| -corr                               | run correlation analysis. A user_provided.txt is needed for the correlation graph  |
| -usrprov <user_provided.txt path>   | provide path of user_provided.txt Default: current directory                       |
| -k                                  | keep the sorted bam files of the alignments in the final output folder             |
| --very-sensitive                    | bowtie alignment setting. Default: --very-sensitive-local                          |
| --sensitive                         | bowtie alignment setting. Default: --very-sensitive-local                          |
| --very-fast                         | bowtie alignment setting. Default: --very-sensitive-local                          |
| --fast                              | bowtie alignment setting. Default: --very-sensitive-local                          |
| --local                             | bowtie alignment setting. Default: --very-sensitive-local                          |
| --very-sensitive-local              | bowtie alignment setting. Default: --very-sensitive-local                          |
| --sensitive-local                   | bowtie alignment setting. Default: --very-sensitive-local                          |
| --fast-local                        | bowtie alignment setting. Default: --very-sensitive-local                          |
| --very-fast-local                   | bowtie alignment setting. Default: --very-sensitive-local                          |

##### Note on Bowtie2 alignment settings: sensitive settings are generally more accurate, but slower, while fast settings are generally less accurate, but faster. See the [Bowtie2 Manual] for more information.

##### Note on Flag Arguments: Don't include the <> when typing paths. Also, paths passed into this command cannot have blank spaces.

### Generating Correlation Analysis
Preparing user_provided.txt for -corr
Lets say you want to make a profile for reads you prepared and want to include correlation analysis graphs which show how similar/different read mapping depth are. In order to conduct this analysis reads must be grouped. The manner of grouping is dependent on what you are aiming to get out of this analysis.

Generate user_provided.txt Command:
```sh
repeatprof pre-corr < -u for unpaired reads  or -p paired reads  > <path reads folder>
```

After running this command a file named user_provided.txt will be generated in your current directory based on your reads. In order to use this file for correlation analysis replace the placeholder 'temporary' with your own desired groups.  

Verify Correct format and View Command:
```sh
repeatprof pre-corr -v   
```

##### The user_provided.txt must be in the same directory you are running this command in.

## Now you are all set for generating profiles with nice looking correlation groups graph and using the tool. GOOD JOB !

In case you terminated the run, you can use this command to clean up intermediate files created by the tool.
```sh
repeatprof clean   
```

[//]: #
   [Installation]: <https://johnssproul.github.io/RepeatProfiler/>
   [Application]: <https://johnssproul.github.io/RepeatProfiler/Uses.html>
   [FASTA format]: <https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet>
   [Bowtie2 Manual]: <http://gensoft.pasteur.fr/docs/bowtie2/2.0.0/>
   
