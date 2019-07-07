# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class RepeatTest < Formula
  desc "yarab"
  homepage "https://github.com/johnssproul/RepeatProfiler/"
  url "https://github.com/johnssproul/RepeatProfiler/raw/master/Repeatprofiler.tar.gz"
  version "1.1"
  sha256 ""
  # depends_on "cmake" => :build

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
   ## system "./configure","--prefix=#{prefix}"
    # system "cmake",  ".", *std_cmake_args
    #system "cp The_Pipe.sh scripts *  $(brew --prefix)/bin   " # if this fails, try separate make/make install steps
	system "install.sh #{prefix}"
	system "cp -r *  #{prefix}"
	bin.install("The_pipe.sh")

	#system "cp -r 
  
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
