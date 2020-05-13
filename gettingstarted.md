|| [1.Installation](readme.md) ||  [***2.Getting Started***](gettingstarted.md) || [3.Output](output.md) || [4.Application](uses.md) || 

# Getting started

### Required Input

To generate profiles, you need two input types: (1) one or more reference sequences and (2) short-read sequence data from one or more samples.

1. Reference sequences (FASTA format)
  - Multi-fasta files are supported. Valid file extensions are '.fa', '.fasta', and '.txt'

2. Sequence data (FASTQ format)
  - Paired or unpaired reads are supported. Valid extensions are '.fastq', '.fq'. Compressed reads ‘i.e., .fastq.gz’ also supported.
  - For paired reads, the last string before the file extension should be ‘_1’ for Read1 and ‘_2’ for Read2 (alternatively ‘_R1’ and ‘_R2’ may be used). For example: ‘SampleName_1.fastq.gz’ and ‘SampleName_2.fastq.gz’.

### Generating Profiles

###### General Command Structure:
```sh
repeatprof profile <-p for paired reads or -u for unpaired> <path to reference sequence> <path to the folder containing reads> [optional flags]
```

###### Functional Command:
```sh
repeatprof profile -p Refs.fa /RepeatProfilerData/Test1
```

###### Explanation:
- 'repeatprof' is the program
- 'profile' is the command that directs the program to generate profiles (see other command options below)
- '-p' indicates the input reads are paired
- 'Refs.fa' specifies the FASTA files containing reference sequences (located in the current directory in this example)
– '/RepeatProfilerData/Test1' specifies the path of the directory containing input read files

### Sample Data

Download the sample input data set provided [here].

1. Unzip and navigate into the downloaded folder and enter the command:
```sh
repeatprof profile -p reference.fa  <enter full path of current directory>
```
2. Check if no errors were generated and program ran smoothly.

###### Optional Flags for Profile:

| Flag| Usage |
|---|---|
| -h | Displays help menu. |
| -o <folder_path> | Directs output folder to the specified folder. Default: current directory. |
| -corr | Runs a correlation analysis of profile shape among user-defined groups. If this flag is used ensure the user_groups.txt is present in the working directory (but see next). See below for instructions on preparing the user_groups.txt file. |
| -corr <file_path> | Use this to run correlation analysis when user_groups.txt is not in the current directory. |
| -t | Sets the number of threads for multi-processor systems. Default: 4. |
| -k | Use this flag to keep bam files in the final output folder. |
| -vertical| Generates color-scaled profiles with a vertical color gradient. Default: horizontal gradient. |
| -singlecopy | Normalizes read coverage of all samples relative to single-copy genes. This flag is useful when it is useful to compare relative abundance of repeats across samples. When this flag is used, the user needs to provide one or more references of single-copy genes in the FASTA file that contains reference sequences. Single-copy genes must be indicated in that file by appending the FASTA header with 'singlecopy' |
| -rmdup | Uses SAMtools to remove PCR duplicates from read mapping output (left off by default as reads from repetitive loci may be incorrectly assigned as PCR duplicates). |
| -- <bowtie_setting> | Allows user to change Bowtie 2 mapping parameters. Valid arguments include '--very-fast-local', '--fast-local', '--sensitive-local', '--very-sensitive-local', '--very-fast', '--fast', '--sensitive', '--very-sensitive'. In addition to these Bowtie 2 presets, any valid full bowtie command string may be entered. Default: '--very-sensitive-local'. See [Bowtie2 Manual] for more information.|

##### NOTE: Don't include the <> when typing paths . It is just for illustration here. Also make sure all paths passed into the command have no blank spaces. By default the program looks for input files in the current directory so if only file names are provided it will assume the files are in the current directory.

### Correlation Analysis
If you are making profiles for multiple samples and want to compare profile shape across samples using the correlation analysis feature (i.e., the -corr flag). This command is designed for cases when multiple samples per category are present (e.g., multiple individuals per species) such that -within group correlation values can be compared to -between group values. The -corr flag requires that you provide an input text file (user_groups.txt) that assigns your samples to groups. The user can generate this file manually, or use the program to auto-generate the base user_groups.txt file using this command:

```sh
repeatprof pre-corr <'-u' for unpaired reads or '-p' for paired reads> <path reads folder>
```

After running this command the user_groups.txt will be generated based on your input reads and you can simply replace the placeholder 'TEMPORARY' with your own group numbers such that each sample belonging to a given group has the same number in the 'group' column. You can run this command to view the file and verify that it is in the correct format.

```sh
repeatprof pre-corr -v   
```

###### Example of user_groups.txt
![](./pics/user_groups.png)

##### NOTE: The user_groups.txt must be in the same directory you are running repeatprof in. 

[//]: #
   [here]: <https://github.com/johnssproul/RepeatProfiler/releases/download/0.9/sample_input.zip>
   [Bowtie2 Manual]: <http://gensoft.pasteur.fr/docs/bowtie2/2.0.0/>  
