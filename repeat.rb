class Repeat < Formula
  desc "yarab"
  homepage "https://github.com/johnssproul/RepeatProfiler/"
  url "https://github.com/johnssproul/RepeatProfiler/raw/master/repeat-test.tar.gz"
  version "1.0"
  sha256 "c27daab16ffeb5b05510c01383264b6daaea5c61b3cd31a053eba9c07fe81987"
	depends_on "bowtie2"
	depends_on "python"
	depends_on "r"
	depends_on "samtools"
	



  def install
	system "Rscript", "-e", "install.packages(c('ggplot2','gridExtra'),repos='https://cran.rstudio.com')"
	
	#system "bash install.sh"
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
	#bin.install("pileup_basecount_sink.py")
	
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
