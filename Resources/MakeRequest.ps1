param (
    $SoftwareVersion = "SoftwareVersion",
    $SoftwareName = "SoftwareName"
    )

# Hardcoded values:
    $URI = "https://softwareloggingapp.azurewebsites.net/api/SoftwareLoggingFunction"
    #$URI = "https://logsoftwaretest.azurewebsites.net/api/LogSoftware"
    #$URI = "http://localhost:7071/api/LogSoftware"
function Send-SoftwarePOSTRequest {
    <#
    .SYNOPSIS
    Send Software information back to Azure for tracking
    
    .DESCRIPTION
    Generates a REST POST request to Azure with the relevant software and hardware information for tracking the installations of software
    
    .PARAMETER URI
    The URI that the POST request should be made
    
    .PARAMETER SoftwareVersion
    The Version number of the software being installed
    
    .PARAMETER SoftwareName
    The Name of the software being installed
    
    .EXAMPLE
    Send-SoftwarePOSTRequest -URI "https://someaddress.azurewebsites.net/api/endpoint" -SoftwareVersion "9.3" -SoftwareName "SuperExpensiveSoftware"
    
    .NOTES
    This gathers information both about the computer and the user that ran the install
    #>
    [CmdletBinding()]
    param (
        $URI,
        $SoftwareVersion,
        $SoftwareName
    )
    #Gather all of the computer info we need
    $ComputerInfo = Get-ComputerInfo

    #Loading the needed functions...
    function Set-OutputFormat {
        [CmdletBinding()]
        param (
            [Parameter()]
            $ObjectInput
        )
        #If the object is empty, return a blank string
        if ([string]::IsNullOrEmpty($ObjectInput)) { [string]$output = "" }
        #Otherwise, just output the object as a string
        Else { [string]$output = $ObjectInput }
        #Return the Output
        return $output
    }

    #Setting a custom object for data formatting
    $obj = [PSCustomObject]@{
        #Be aware that the incorrect spelling of "seral" is intentional, that is the way that the attribute is spelled from "get-ComputerInfo"
        BiosSerial      = Set-OutputFormat -ObjectInput $ComputerInfo.BiosSeralNumber
        ComputerModel   = Set-OutputFormat -ObjectInput $ComputerInfo.CsSystemFamily
        ComputerName    = Set-OutputFormat -ObjectInput $ComputerInfo.csname
        SoftwareName    = Set-OutputFormat -ObjectInput $SoftwareName
        SoftwareVersion = Set-OutputFormat -ObjectInput $SoftwareVersion
        UserName        = Set-OutputFormat -ObjectInput $ComputerInfo.CsUserName
        WindowsBuild    = Set-OutputFormat -ObjectInput $ComputerInfo.WindowsBuildLabEx
        WindowsVersion  = Set-OutputFormat -ObjectInput $ComputerInfo.WindowsProductName
    }

    #Convert the PSCustomObject back to a hashtable & make a generic hash:
    $Hash = [ordered]@{}
    #Grab all the properties and for each of them add the name and value to the hash
    $obj.psobject.properties | ForEach-Object { $Hash[$_.Name] = $_.Value }

    #Convert it to json
    $JSON = $Hash | ConvertTo-Json

    #Make the webrequest:
    Invoke-WebRequest -Uri $URI -Body $JSON -Method Post
}

<#
    --------------------
    --------------------
    Running the function
    --------------------
    --------------------
#>

Send-SoftwarePOSTRequest -URI $URI -SoftwareVersion $SoftwareVersion -SoftwareName $SoftwareName
