<#

.SYNOPSIS
    Generates one or more random IPv6 addresses.

.PARAMETER Ipv6Prefix
    The IPv6 prefix to use when generating IPv6 addresses. The default value is the documentation prefix 2001:db8::.

.PARAMETER Count
    The number of IPv6 addresses to generate. The default value is 1.

.EXAMPLE
    .\Create-Ipv6Address.ps1

    Generates a single random IPv6 address using the default prefix 2001:db8::.

.EXAMPLE
    .\Create-Ipv6Address.ps1 -Ipv6Prefix '2001:db8:a:b::'

    Generates a single random IPv6 address using the specified prefix 2001:db8:a:b::.

.EXAMPLE
    .\Create-Ipv6Address.ps1 -Count 5

    Generates five random IPv6 addresses using the default prefix 2001:db8::.

.DESCRIPTION
    When working with IPv6, it is often necessary to generate random addresses for testing or other purposes. This script generates one or more random IPv6 addresses using the specified or default prefix.

.LINK
    https://github.com/richardhicks/ipv6/blob/main/Create-Ipv6Address.ps1

.LINK
    https://www.richardhicks.com/

.NOTES
    Version:        1.0
    Creation Date:  August 14, 2024
    Last Updated:   August 14, 2024
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

    [Alias('Prefix')]
    [string]$Ipv6Prefix = '2001:db8::',
    [int]$Count = 1

)

# Ensure the Ipv6 prefix specified is valid
If ($Ipv6Prefix -notmatch '::$') {

    Write-Warning 'Invalid IPv6 prefix.'
    Return

}

Try {

    [System.Net.IPAddress]::Parse($Ipv6Prefix) | Out-Null
    Write-Verbose "$Ipv6Prefix is a valid IPv6 prefix."

}

Catch {

    Write-Warning 'Invalid IPv6 prefix.'
    Return

}

# Remove any trailing colons from the Ipv6 prefix if it contains four hextets
$Hextets = ($Ipv6Prefix.TrimEnd(':') -split ':') | Where-Object { $_ -ne '' } | Measure-Object | Select-Object -ExpandProperty Count

If ($Hextets -eq 4) {

    $Ipv6Prefix = $Ipv6Prefix -replace ':(?!.*:)', ''

}

# Create an array to store generated IPv6 addresses
$Ipv6Addresses = @()

# Generate the specified number of IPv6 addresses
For ($i = 0; $i -lt $Count; $i++) {

    # Create a random Ipv6 Interface Identifier
    $Ipv6Iid = ( -Join ((48..57) + (65..70) | ForEach-Object { [Char]$_ } | Get-Random -Count 16)).ToLower()
    $Ipv6Iid = $Ipv6Iid -Replace '(.{4})(?!$)', '$1:'

    # Build Ipv6 address
    $Ipv6Address = $Ipv6Prefix.ToLower() + $Ipv6Iid

    # Add to the output array
    $Ipv6Addresses += [PSCustomObject]@{

        Ipv6Address = $Ipv6Address

    }

}

# Output all generated IPv6 addresses
Return $Ipv6Addresses
