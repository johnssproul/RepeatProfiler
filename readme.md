|| [Getting Started](gettingstarted.md) || [Tutorial](tutorial.md) || [Output](output.md) || [Application](uses.md) || 

A tool for generating, visualizing, and comparative analysis of repetitive DNA profiles from short-read data. This tool automates the generation of repetitive DNA profiles from short-read sequence data and one or more reference sequences. Output enables standardized visualization of profiles, and comparative analysis of profile shape within and among user-defined groups, and prepares input files for phylogenetic analysis signal arising from variants within repeat profiles. RepeatProfiler is developed specifically to facilitate study of repetitive DNA dynamics over short evolutionary time scales in groups lacking genomic resources; however, it may be useful in any application where extracting signal from repetitive sequences is needed.

# Features

  - Facilitates data visualization of repeat profiles using short read data
  - Produces publication quality graphs in R that simplify visual comparison of profiles
  - Provides summary statistics related to repeat abundance
  - Conducts comparative analysis of profiles shape across and within user specified groups
  - Enables comparative study of variation within repeats through phylogenetic analysis


# Installation
### Homebrew
The easiest way to setup RepeatProfiler with all of its dependencies is through the package manager [Homebrew]. If you don’t have homebrew, it is available for installation on [linux/WSL] and on [macOS].

After homebrew is installed, run the command:

```
brew install HounerX/homebrew-repo/repeatprof
```

To test if the installation was successful, try calling the program at the command line using:

```sh
repeatprof
```

The words “REPEAT PROFILER” should print to the screen. 

### Docker
If Docker software is installed, pull the RepeatProfiler image with the command:

```
docker pull durberg7/repeatprof
```

To test if the installation was successful, try calling the program at the command line using:

```
docker exec <container ID> ./repeatprof
```

The words “REPEAT PROFILER” should print to the screen. 
For more information about how to use RepeatProfiler with Docker see the [repeatprof repository] on Docker hub.

### Manual
Download [.zip] of the latest program version and install the dependencies separately.

Required dependencies are:
 - [bowtie2]
 - [samtools]
 - [python2] (RepeatProfiler was written for python2, but is also compatible with python3)
 - [R]
    - R packages: ggplot2, ggpubr, scales, reshape2 - it is recommended that R packages be installed using this command:  

```sh
echo "install.packages(c('ggplot2','ggpubr','scales','reshape2'), repos=\"https://cran.rstudio.com\")" | R --no-save
```

To test if the installation was successful, set the current directory to the unzipped file from above and try calling the program at the command line using:

```sh
bash repeatprof
```

The words “REPEAT PROFILER” should print to the screen. 

[//]: #
  [Homebrew]: <https://brew.sh/>
  [linux/WSL]: <https://docs.brew.sh/Homebrew-on-Linux>
  [macOS]: <https://brew.sh/>
  [repeatprof repository]: <https://hub.docker.com/r/durberg7/repeatprof>
  [.zip]: <https://github.com/johnssproul/RepeatProfiler/releases>
  [bowtie2]: <https://github.com/BenLangmead/bowtie2>
  [samtools]: <http://www.htslib.org/doc/samtools.html>
  [python2]: <https://www.python.org/downloads/>
  [R]: <https://www.r-project.org/>
