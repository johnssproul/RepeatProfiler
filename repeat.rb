class Repeat < Formula
  desc "Yarab"
  homepage "https://github.com/johnssproul/RepeatProfiler/"
  url "https://github.com/johnssproul/RepeatProfiler/raw/master/repeat-test.tar.gz"
  version "1.0"
  sha256 "1925c30131c999dbabae1b496b4a60923351f6e792debce42aed7b5fc2a97bc3"
  depends_on "bowtie2"
  depends_on "python"
  depends_on "r"
  depends_on "samtools"

  def install
    system "Rscript", "-e", "install.packages(c('ggplot2','gridExtra'),repos='https://cran.rstudio.com')"
    bin.install("The_pipe.sh")
    lib.install("Readmegen.sh")
    lib.install("map_mpileup.sh")
    lib.install("Fasta_splitter.sh")
    lib.install("The_depth_analyser.R")
    lib.install("RP_4.0.R")
    lib.install("polymorphism_2.0.R")
    lib.install("fraction_bases.R")
    lib.install("Corr_test.R")
    lib.install("All_RP_graphs_reference.R")
    lib.install("All_RP_graphs.R")
    lib.install("multi_Poly_maker.R")
    lib.install("pileup_basecount_sink.py")
  end

  test do
    system "#{bin}/The_pipe.sh"
    system "true"
  end
end
