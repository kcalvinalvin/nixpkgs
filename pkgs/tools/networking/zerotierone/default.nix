{ stdenv, fetchFromGitHub, openssl, lzo, zlib, iproute, which, ronn }:

stdenv.mkDerivation rec {
  pname = "zerotierone";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "zerotier";
    repo = "ZeroTierOne";
    rev = version;
    sha256 = "1b78jr33xawdkn8dcs884g6klj0zg4dazwhr1qhrj7x54bs7gizr";
  };

  preConfigure = ''
      substituteInPlace ./osdep/ManagedRoute.cpp \
        --replace '/usr/sbin/ip' '${iproute}/bin/ip'

      substituteInPlace ./osdep/ManagedRoute.cpp \
        --replace '/sbin/ip' '${iproute}/bin/ip'

      patchShebangs ./doc/build.sh
      substituteInPlace ./doc/build.sh \
        --replace '/usr/bin/ronn' '${ronn}/bin/ronn' \
        --replace 'ronn -r' '${ronn}/bin/ronn -r'
  '';

  buildInputs = [ openssl lzo zlib iproute which ronn ];

  installPhase = ''
    install -Dt "$out/bin/" zerotier-one
    ln -s $out/bin/zerotier-one $out/bin/zerotier-idtool
    ln -s $out/bin/zerotier-one $out/bin/zerotier-cli

    mkdir -p $man/share/man/man8
    for cmd in zerotier-one.8 zerotier-cli.1 zerotier-idtool.1; do
      cat doc/$cmd | gzip -9n > $man/share/man/man8/$cmd.gz
    done
  '';

  outputs = [ "out" "man" ];

  meta = with stdenv.lib; {
    description = "Create flat virtual Ethernet networks of almost unlimited size";
    homepage = https://www.zerotier.com;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sjmackenzie zimbatm ehmry obadz ];
    platforms = platforms.x86_64 ++ platforms.aarch64;
  };
}
