$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootDir = Split-Path -Parent $scriptDir
$htmlFiles = Get-ChildItem -Path $rootDir -Recurse -Filter "*.html"

Write-Host "Total HTML files found: $($htmlFiles.Count)"

$missingCanonical = 0
$missingOg = 0
$missingJsonLd = 0

foreach ($file in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    $hasCanonical = $content.Contains('rel="canonical"')
    $hasOg = $content.Contains('og:title')
    $hasLd = $content.Contains('application/ld+json')
    
    if (-not $hasCanonical) {
        Write-Host "Missing canonical: $($file.Name)"
        $missingCanonical++
    }
    if (-not $hasOg) {
        Write-Host "Missing og:title: $($file.Name)"
        $missingOg++
    }
    if (-not $hasLd) {
        Write-Host "Missing JSON-LD: $($file.Name)"
        $missingJsonLd++
    }
}

Write-Host "Scan completed."
Write-Host "Missing Canonical: $missingCanonical"
Write-Host "Missing OG tags: $missingOg"
Write-Host "Missing JSON-LD: $missingJsonLd"
