---
layout: default
title: Installation
---

<nav>
    <ul>
      <li><a href="/RepeatProfiler/">Home</a></li>
      <li><a href="/RepeatProfiler/installation" style="color:red">Installation</a></li>
      <li><a href="/RepeatProfiler/gettingstarted">Getting Started</a></li>
      <li><a href="/RepeatProfiler/output">Output</a></li>
      <li><a href="/RepeatProfiler/application">Applications</a></li>
      <li><a href="/RepeatProfiler/documentation">Documentation</a></li>
      <li><a href="/RepeatProfiler/FAQ">FAQ</a></li>
    </ul>
</nav>

# Installation

## Homebrew

The easiest way to setup RepeatProfiler with all of its dependencies is through the package manager <a href="https://brew.sh/" target="_blank">Homebrew</a>. If you don’t have Homebrew, it is available for installation on <a href="https://docs.brew.sh/Homebrew-on-Linux" target="_blank">Linux/WSL</a> and <a href="https://brew.sh/" target="_blank">macOS</a>.

After Homebrew is installed, run this command:

```sh
brew install HounerX/homebrew-repo/repeatprof
```

Note that the Homebrew installation can take some time, so you may need to be patient. To test if the installation was successful, try calling the program at the command line using:

```sh
repeatprof
```

## Docker

If Docker software is installed, pull the Docker image contanining RepeatProfiler and run the command:

```sh
docker pull durberg7/repeatprof
```

To test if the installation was successful, try calling the program at the command line using :

```sh
docker exec <container ID> bash repeatprof
```

For more information about how to use RepeatProfiler with Docker see the <a href="https://hub.docker.com/r/durberg7/repeatprof">Docker Hub repository</a>.


## Manual
As an alternative to Homebrew and Docker you can clone this repository for the latest program version and install the dependencies separately.

```sh
git clone https://github.com/johnssproul/RepeatProfiler/
```

Required dependencies are:
- bowtie2 (v2.3.5.1 or newer)
- samtools
- python (2 or 3)
- R and R packages
  - reshape2
  - scales
  - ggplot2
  - ggpubr

You can install required R packages by running this command:

```sh
echo "install.packages(c('ggpubr','ggplot2','scales','reshape2'), repos=\"https://cran.rstudio.com\")" | R --no-save
```

After dependencies are installed, move to the unzipped cloned directory in the terminal and run the following command to check that the program is working.

```sh
bash repeatprof
```

## Successful Installation

When testing a successful installation, the words “REPEAT PROFILER” should print to the console.
