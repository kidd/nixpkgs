{ lib, buildPythonPackage, fetchPypi, toml }:

buildPythonPackage rec {
  pname = "setuptools_scm";
  version = "4.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a8994582e716ec690f33fec70cca0f85bd23ec974e3f783233e4879090a7faa8";
  };

  propagatedBuildInputs = [ toml ];

  # Requires pytest, circular dependency
  doCheck = false;
  pythonImportsCheck = [ "setuptools_scm" ];

  meta = with lib; {
    homepage = "https://github.com/pypa/setuptools_scm/";
    description = "Handles managing your python package versions in scm metadata";
    license = licenses.mit;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
