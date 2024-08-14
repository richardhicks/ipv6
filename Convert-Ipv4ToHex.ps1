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
    .\Convert-Ipv4ToHex.ps1 -Ipv4Address

    Converts the specified IPv4 address to hexadecimal format.

.LINK
    https://github.com/richardhicks/ipv6/blob/main/Convert-Ipv4ToHex.ps1

.LINK
    https://www.richardhicks.com/

.NOTES
    Version:        1.0.1
    Creation Date:  August 14, 2024
    Last Updated:   August 14, 2024
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Enter an IPv4 address.')]
    [string[]]$IPv4Address

)

Process {

    ForEach ($Address in $IPv4Address) {

        # Validate IPv4 address
        Try {

            # Attempt to parse the input IPv4 address
            [System.Net.IPAddress]::Parse($Address) | Out-Null

        }

        Catch {

            # If the input IPv4 address is invalid, display a warning message and exit
            Write-Warning 'Invalid IPv4 address format.'
            Return

        }

        # Convert IPv4 address to hexadecimal
        $Hex = $Address -Split '\.' | ForEach-Object { [Convert]::ToString($_, 16) }

        # Output the hexadecimal value in the format xx:xx
        $Result = "{0}{1}:{2}{3}" -f $Hex[0], $Hex[1], $Hex[2], $Hex[3]

        # Perform zero compression
        $Result = $Result -Replace '0+', '0' -Replace '(?<=:)(0+)', ''

        # Return the hexadecimal value as a custom object
        [PSCustomObject]@{

            IPv4 = $Address
            Hex = $Result.ToLower()

        }

    }

}
