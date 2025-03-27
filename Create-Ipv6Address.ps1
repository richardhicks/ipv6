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
    Version:        1.1
    Creation Date:  August 14, 2024
    Last Updated:   March 26, 2025
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

# Ensure the IPv6 prefix ends with '::'
If ($Ipv6Prefix -notmatch '::$') {

    Write-Warning 'Invalid IPv6 prefix: must end with "::" to represent a /64.'
    Return

}

# Validate the prefix is a valid IPv6 address
Try {

    $Ip = [System.Net.IPAddress]::Parse($Ipv6Prefix)
    If (-not $Ip.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6) {

        Throw "Not an IPv6 address."

    }

    Write-Verbose "$Ipv6Prefix is a valid IPv6 prefix."

}

Catch {

    Write-Warning 'Invalid IPv6 prefix.'
    Return

}

# Count non-empty hextets (max 4 allowed for /64)
$Hextets = ($Ipv6Prefix.TrimEnd(':') -split ':') | Where-Object { $_ -ne '' }
If ($Hextets.Count -gt 4) {

    Write-Warning 'Invalid IPv6 prefix: more than 64 bits (more than 4 hextets) specified.'
    Return

}

# Ensure no trailing colon after adjustment
If ($Hextets.Count -eq 4) {

    $Ipv6Prefix = $Ipv6Prefix -replace ':(?!.*:)', ''

}

# Create array to store generated IPv6 addresses
$Ipv6Addresses = @()

# Generate the specified number of IPv6 addresses
For ($i = 0; $i -lt $Count; $i++) {

    # Generate 64-bit Interface Identifier (16 hex characters)
    $Ipv6Iid = ( -Join ((48..57) + (65..70) | ForEach-Object { [Char]$_ } | Get-Random -Count 16)).ToLower()
    $Ipv6Iid = $Ipv6Iid -Replace '(.{4})(?!$)', '$1:'

    # Combine prefix and IID
    $Ipv6Address = $Ipv6Prefix.ToLower() + $Ipv6Iid

    # Store in result array
    $Ipv6Addresses += [PSCustomObject]@{

        Ipv6Address = $Ipv6Address

    }

}

# Output all generated IPv6 addresses
Return $Ipv6Addresses