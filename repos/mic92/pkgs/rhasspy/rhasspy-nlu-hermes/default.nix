{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, rhasspy-nlu
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-nlu-hermes";
  version = "0.3.0";

  disabled = pythonOlder "3.7"; # requires python version >=3.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4wOADSd1cVPPfhUnPiX2da298QUrDQACQKpNLufzjR0=";
  };

  postPatch = ''
    sed -i "s/aiohttp==.*/aiohttp/" requirements.txt
    sed -i "s/networkx==.*/networkx/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-nlu
  ];

  meta = with lib; {
    description = "MQTT service for natural language understanding using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-nlu-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
