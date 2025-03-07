{ lib, stdenv, fetchfossil, libGL, libX11, SDL, ghostscript }:

stdenv.mkDerivation {
  pname = "farbfeld-utils";
  version = "2021-05-15";

  src = fetchfossil {
    url = "http://zzo38computer.org/fossil/farbfeld.ui";
    rev = "85139a0300";
    sha256 = "sha256-A6fOqVnD6jtlYUC91c8+dAUdT8F4dQXS0LHh/Fk7A4s=";
  };

  buildInputs = [ libGL libX11 SDL ghostscript ];

  buildPhase = ''
    mkdir -p $out/bin
    $CC -c lodepng.c
    find . -name '*.c' -exec grep 'gcc' {} + -print0 | \
      awk -F: '{print $2}' | sed 's#~/bin#$out/bin#;s#gcc#$CC#;s#/usr/lib/libgs.so.9#-lgs#' | xargs -0 sh -c
  '';

  dontInstall = true;

  meta = with lib; {
    description = "Collection of utilities for farbfeld picture format";
    homepage = "http://zzo38computer.org/fossil/farbfeld.ui/home";
    license = licenses.publicDomain;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
