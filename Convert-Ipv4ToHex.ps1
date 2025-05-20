<#

.SYNOPSIS
    Converts an IPv4 address to hexadecimal format.

.DESCRIPTION
    IPv4 addresses are commonly represented in decimal format. However, it is sometimes necessary to convert an IPv4 address to hexadecimal format, for example when working with IPv6 mapped or NAT64 addresses.

    This script converts an IPv4 address to hexadecimal format. The script accepts one or more IPv4 addresses as input and returns the hexadecimal representation of the address. The script performs zero compression by removing leading zeros and compressing consecutive zeros in the output.

.PARAMETER Ipv4Address
    The IPv4 address to convert to hexadecimal format.

.INPUTS
    String[]

.OUTPUTS
    PSCustomObject

.EXAMPLE
    .\Convert-Ipv4ToHex.ps1 -Ipv4Address 172.16.21.12

    Converts the specified IPv4 address to hexadecimal format.

.LINK
    https://github.com/richardhicks/ipv6/blob/main/Convert-Ipv4ToHex.ps1

.LINK
    https://www.richardhicks.com/

.NOTES
    Version:        2.0
    Creation Date:  August 14, 2024
    Last Updated:   May 20, 2025
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Enter an IPv4 address (e.g., 172.16.21.12).')]
    [string[]]$IPv4Address

)

Process {

    ForEach ($Address in $IPv4Address) {

        # Validate IPv4 address
        Try {

            [void]([System.Net.IPAddress]::Parse($Address))

        }

        Catch {

            Write-Warning "Invalid IPv4 address format: '$Address'."
            Continue

        }

        # Split into octets
        $Octets = $Address -split '\.' | ForEach-Object { [int]$_ }

        # Combine first two and last two octets into 16-bit values
        $FirstPair = ($Octets[0] -shl 8) + $Octets[1]
        $SecondPair = ($Octets[2] -shl 8) + $Octets[3]

        # Convert to hexadecimal without leading zeros
        $HexFirst = [Convert]::ToString($FirstPair, 16)
        $HexSecond = [Convert]::ToString($SecondPair, 16)

        # Combine into xxxx:xxxx format
        $Result = "$HexFirst`:$HexSecond"

        # Output as custom object
        [PSCustomObject]@{

            IPv4 = $Address
            Hex  = $Result.ToLower()

        }

    }

}
