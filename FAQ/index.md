---
layout: default
title: FAQ
---

<nav>
    <ul>
      <li><a href="/RepeatProfiler/">Home</a></li>
      <li><a href="/RepeatProfiler/installation">Installation</a></li>
      <li><a href="/RepeatProfiler/gettingstarted">Getting Started</a></li>
      <li><a href="/RepeatProfiler/output">Output</a></li>
      <li><a href="/RepeatProfiler/tips">Tips for Users</a></li>
      <li><a href="/RepeatProfiler/documentation">Documentation</a></li>
      <li><a href="/RepeatProfiler/FAQ" style="color:red">FAQ</a></li>
    </ul>
</nav>

# FAQ

#### For runs with multiple species, is there a limit to the evolutionary divergence that can be spanned by my taxon sampling?

See answer <a href="/RepeatProfiler/tips#divergence">here</a>.

#### How does RepeatProfiler handle read mapping?

See answer <a href="/RepeatProfiler/tips#mapping">here</a>.

#### How should I approach making profiles of tandem repeats (e.g., satDNAs) and/or short reference sequences?

See answer <a href="/RepeatProfiler/tips#satdna">here</a>.

#### For multi-species runs, which species should serve as the source of reference sequences?

See answer <a href="/RepeatProfiler/tips#multi">here</a>.

#### Can I provide my own BAM file, or do I need to let RepeatProfiler do the mapping for me?

Yes, using the “-bam” flag you can feed your own BAM file into RepeatProfiler. See the <a href="https://github.com/johnssproul/RepeatProfiler/blob/master/README.md" target="_blank">README</a> on GitHub for more details.

#### Can RepeatProfiler handle long-read data?

Because RepeatProfier maps reads using bowtie2, which was designed for short-read data, it cannot handle long reads as raw input. However, if you map long reads outside of RepeatProfiler with a different read mapper, you can always input the BAM file using the “-bam” flag and use the data visualization and comparative analysis features of RepeatProfiler for your long-read data.

#### Can I annotate specific coordinates along profiles?

Yes, using the “-bed” flag you can include a BED file with annotations for your reference which will be plotted along the x-axis of profiles. See the <a href="https://github.com/johnssproul/RepeatProfiler/blob/master/README.md" target="_blank">README</a> on GitHub for more details

#### Should I remove PCR duplicates prior to making profiles?

Users have the option to remove PCR duplicates using the “-rmdup” flag. Although we provide this option, we do not make a strong recommendation whether to remove duplicate sequences or not. Because the pipeline is built around mapping repetitive sequences, there is a risk that removing duplicates will eliminate valid indels from different repeats that should in fact contribute to profiles. We suggest users consider their library preparation and sequencing approach and explore output from different settings to help inform their use of this flag. 

<br><br><br><br><br><br><br><br><br><br>
