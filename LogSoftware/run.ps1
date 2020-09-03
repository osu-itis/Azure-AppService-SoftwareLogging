using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Making sure that all of the needed variables are available
if ([string]::IsNullOrEmpty($env:AzureWebJobsStorage)) { Throw 'Could not find $env:AzureWebJobsStorage' }

# Creating an object that contains all of the needed information
$ProcessingObject = [hashtable]@{
    # Gathering the body of the request and converting it from JSON to a PSCustomObject
    StorageTableProperties     = $(
        $obj = $Request.Body | ConvertFrom-Json
        $Hash = [ordered]@{}
        $obj.psobject.properties | ForEach-Object { $Hash[$_.Name] = $_.Value }
        # Adding the needed partition key and row key
        $Hash.Add("PartitionKey",$(get-date -Format yyyy))
        $Hash.Add("RowKey", $(new-guid | Select-Object -ExpandProperty guid))
        $Hash
    )
}

# If the processing object does NOT contain the software name, break.
if (! $ProcessingObject.StorageTableProperties.Contains("softwarename") ) {
    break
}

# Load the functions
. ".\LogSoftware\GenerateReponseObject.ps1"

# Attempt to post to the table and collect the results
try {
    # Pushing to the table
    Push-OutputBinding -Name "outputTable" -Value $ProcessingObject.StorageTableProperties
    # Setting the status
    $status = @{
        HttpStatusCode = [string]"OK"
        Body           = [string]"Successfully Logged Install"
    }
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    GenerateReponseObject @Status
}
catch {
    Break
}
