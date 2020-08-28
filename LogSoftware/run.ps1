using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

#Creating an object that contains all of the needed information
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
    # Gathering the body of the request and converting it from JSON to a PSCustomObject
    StorageTableProperties     = $(
        $obj = $Request.Body | ConvertFrom-Json
        $Hash = [ordered]@{}
        $obj.psobject.properties | ForEach-Object { $Hash[$_.Name] = $_.Value }
        $Hash
    )
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
            Body = [string]"Successfully Logged Install"
        }
    }
    { [string]::IsNullOrEmpty($_.Results) } {
        $status = @{
            HttpStatusCode = [string]"BadRequest"
            Body = [string]"Failed to process request"
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

$ProcessingObject += @{Status = $status}

Export-Clixml -InputObject $ProcessingObject -Force .\ProcessingObject.cli.xml
