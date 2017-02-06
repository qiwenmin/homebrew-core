class Ucon64 < Formula
  desc "ROM backup tool and emulator's Swiss Army knife program"
  homepage "http://ucon64.sourceforge.net/"
  url "https://downloads.sourceforge.net/ucon64/ucon64-2.0.2-src.tar.gz"
  sha256 "2df3972a68d1d7237dfedb99803048a370b466a015a5e4c1343f7e108601d4c9"
  head ":pserver:anonymous:@ucon64.cvs.sourceforge.net:/cvsroot/ucon64", :using => :cvs

  bottle do
    sha256 "e53964f03c96339c55777287baefc70a7983fbcbc0df632b9271b6195759ac00" => :el_capitan
    sha256 "2e3374d6985209c430b81b0f50b16b97cb91696df041fa4a7700793de5959faa" => :yosemite
    sha256 "cd3f63bdce54eeca0723c9150d8916d980dd5ca98d6ba2e956bc7553922ca864" => :mavericks
  end

  resource "super_bat_puncher_demo" do
    url "http://morphcat.de/superbatpuncher/Super%20Bat%20Puncher%20Demo.zip"
    sha256 "d74cb3ba11a4ef5d0f8d224325958ca1203b0d8bb4a7a79867e412d987f0b846"
  end

  def install
    # ucon64's normal install process installs the discmage library in
    # the user's home folder. We want to store it inside the prefix, so
    # we have to change the default value of ~/.ucon64rc to point to it.
    # .ucon64rc is generated by the binary, so we adjust the default that
    # is set when no .ucon64rc exists.
    inreplace "src/ucon64_misc.c", 'PROPERTY_MODE_DIR ("ucon64") "discmage.dylib"',
                                   "\"#{opt_prefix}/libexec/libdiscmage.dylib\""

    cd "src" do
      system "./configure", "--disable-debug",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      system "make"
      bin.install "ucon64"
      libexec.install "libdiscmage/discmage.so" => "libdiscmage.dylib"
    end
  end

  def caveats; <<-EOS.undent
      You can copy/move your DAT file collection to $HOME/.ucon64/dat
      Be sure to check $HOME/.ucon64rc for configuration after running uCON64
      for the first time.
    EOS
  end

  test do
    resource("super_bat_puncher_demo").stage testpath

    assert_match "00000000  4e 45 53 1a  08 00 11 00  00 00 00 00  00 00 00 00",
                 shell_output("#{bin}/ucon64 \"#{testpath}/Super Bat Puncher Demo.nes\"")
  end
end
