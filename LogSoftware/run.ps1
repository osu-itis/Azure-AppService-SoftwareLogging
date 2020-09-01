using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Export-Clixml -InputObject $Request -Path .\notes\Request.cli.xml

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Making sure that all of the needed variables are available
if ([string]::IsNullOrEmpty($env:AzureWebJobsStorage)) { Throw 'Could not find $env:AzureWebJobsStorage' }
if ([string]::IsNullOrEmpty($env:TenantID)) { Throw 'Could not find $env:TenantID' }
if ([string]::IsNullOrEmpty($env:ServicePrincipal)) { Throw 'Could not find $env:ServicePrincipal' }
if ([string]::IsNullOrEmpty($env:ServicePrincipalSecret)) { Throw 'Could not find $env:ServicePrincipalSecret' }
if ([string]::IsNullOrEmpty($env:StorageAccountName)) { Throw 'Could not find $env:StorageAccountName' }
if ([string]::IsNullOrEmpty($env:StorageAccountKey)) { Throw 'Could not find $env:StorageAccountKey' }
if ([string]::IsNullOrEmpty($env:AzureTableName)) { Throw 'Could not find $env:AzureTableName' }
if ([string]::IsNullOrEmpty($env:PartitionKey)) { Throw 'Could not find $env:PartitionKey' }

# Creating an object that contains all of the needed information
$ProcessingObject = [hashtable]@{   
    # Gathering the Tenant ID
    Tenant                     = $env:TenantID
    # Gathering the credentials for the Service Principal account
    ServicePrincipalCredential = New-Object System.Management.Automation.PSCredential ("$ENV:ServicePrincipal", $(ConvertTo-SecureString "$($ENV:ServicePrincipalSecret)" -AsPlainText -Force))
    # Gathering all of the needed storage settings
    StorageAccountName         = $env:StorageAccountName
    StorageAccountKey          = $env:StorageAccountKey
    StorageTableName           = $env:AzureTableName
    PartitionKey               = $env:PartitionKey
    # AzureWebJobsStorage        = [hashtable]$(
    #     # Creating an empty hashtable
    #     $temp = [hashtable]@{}
    #     $(
    #         # Looping through all of the parts in the variable
    #         foreach ($item in $($env:AzureWebJobsStorage.split(";"))) {
    #             # Setting the name and value
    #             $tempname = $(($item -split "=", 2)[0])
    #             $tempvalue = $(($item -split "=", 2)[1])
    
    #             # Adding them to the hashtable
    #             $temp.Add($tempname, $tempvalue)
    #         }
    #     )
    #     #Outputing the results
    #     $temp
    # )
    # Gathering the body of the request and converting it from JSON to a PSCustomObject
    StorageTableProperties     = $(
        $obj = $Request.Body | ConvertFrom-Json
        $Hash = [ordered]@{}
        $obj.psobject.properties | ForEach-Object { $Hash[$_.Name] = $_.Value }
        $Hash
    )
}

# If the processing object does NOT contain the software name, break.
if (! $ProcessingObject.StorageTableProperties.Contains("softwarename") ) {
    break
}

# Load the functions
. ".\LogSoftware\New-PostToTable.ps1"
. ".\LogSoftware\GenerateReponseObject.ps1"

# Attempt to post to the table and collect the results
try {
    $temp = @{Results = $( New-PostToTable @ProcessingObject ) }
}
catch {
    $temp = @{Results = $null }    
}

# Add the results to the Main Object
$ProcessingObject += $temp

# Determine the final status of the function
switch ($ProcessingObject) {
    { $_.Results.httpstatuscode -eq 204 } {
        $status = @{
            HttpStatusCode = [string]"OK"
            Body           = [string]"Successfully Logged Install"
        }
    }
    { [string]::IsNullOrEmpty($_.Results) } {
        $status = @{
            HttpStatusCode = [string]"BadRequest"
            Body           = [string]"Failed to process request"
        }
    }
    Default {
        $status = @{
            HttpStatusCode = [string]"InternalServerError"
        }
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
GenerateReponseObject @Status

Export-Clixml -InputObject $ProcessingObject -Path .\notes\ProcessingObject.cli.xml