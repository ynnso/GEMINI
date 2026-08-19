$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8791/")
$listener.Start()
$root = "C:\Claude"
Write-Host "Serving $root on http://localhost:8791/"
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $req = $context.Request
    $res = $context.Response
    $path = $req.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($path)) { $path = "PriceAppV10.html" }
    $filePath = Join-Path $root $path
    if (Test-Path $filePath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        if ($filePath -like "*.html") { $res.ContentType = "text/html" }
        elseif ($filePath -like "*.js") { $res.ContentType = "application/javascript" }
        elseif ($filePath -like "*.css") { $res.ContentType = "text/css" }
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.Close()
}
