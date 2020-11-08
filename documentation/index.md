---
layout: default
title: Documentation
---

<nav>
    <ul>
      <li><a href="/RepeatProfiler/">Home</a></li>
      <li><a href="/RepeatProfiler/installation">Installation</a></li>
      <li><a href="/RepeatProfiler/gettingstarted">Getting Started</a></li>
      <li><a href="/RepeatProfiler/output">Output</a></li>
      <li><a href="/RepeatProfiler/tips">Tips for Users</a></li>
      <li><a href="/RepeatProfiler/documentation" style="color:red">Documentation</a></li>
      <li><a href="/RepeatProfiler/FAQ">FAQ</a></li>
    </ul>
</nav>

# Documentation

## Commands

<hr>

`profile` :: Primary analysis command. This command should be followed by read type (i.e., '-p' or -u' for paired-end or single-end, respecitively), the path to the fasta file containing reference sequences, the path to the input reads, and any optional flags.

`pre-corr` :: Auto-generates the base user_groups.txt file required for correlation analysis (see -corr optional flag below). 

`clean` :: In the event of a failed run, this command will clean the remnants of the run from the current directory.

## Optional Flags

<hr>

`-h` :: Displays the help menu.

`-o <folder_path>` :: Directs output to the specified folder. <span style="color:yellow">Default: current directory</span>.

`-corr` :: Runs a correlation analysis of profile shape among user-defined groups. If this flag is used, ensure the user_groups.txt is present in the working directory (but see next). See <a href="/RepeatProfiler/gettingstarted">Getting Started</a> for instructions on preparing the user_groups.txt file.

`-corr <file_path>` :: Use this to run correlation analysis when user_groups.txt is not in the current directory.

`-t` :: Sets the number of threads for multi-processor systems. <span style="color:yellow">Default: 4</span>.

`-k` ::	Use this flag to keep bam files in the final output folder.

`-vertical` :: Generates color-scaled profiles with a vertical color gradient. <span style="color:yellow">Default: horizontal gradient</span>.

`-singlecopy` :: Normalizes read coverage of all samples relative to single-copy genes. This flag is used when it is useful to compare relative abundance of repeats across samples. When this flag is used, the user needs to provide one or more references of single-copy genes in the FASTA file that contains reference sequences. Single-copy genes must be indicated in that file by appending the FASTA header with '_singlecopy'.


`-rmdup` :: Uses SAMtools to remove PCR duplicates from read mapping output. <span style="color:yellow">Left off by default</span> as reads from repetitive loci may be incorrectly assigned as PCR duplicates.

`--<bowtie_setting>` :: Allows user to change among Bowtie 2 preset parameters. *Valid arguments*: '--very-fast-local', '--fast-local', '--sensitive-local', '--very-sensitive-local', '--very-fast', '--fast', '--sensitive', '--very-sensitive'. <span style="color:yellow">Default: '--very-sensitive-local'</span>. If changing Bowtie2 settings beyond these presets, use the next flag.

`-bowtieflag ""` :: Use this flag to enter more complex Bowtie2 settings. Any valid Bowtie2 command can be entered between the quotes. For example:
```
-bowtieflag "--sensitive-local --no-mixed"
```

<br><br><br><br><br><br><br><br><br><br>
