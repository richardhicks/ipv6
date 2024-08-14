<#

.SYNOPSIS
    Expands an IPv6 address to its full uncompressed 8-segment format.

.DESCRIPTION
    When working with IPv6 addresses, it is common to see them in a compressed format. However, it is a best practice to record and store IPv6 addresses in their fully expanded 8-segment format to ensure uniformity and consistency and to reduce parsing errors.

    This script expands an IPv6 address to its full 8-segment format. It accepts one or more IPv6 addresses as input and returns the fully expanded address.

.PARAMETER Ipv6Address
    The IPv6 address to expand.

.INPUTS
    String[]

.OUTPUTS
    PSCustomObject

.EXAMPLE
    .\Expand-Ipv6Address.ps1 -Ipv6Address '2001:db8::1'

    Expands the specified IPv6 address to its full 8-segment format. In this example the output would be '2001:0db8:0000:0000:0000:0000:0000:0001'.

.LINK
    https://github.com/richardhicks/ipv6/blob/main/Expand-Ipv6Address.ps1

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

    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'IPv6 address to expand.')]
    [string[]]$Ipv6Address

)

Process {

    ForEach ($Address in $Ipv6Address) {

        # Validate IPv6 address
        Try {

            [System.Net.IPAddress]::Parse($Address) | Out-Null

        }

        Catch {

            Write-Warning 'Invalid IPv6 address format.'
            Return

        }

        # Split the input IPv6 address by colons
        $Segments = $Address -Split ':'

        # Check if the address contains zero compression (::)
        If ($Address -match "::") {

            # Calculate the number of missing segments to expand
            $MissingSegmentsCount = 8 - ($Segments | Where-Object { $_ -ne '' }).Count

            # Initialize an empty array to store expanded segments
            $ExpandedSegments = @()

            # Flag to track if zero compression was expanded
            $ZeroCompressionExpanded = $false

            ForEach ($Segment In $Segments) {

                If ($Segment -eq '') {

                    # If zero compression is not expanded yet, expand it now
                    If (-not $ZeroCompressionExpanded) {

                        # Expand missing segments with zeros
                        1..$MissingSegmentsCount | ForEach-Object { $ExpandedSegments += '0000' }
                        $ZeroCompressionExpanded = $true

                    }

                }

                Else {

                    # Convert the hexadecimal segment to a full 4-character length
                    $ExpandedSegments += $Segment.PadLeft(4, '0')

                }

            }

            # Handle the case where there is a trailing `::` with no segments after it
            If (-not $ZeroCompressionExpanded) {

                1..$MissingSegmentsCount | ForEach-Object { $ExpandedSegments += '0000' }

            }

            # Join the expanded segments with colons to form the fully expanded IPv6 address
            $ExpandedSegments = $ExpandedSegments -join ':'

            # Output the fully expanded IPv6 address as an object
            [PSCustomObject]@{

                IPv6Address              = $Address
                FullyExpandedIPv6Address = $ExpandedSegments.ToLower()

            }

        }

        Else {

            # No zero compression, so just pad each segment to 4 characters
            $ExpandedSegments = $Segments | ForEach-Object { $_.PadLeft(4, '0') }
            $ExpandedSegments = $ExpandedSegments -join ':'

            [PSCustomObject]@{

                IPv6Address              = $Address
                FullyExpandedIPv6Address = $ExpandedSegments.ToLower()

            }

        }

    }

}
