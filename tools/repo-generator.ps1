param(
    [int]$Count = 25,
    [string]$Prefix = "mini-project",
    [ValidateSet("public","private")]
    [string]$Visibility = "public"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) belum terpasang." -ForegroundColor Yellow
    Write-Host "Install: winget install --id GitHub.cli"
    exit 1
}

try {
    gh auth status | Out-Null
} catch {
    Write-Host "Login GitHub dulu dengan: gh auth login" -ForegroundColor Yellow
    exit 1
}

$owner = (gh api user --jq .login).Trim()
Write-Host "Akun GitHub: $owner"
Write-Host "Akan membuat $Count repository $Visibility..."

for ($i = 1; $i -le $Count; $i++) {
    $suffix = $i.ToString("000")
    $name = "$Prefix-$suffix"
    $full = "$owner/$name"

    $exists = $false
    try {
        gh repo view $full --json name 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { $exists = $true }
    } catch {}

    if ($exists) {
        Write-Host "SKIP: $full sudah ada"
        continue
    }

    Write-Host "CREATE: $full"
    gh repo create $full --$Visibility --add-readme --description "Small experimental repository #$suffix"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Gagal membuat $full" -ForegroundColor Red
    }
}

Write-Host "Selesai. Cek: https://github.com/$owner?tab=repositories" -ForegroundColor Green
