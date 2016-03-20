function Ping-MultipleHosts {
    
    [cmdletbinding()]
    param (
        
        [parameter (Position = 0, 
                    Mandatory = $True, 
                    ParameterSetName = 'Comp', 
                    ValueFromPipeline=$True)]
        [Alias ('ComputerName','Name')]
        [string[]]$HostName,

        [parameter (Mandatory = $True, 
                    ParameterSetName = 'Range')]
        [IPAddress]$StartAddress,

        [parameter (Mandatory = $True, 
                    ParameterSetName = 'Range')]
        [IPAddress]$EndAddress,

        [int]$Timeout = 2000,

        [switch]$DontFragment,

        [int]$BufferSize = 32
    )

    begin {
        
        $global:PingRezult = @()
        $InputObjects = @()

        if ($StartAddress) {

            $IPArray = @()

            $Start = $StartAddress.GetAddressBytes()
            [Array]::Reverse($Start)
            $Start = ([IPAddress]($Start -join '.')).Address

            $End = $EndAddress.GetAddressBytes()
            [Array]::Reverse($End)
            $End = ([IPAddress]($End -join '.')).Address

            for ($i = $Start; $i -le $End; $i++) {
                $IP = ([IPAddress]$i).GetAddressBytes()
                [Array]::Reverse($IP)
                $IPArray += $IP -join '.'  
            }

            $Hostname = $IPArray            
        }
    
    }

    process {

        foreach ($Host_ in $HostName) {
            $InputObjects += $Host_
        }
    }

    end {

        $DF = New-Object Net.NetworkInformation.PingOptions
            if (!$DontFragment) {      
                $DF.DontFragment = $false
            }
            else {
                $DF.DontFragment = $true    
            }

        $InputObjects | foreach {

            $Ping = New-Object System.Net.NetworkInformation.Ping

            Register-ObjectEvent $Ping PingCompleted -Action {
                $global:PingRezult += [pscustomobject][ordered]@{
                    Host = $event.SourceArgs[1].UserState
                    Status = $event.SourceArgs[1].Reply.Status
                    Time = $event.SourceArgs[1].Reply.RoundtripTime
                    Address = $event.SourceArgs[1].Reply.Address
                }   
            } | Out-Null

            $Ping.SendAsync($_, $Timeout, (New-Object Byte[] $BufferSize), $DF, $_) | Out-Null
        }

        while ($global:PingRezult.count -lt $InputObjects.Count) {
            Start-Sleep -Milliseconds 10
        }

        return $global:PingRezult
    
    }
}