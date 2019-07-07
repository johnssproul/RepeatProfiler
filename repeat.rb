# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Repeat < Formula
  desc "yarab"
  homepage "https://github.com/johnssproul/RepeatProfiler/"
  url "https://github.com/johnssproul/RepeatProfiler/raw/master/repeat-test.tar.gz"
  version "1.1"
  sha256 ""
  # depends_on "cmake" => :build
	depends_on "r"
	depends_on "python"
	depends_on "samtools"
	depends_on "bowtie2"
	



  def install
	system "Rscript", "-e", "install.packages(c('ggplot2','gridExtra'),repos='https://cran.rstudio.com')"
	
	#system "bash install.sh"
	bin.install("The_pipe.sh")
	bin.install("Readmegen.sh")
	bin.install("map_mpileup.sh")
	bin.install("Fasta_splitter.sh")
	bin.install("The_depth_analyser.R")
	bin.install("RP_4.0.R")
	bin.install("polymorphism_2.0.R")
	bin.install("fraction_bases.R")
	bin.install("Corr_test.R")
	bin.install("All_RP_graphs_reference.R")
	bin.install("All_RP_graphs.R")
	bin.install("multi_Poly_maker.R")
	bin.install("pileup_basecount_sink.py")
	
	#system "cp -r scripts bin"
  
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test Repeat-test`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
