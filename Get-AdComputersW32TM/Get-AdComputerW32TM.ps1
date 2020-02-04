function Get-AdComputerW32TM {
<#
Description
-----------
Проверка доменных компьютеров на работу службы времени, источника времени, расхождение с источником.
Get-AdComputerW32TM | Export-Csv -Path C:\Distrib\compW32tm.csv -Encoding Unicode
-----------
#>


$computers = Get-ADComputer -Filter 'enabled -eq "true"' -Properties Operatingsystem,OperatingSystemVersion,OperatingSystemServicePack,IPv4Address |
Select Name,Operatingsystem,OperatingSystemVersion,OperatingSystemServicePack,IPv4Address,testConnection,statusServiceW32TM,sourceW32TM,precisionW32TM

$computers |% {
    if (Test-Connection $_.name -Count 1 -Quiet) {
		$_.testConnection = "true"
		$_.statusServiceW32TM = (Get-Service -Name W32Time -ComputerName "$($_.Name)" -ErrorAction Ignore).Status
		if ($_.statusServiceW32TM -eq "Running") {
			$w32tm = w32tm /query /computer:"$($_.Name)" /status
			$_.sourceW32TM = $w32tm[-3].Trim() -replace "^.*\s"			
			$_.precisionW32TM = $w32tm[2] -replace "^.*\:\s" -replace "\s\(.*$"
		}
		else {
			$_.sourceW32TM = "false"
			$_.precisionW32TM = "false"
		}
	}
	else {
		$_.testConnection = "false"
		$_.statusServiceW32TM = "false"
		$_.sourceW32TM = "false"
		$_.precisionW32TM = "false"
	}
}

$computers

}
