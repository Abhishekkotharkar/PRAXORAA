param(
  [string]$Domain = "praxoraa.ai",
  [string]$GitHubHost = "Abhishekkotharkar.github.io"
)

$Domain = $Domain.Trim().TrimEnd('.')
$Subdomain = "www.$Domain"

Write-Output "Checking $Domain"
Write-Output ""

$apexRecords = @(Resolve-DnsName $Domain -Type A -ErrorAction SilentlyContinue)
$wwwRecords = @(Resolve-DnsName $Subdomain -Type CNAME -ErrorAction SilentlyContinue)

if ($apexRecords.Count -eq 0) {
  Write-Output "FAIL: No A record found for $Domain"
} else {
  Write-Output "A records for ${Domain}:"
  $apexRecords | Select-Object -ExpandProperty IPAddress | ForEach-Object { Write-Output "  $_" }
}

if ($wwwRecords.Count -eq 0) {
  Write-Output "FAIL: No CNAME record found for $Subdomain"
} else {
  $targets = @($wwwRecords | Select-Object -ExpandProperty NameHost)
  Write-Output "CNAME for ${Subdomain}: $($targets -join ', ')"
  if ($targets -notcontains $GitHubHost) {
    Write-Output "WARN: Expected $GitHubHost as the CNAME target"
  }
}

Write-Output ""
Write-Output "Expected apex A records: 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153"
Write-Output "Expected www CNAME target: $GitHubHost"
