{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  name = "mender-${version}-${stdenv.hostPlatform.config}";
  version = "1.6.1";

  goPackagePath = "github.com/mendersoftware/mender";

  src = fetchFromGitHub {
    owner = "mendersoftware";
    repo = "mender";
    rev = version;
    sha256 = "05mc7hm08mbvxnnpqx1bw8k0plh38hxnynh9vbzkf9nx79jqvkzp";
  };

  postUnpack = ''
    export CC="${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
  '';

  postInstall = ''
    ${stdenv.cc.bintools.bintools}/bin/${stdenv.cc.targetPrefix}strip \
      -s $bin/bin/mender
  '';
}
