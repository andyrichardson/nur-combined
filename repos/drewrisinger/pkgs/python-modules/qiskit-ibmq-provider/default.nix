{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, arrow
, nest-asyncio
, qiskit-terra
, requests
, requests_ntlm
, websockets
  # Visualization inputs
, withVisualization ? true
, ipython
, ipyvuetify
, ipywidgets
, matplotlib
, plotly
, pyperclip
, seaborn
  # check inputs
, pytestCheckHook
, nbconvert
, nbformat
, pproxy
, qiskit-aer
, vcrpy
}:

let
  visualizationPackages = [
    ipython
    ipyvuetify
    ipywidgets
    matplotlib
    plotly
    pyperclip
    seaborn
  ];
in
buildPythonPackage rec {
  pname = "qiskit-ibmq-provider";
  version = "0.13.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "0qhpbvnc5i4zn3vfipfd9bmddspfj1k8fs75wal33drdfxgfal8f";
  };

  propagatedBuildInputs = [
    arrow
    nest-asyncio
    qiskit-terra
    requests
    requests_ntlm
    websockets
  ] ++ lib.optionals withVisualization visualizationPackages;

  # Most tests require credentials to run on IBMQ
  checkInputs = [
    pytestCheckHook
    nbconvert
    nbformat
    pproxy
    qiskit-aer
    vcrpy
  ] ++ lib.optionals (!withVisualization) visualizationPackages;
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [ "qiskit.providers.ibmq" ];
  # These disabled tests require internet connection, aren't skipped elsewhere
  disabledTests = [
    "test_old_api_url"
    "test_non_auth_url"
    "test_non_auth_url_with_hub"

    # slow tests
    "test_websocket_retry_failure"
    "test_invalid_url"
  ];
  # Ensure run from source dir, not all versions of pytestCheckHook run from proper dir
  # Skip tests that rely on internet access (mostly to IBM Quantum Experience cloud).
  # Options defined in qiskit.terra.test.testing_options.py::get_test_options
  preCheck = ''
    pushd $TMP/$sourceRoot
    export QISKIT_TESTS=skip_online
  '';
  postCheck = "popd";


  meta = with lib; {
    description = "Qiskit provider for accessing the quantum devices and simulators at IBMQ";
    homepage = "https://github.com/Qiskit/qiskit-ibmq-provider";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
