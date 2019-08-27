
[Tutorial](./Tutorial.md)

[Applications](./Uses.md)


Repeat Profiler is a tool for generating, visualizing, and comparing repetitive DNA profiles from short-read data. This tool automates the generation of repetitive DNA profiles from short-read sequence data and one or more reference sequences. Output enables standardized visualization of profiles and comparative analysis of profiles across and within samples. RepeatProfiler is developed specifically to facilitate study of repetitive DNA dynamics over short evolutionary time scales in groups lacking genomic resources; however, it may be useful in any application where extracting signal from repetitive sequences is needed.


# Features:

  - Facilitates data visualization of repeat profiles using short read data
  - Produces publication quality graphs in R that simplify visual comparison of profiles.
  - Provides summary statistics related to repeat abundance, etc.
  - Conducts comparative analysis of profiles shape across and within user specified groups
  - Enables comparative study of variation within repeats through phylogenetic analysis


### Installation
The easiest way to setup RepeatProfiler with all of its dependencies is through the package manager [Homebrew]. If you don’t have homebrew, it is available for installation on [linux/WSL] and on [macOS].

After homebrew is installed, run this command:
```
brew install HounerX/homebrew-repo/repeatprof
```

To test if the installation was successful, try calling the program at the command line using:

```sh
repeatprof
```

### Alternative Installation
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

[//]: #
  [Homebrew]: <https://brew.sh/>
  [linux/WSL]: <https://docs.brew.sh/Homebrew-on-Linux>
  [macOS]: <https://brew.sh/>
