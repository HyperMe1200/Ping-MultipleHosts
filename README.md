# Ping-MultipleHosts
.Examples

$Ping = Ping-MultipleHosts -StartAddress 172.16.10.1 -EndAddress 172.16.11.254

Ping-MultipleHosts dc06,dc01 -DontFragment -BufferSize 1400 -TimeOut 1000

$Servers = Get-ADComputer -Filter {operatingsystem -like 'windows server*'} | select -ExpandProperty name
Ping-MultipleHosts -HostName $servers

Get-ADComputer -Filter {operatingsystem -like 'windows server*'} | select -ExpandProperty name  | Ping-MultipleHosts

'dc01', 'dc02', 'srv01', '172.16.11.7' | Ping-MultipleHosts


 

