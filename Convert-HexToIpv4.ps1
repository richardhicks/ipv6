<#

.SYNOPSIS
    Converts a hexadecimal IP address to IPv4 format.

.DESCRIPTION
    IPv4 addresses are commonly represented in decimal format. It is sometimes necessary to convert a hexadecimal address to IPv4 format, for example when working with IPv6 mapped or NAT64 addresses.

    This script converts a hexadecimal address to IPv4 format. The script accepts one or more hexadecimal addresses as input and returns the IPv4 representation of the address. The script performs zero compression by removing leading zeros and compressing consecutive zeros in the output.

.PARAMETER HexAddress
    The hexadecimal address to convert to IPv4 format.

.INPUTS
    String[]

.OUTPUTS
    PSCustomObject

.EXAMPLE
    .\Convert-HexToIpv4.ps1 -HexAddress ac10:150c

    Converts the specified hexadecimal address to IPv4 format.

.LINK
    https://github.com/richardhicks/ipv6/blob/main/Convert-HexToIpv4.ps1

.LINK
    https://www.richardhicks.com/

.NOTES
    Version:        1.0
    Creation Date:  May 20, 2025
    Last Updated:   May 20, 2025
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Enter a hexadecimal IP address (e.g., ac10:150c).')]
    [string[]]$HexAddress

)

Process {

    ForEach ($Hex in $HexAddress) {

        # Validate hexadecimal input format
        If ($Hex -notmatch '^[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}$') {

            Write-Warning "Invalid hexadecimal format for '$Hex'. Use format like 'ac10:15c'."
            Continue

        }

        Try {

            # Split the hex address into two parts
            $Hextet = $Hex -split ':'

            # Convert each part to two octets
            $Octets = @()
            ForEach ($Octet in $Hextet) {

                # Convert hex to decimal
                $Decimal = [Convert]::ToInt32($Octet, 16)

                # Split into two octets (high and low bytes)
                $Octets += ($Decimal -shr 8), ($Decimal -band 0xFF)

            }

            # Validate octet values (0-255)
            If ($Octets | Where-Object { $_ -lt 0 -or $_ -gt 255 }) {

                Write-Warning "Invalid octet value in '$Hex'. Each octet must be 0-255."
                Continue

            }

            # Format as IPv4 address
            $IPv4 = $Octets -join '.'

            # Output as custom object
            [PSCustomObject]@{

                Hex   = $Hex.ToLower()
                IPv4  = $IPv4

            }

        }

        Catch {

            Write-Warning "Error processing '$Hex': $_"

        }

    }

}
