class RepeatProf < Formula
  desc 	"RepeatProfiler: A tool for generating, visualizing, and comparing repetitive DNA profiles"
  homepage "https://github.com/johnssproul/RepeatProfiler/"
  url "https://github.com/johnssproul/RepeatProfiler/raw/master/repeat-test.tar.gz"
  version "0.9"
  sha256 "9696aabc2d752f0e2632a957d8a244eaeefb19e215a6e00be2d78bae965ad904"
  depends_on "bowtie2"
  depends_on "python"
  depends_on "r"
  depends_on "samtools"
 
  def install
    system "echo", "install.packages(c('ggplot2','gridExtra','ggpubr','magrittr','scales'),repos='https://cran.rstudio.com')", "|", "R", "--no-save"
    bin.install("repeatprof")
    libexec.install("Readmegen.sh")
    libexec.install("map_mpileup.sh")
    libexec.install("Fasta_splitter.sh")
    libexec.install("The_depth_analyser.R")
    libexec.install("RP_4.0.R")
    libexec.install("polymorphism_2.0.R")
    libexec.install("fraction_bases.R")
    libexec.install("Corr_test.R")
    libexec.install("All_RP_graphs_reference.R")
    libexec.install("All_RP_graphs.R")
    libexec.install("multi_Poly_maker.R")
    libexec.install("pileup_basecount_sink.py")
	libexec.install("user_supplied_maker.R")
  end
 
  test do
    system "#{bin}/repeatprof"
    system "true"
  end
end
