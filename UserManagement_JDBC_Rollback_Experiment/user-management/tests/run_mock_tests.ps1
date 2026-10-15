# Chay toan bo mock tests bang JDK 17+ (khong can MySQL/Maven).
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$build = Join-Path $PSScriptRoot 'build'
New-Item -ItemType Directory -Path $build -Force | Out-Null
$sources = @()
$sources += @(Get-ChildItem (Join-Path $PSScriptRoot 'stubs') -Filter '*.java' -Recurse | ForEach-Object FullName)
$sources += @(Get-ChildItem (Join-Path $project 'src/main/java') -Filter '*.java' -Recurse | ForEach-Object FullName)
$sources += @(Get-ChildItem $PSScriptRoot -Filter '*Test.java' | ForEach-Object FullName)
& javac --release 17 -encoding UTF-8 -d $build @sources
if ($LASTEXITCODE -ne 0) { throw 'javac failed' }
$tests = @(
  'UseTransactionMockTest',
  'StoredProceduresCrudMockTest',
  'com.codegym.controller.ServletCrudStoredProceduresMockTest',
  'com.codegym.controller.ServletUseTransactionMockTest',
  'NoTransactionMockTest',
  'TxMockTest',
  'com.codegym.controller.ServletTransactionMockTest',
  'RollbackExperimentMockTest',
  'com.codegym.controller.ServletRollbackExperimentMockTest'
)
foreach ($test in $tests) {
    Write-Host "--- $test ---"
    & java -cp $build $test
    if ($LASTEXITCODE -ne 0) { throw "Failed: $test" }
}
Write-Host 'All mock suites passed. This does NOT test MySQL or Tomcat.'
