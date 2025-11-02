# Read file with UTF8 encoding
$filePath = "lib\view\on_boarding\started_view\goal_selection.dart"
$content = Get-Content $filePath -Encoding UTF8 -Raw

# Replace broken emojis with correct ones
$content = $content -replace "icon: 'ðŸ"¥'", "icon: '[object Object]content -replace "icon: 'ðŸ½ï¸'", "icon: '[object Object] = $content -replace "icon: 'âš–ï¸'", "icon: '⚖️'"
$content = $content -replace "icon: 'ðŸ'ª'", "icon: '[object Object] with UTF8 encoding (with BOM to ensure proper encoding)
$utf8WithBom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($filePath, $content, $utf8WithBom)

Write-Host "Emojis fixed successfully!" -ForegroundColor Green

