|| [1.Installation](readme.md) ||  [2.Getting Started](gettingstarted.md) || [3.Output](output.md) || [***4.Application***](uses.md) || 

# Getting the Most out of Repeat Profiler 

### Normalization
things to talk about here
- how normalization affects the results
- normalization command

### Obtaining Reference Sequences
Reference sequences may be obtained from existing repeat libraries, online databases, or de novo assembly of repeats from the same low-coverage reads used as input for RepeatProfiler. The latter is a good option for those wanting to explore repeat profiles from low-coverage shotgun reads data in groups with limited genomic resources. This can be done by first characterizing repetitive sequences using de novo assembly/annotation software. For example, RepeatExplorer is a reference-free tool that will assemble/annotate repeats from low-coverage shotgun data. The output includes consensus sequences of several repeat categories in fasta format, which can be directly fed into RepeatProfiler as reference sequences.

### Using Common Reference Sequence
RepeatProfiler can be used to map reads from multiple species to a common reference sequence. The value in this approach is that variation in profile shape can then all be compared across all input samples relative to a fixed point of reference. If sample-specific reference sequences were used the presence of indels would prevent direct shape comparison. For cases in which mapping to sample-specific references is desired, it is recommended that the multiple reference sequences be separated by independent runs of the program. This is because the pipeline maps reads for each sample to all repeats simultaneously, such that if two orthologous references are included in the run, mapped reads will be shared across the two references.

##### Bowtie2 Parameters
The Bowtie2 setting affects how the reads are mapped to the reference and therefore what the resulting profile will look like.
things to talk about here
- maybe figure
- the effects of different settings, benefits and cons
- The default setting for Bowtie2 read mapping is end-to-end. This setting maps reads only if the alignment contains all the characters of the read. In contrast, the -local tag indicates that these alignments may omit a few characters in the alignment if it improves the total alignment score of the read. (cite Bowtie2 manual)
 
##### Sequence Divergence
things to talk about here
- maybe figure
- farther the reference is from the reads species-ly, the less coverage and less accurate the profiles will be

# Examples
which ones, what data
