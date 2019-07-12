class Repeat < Formula
  desc "Yarab"
  homepage "https://github.com/johnssproul/RepeatProfiler/"
  url "https://github.com/johnssproul/RepeatProfiler/raw/master/repeat-test.tar.gz"
  version "1.0"
  sha256 "42d9e05e59c36add973e385dc591acb9b284aed257c259467241b1f6ef354501"
  depends_on "bowtie2"
  depends_on "python"
  depends_on "r"
  depends_on "samtools"
 
  def install
    system "echo", "install.packages(c('ggplot2','gridExtra'),repos='https://cran.rstudio.com')", "|", "R", "--no-save"
    bin.install("The_pipe.sh")
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
  end
 
  test do
    system "#{bin}/The_pipe.sh"
    system "true"
  end
end
