# Export the SiBekas leaf mark to launcher sizes using Windows drawing APIs.
# Geometry matches assets/branding/sibekas.svg; no third-party artwork is used.
Add-Type -AssemblyName System.Drawing
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Export-SiBekasIcon([string] $destination, [int] $pixels) {
    $bitmap = New-Object System.Drawing.Bitmap($pixels, $pixels)
    $canvas = [System.Drawing.Graphics]::FromImage($bitmap)
    $canvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $canvas.Clear([System.Drawing.ColorTranslator]::FromHtml('#19532b'))
    $factor = [single]($pixels / 108.0)
    $canvas.ScaleTransform($factor, $factor)
    $leaf = New-Object System.Drawing.Drawing2D.GraphicsPath
    $leaf.AddBezier(28, 68, 22, 42, 42, 27, 79, 27)
    $leaf.AddBezier(79, 27, 79, 65, 61, 83, 39, 73)
    $leaf.AddLine(39, 73, 28, 68)
    $leaf.CloseFigure()
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#d0e08b'))
    $canvas.FillPath($brush, $leaf)
    $pen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#19532b'), 5)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $canvas.DrawLine($pen, 28, 82, 66, 43)
    $canvas.DrawLine($pen, 44, 65, 43, 48)
    $canvas.DrawLine($pen, 55, 54, 69, 56)
    $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
    $pen.Dispose(); $brush.Dispose(); $leaf.Dispose(); $canvas.Dispose(); $bitmap.Dispose()
}

$iconFolder = Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$manifest = Get-Content -LiteralPath (Join-Path $iconFolder 'Contents.json') -Raw | ConvertFrom-Json
foreach ($icon in $manifest.images) {
    $points = [double]($icon.size.Split('x')[0])
    $scale = [double]($icon.scale.TrimEnd('x'))
    Export-SiBekasIcon (Join-Path $iconFolder $icon.filename) ([int]($points * $scale))
}
$androidSizes = @{mdpi=48; hdpi=72; xhdpi=96; xxhdpi=144; xxxhdpi=192}
foreach ($density in $androidSizes.Keys) {
    Export-SiBekasIcon (Join-Path $projectRoot "android/app/src/main/res/mipmap-$density/ic_launcher.png") $androidSizes[$density]
}
Write-Output 'Exported Android and iOS SiBekas launcher icons.'
