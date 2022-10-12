[CmdletBinding()]
param(
[parameter(Mandatory=$true)]
[string[]]$ComputerName,
[parameter(Mandatory=$true)]
[int]$Port = 443,
[switch]$ExportToCSV
)
 
$Outarr = @()
foreach($Computer in $ComputerName) {
Write-Host "Working on retrieving cert for $Computer" -ForegroundColor Green
try {
$tcpsocket = New-Object Net.Sockets.TcpClient($Computer,$Port)
$tcpstream = $tcpsocket.GetStream()
$sslStream = New-Object System.Net.Security.SslStream($tcpstream,$false)
$sslStream.AuthenticateAsClient($computer)
$CertInfo = New-Object system.security.cryptography.x509certificates.x509certificate2($sslStream.RemoteCertificate)
$SubjectName = @{Name="SubjectName";Expression={$_.SubjectName.Name}}
$OutObj = $CertInfo | Select-Object FriendlyName,$SubjectName,HasPrivateKey,EnhancedKeyUsageList,DnsNameList,SerialNumber,
Thumbprint,NotAfter,NotBefore,@{Name='IssuerName';Expression = {$_.IssuerName.Name}}
if($ExportToCSV) {
$Outarr += $OutObj
} else {
$OutObj
}
 
} catch {
Write-Warning "Unable to get cert details for `"$Computer`". $_"
}
}
 
if($ExportToCSV) {
 
$Outarr | Export-Csv c:\certdetails.csv -NoTypeInformation
}