& "../../make.ps1" -Target OpenCover

Write-Host "####################################"
Write-Host ("make file returned: {0}" -f $LASTEXITCODE)
Write-Host "####################################"
if ($LASTEXITCODE -ne 0) {
	throw "It seems you code either doesn't compile, or the unit test(s) are broken ... Fix compilation error(s) before commiting"
}

if (([xml] (get-content ../../NUnitTestResult.xml)).'test-run'.failed -gt 0){
	throw "unit tests failed. See NUnitTestResult.xml"
}
