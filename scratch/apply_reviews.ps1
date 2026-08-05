# PowerShell script to rewrite all 8 reviews using JSON database and template placeholders
# Zero literal Chinese characters in the script source to prevent parser/compiler encoding errors

$jsonData = [System.IO.File]::ReadAllText("C:\Users\Administrator\.gemini\antigravity-ide\brain\2aa85383-3cfd-450b-994e-9af42fa87deb\scratch\review_data.json", [System.Text.Encoding]::UTF8)
$data = ConvertFrom-Json $jsonData

# We use Unicode hex array to safely build button text and title suffix without literals
# " 官网，" -> [char]0x20 + [char]0x5b98 + [char]0x7f51 + [char]0xff0c
# "输入优惠码 " -> [char]0x8f93 + [char]0x5165 + [char]0x4f18 + [char]0x60e0 + [char]0x7801 + [char]0x20
# "享受8折优惠 " -> [char]0x4eab + [char]0x53d7 + [char]0x38 + [char]0x6298 + [char]0x4f18 + [char]0x60e0 + [char]0x20
# " 🚀 立即前往 " -> [char]0x20 + [char]0xd83d + [char]0xde80 + [char]0x20 + [char]0x7acb + [char]0x5373 + [char]0x524d + [char]0x5f80 + [char]0x20
$g1 = [char]0x20 + [char]0xd83d + [char]0xde80 + [char]0x20 + [char]0x7acb + [char]0x5373 + [char]0x524d + [char]0x5f80 + [char]0x20
$g2 = [char]0x20 + [char]0x5b98 + [char]0x7f51 + [char]0xff0c + [char]0x8f93 + [char]0x5165 + [char]0x4f18 + [char]0x60e0 + [char]0x7801 + [char]0x20 + "xk808" + [char]0x20 + [char]0x4eab + [char]0x53d7 + [char]0x38 + [char]0x6298 + [char]0x4f18 + [char]0x60e0

# "知识库" -> [char]0x77e5 + [char]0x8bc6 + [char]0x5e93
$titleSuffix = " - TiZi Top" + [char]0x77e5 + [char]0x8bc6 + [char]0x5e93

$btnTemplateStart = @"

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
    <a href="{LINK}" target="_blank" style="background: linear-gradient(135deg, #10b981, #059669); color: #ffffff; padding: 18px 50px; font-size: 1.3rem; border-radius: 50px; text-decoration: none; font-weight: bold; box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4); display: inline-block; transition: all 0.3s ease;">
"@

$btnTemplateEnd = @"
    </a>
</div>
"@

foreach ($item in $data) {
    $filePath = Join-Path ".\articles" $item.file
    if (-not (Test-Path $filePath)) {
        Write-Host "File not found: $filePath"
        continue
    }
    
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $affName = $item.name
    $affLink = $item.link
    
    # 1. Replace title (safely matching corrupted title structures like鐭ヨ瘑搴?/title> or missing < in closing tag)
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?i)<title>.*?(?:</title>|鐭ヨ瘑搴\?/title>|/title>)', "<title>$($item.title)$titleSuffix</title>")
    
    # 2. Replace meta description
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?i)<meta\s+name="description"\s+content="[^"]*"', "<meta name=`"description`" content=`"$($item.desc)`"")
    
    # 3. Replace breadcrumb
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)<span class="current" style="color: #94a3b8;">.*?</span>', "<span class=`"current`" style=`"color: #94a3b8;`">$($item.breadcrumb)</span>")
    
    # 4. Replace H1 title
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)<h1 class="article-title"[^>]*>.*?</h1>', "<h1 class=`"article-title`" style=`"font-size: 2.4rem; color: #0f172a; margin: 0 0 20px 0; font-weight: 800; line-height: 1.3;`">$($item.h1)</h1>")
    
    # 5. Replace intro
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)<div class="article-intro">.*?</div>', "<div class=`"article-intro`">$($item.intro)</div>")
    
    # 6. Replace body between articleBody and INJECTED_SEO_START
    $bodyStartTag = '<div class="article-body" id="articleBody">'
    $seoStartTag = '<!-- INJECTED_SEO_START -->'
    
    $startIndex = $content.IndexOf($bodyStartTag)
    $endIndex = $content.IndexOf($seoStartTag)
    
    if ($startIndex -ge 0 -and $endIndex -gt $startIndex) {
        $before = $content.Substring(0, $startIndex + $bodyStartTag.Length)
        $after = $content.Substring($endIndex)
        
        $originalBody = $content.Substring($startIndex + $bodyStartTag.Length, $endIndex - ($startIndex + $bodyStartTag.Length))
        
        # Extract logo img container
        [regex]$logoRegex = '(?s)<div style="text-align: center; margin: 40px 0 30px 0;">.*?</div>'
        $logoMatch = $logoRegex.Match($originalBody)
        $logoHtml = ""
        if ($logoMatch.Success) {
            $logoHtml = $logoMatch.Value
        }
        
        # Assemble item body directly from JSON
        $itemBody = $item.body
        
        $newBodyContent = "`r`n" + $logoHtml + "`r`n" + $itemBody + "`r`n"
        $content = $before + $newBodyContent + $after
        
        [System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Rewrote $filePath successfully!"
    } else {
        Write-Host "Warning: Could not find body boundaries in $filePath"
    }
}
