$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootDir = Split-Path -Parent $scriptDir
$articlesDir = Join-Path $rootDir "articles"
$templatePath = Join-Path $scriptDir "article_template.txt"

$template = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
$files = Get-ChildItem -Path $articlesDir -Filter "*.html"

foreach ($file in $files) {
    if ($file.Name -eq "edgenova.html") { continue }
    
    $filePath = $file.FullName
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    
    if ($content.Contains('rel="canonical"')) {
        Write-Host "Skipping $($file.Name) - already has canonical"
        continue
    }
    
    $title = ""
    $idx1 = $content.IndexOf("<title>")
    $idx2 = $content.IndexOf("</title>")
    if ($idx1 -ge 0 -and $idx2 -gt $idx1) {
        $title = $content.Substring($idx1 + 7, $idx2 - $idx1 - 7)
    }
    
    $desc = ""
    $d1 = $content.IndexOf('name="description" content="')
    if ($d1 -ge 0) {
        $start = $d1 + 28
        $d2 = $content.IndexOf('"', $start)
        if ($d2 -gt $start) {
            $desc = $content.Substring($start, $d2 - $start)
        }
    }
    
    $isFaq = $file.Name.StartsWith("faq_")
    $parentCategory = if ($isFaq) { [System.Text.Encoding]::UTF8.GetString([byte[]](0xE7,0xA7,0x91,0xE6,0x99,0xAE,0xE6,0x8C,0x87,0xE5,0x8D,0x97)) } else { [System.Text.Encoding]::UTF8.GetString([byte[]](0xE6,0x9C,0xBA,0xE5,0x9C,0xBA,0xE6,0xB5,0x8B,0xE8,0xAF,0x84)) }
    $parentUrl = if ($isFaq) { "https://tizitop.com/faq.html" } else { "https://tizitop.com/reviews.html" }
    $canonicalUrl = "https://tizitop.com/articles/" + $file.Name
    $suffix = [System.Text.Encoding]::UTF8.GetString([byte[]](0x20,0x2D,0x20,0x54,0x69,0x5A,0x69,0x20,0x54,0x6F,0x70,0xE7,0x9F,0xA5,0xE8,0xAF,0x86,0xE5,0xBA,0x93))
    $cleanTitle = $title.Replace($suffix, '')
    
    $metaBlock = $template
    $metaBlock = $metaBlock.Replace('__CANONICAL__', $canonicalUrl)
    $metaBlock = $metaBlock.Replace('__TITLE__', $cleanTitle)
    $metaBlock = $metaBlock.Replace('__DESC__', $desc)
    $metaBlock = $metaBlock.Replace('__PARENT_CAT__', $parentCategory)
    $metaBlock = $metaBlock.Replace('__PARENT_URL__', $parentUrl)
    
    $targetStr = '<link rel="stylesheet" href="../css/style.css">'
    if ($content.Contains($targetStr)) {
        $newContent = $content.Replace($targetStr, $metaBlock + "`r`n    " + $targetStr)
        [System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "Successfully updated $($file.Name)"
    } else {
        Write-Host "Warning: targetStr not found in $($file.Name)"
    }
}
