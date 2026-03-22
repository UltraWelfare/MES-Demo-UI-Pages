$indexPath = Join-Path $PSScriptRoot "index.html"

if (-not (Test-Path $indexPath)) {
    Write-Error "index.html was not found at: $indexPath"
    exit 1
}

$content = Get-Content $indexPath -Raw

$scriptToInject = @'
    <script type="text/javascript">
      // Single Page Apps for GitHub Pages
      // MIT License
      // https://github.com/rafgraph/spa-github-pages
      // This script checks to see if a redirect is present in the query string,
      // converts it back into the correct url and adds it to the
      // browser's history using window.history.replaceState(...),
      // which won't cause the browser to attempt to load the new url.
      // When the single page app is loaded further down in this file,
      // the correct url will be waiting in the browser's history for
      // the single page app to route accordingly.
      (function(l) {
        if (l.search[1] === '/' ) {
          var decoded = l.search.slice(1).split('&').map(function(s) { 
            return s.replace(/~and~/g, '&')
          }).join('?');
          window.history.replaceState(null, null,
              l.pathname.slice(0, -1) + decoded + l.hash
          );
        }
      }(window.location))
    </script>
'@

if ($content -match [regex]::Escape($scriptToInject.Trim())) {
    Write-Host "Script is already present in index.html"
    exit 0
}

if ($content -match '</head>') {
    $updatedContent = $content -replace '</head>', "$scriptToInject`r`n</head>"
    Set-Content -Path $indexPath -Value $updatedContent -Encoding UTF8
    Write-Host "Script injected successfully into index.html"
}
else {
    Write-Error "Could not find </head> in index.html"
    exit 1
}