using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

#Grabbing needed account and key from the ENV
$StorageAccountName = $env:StorageAccountName
$StorageAccountKey = $env:StorageAccountKey

#Gathering the object from the request and converting it to a powershell object
$obj = $Request.Body | ConvertFrom-Json

#Convert the PSCustomObject back to a hashtable & make a generic hash:
$Hash = [ordered]@{}

#Grab all the properties and for each of them add the name and value to the hash
$obj.psobject.properties | ForEach-Object { $Hash[$_.Name] = $_.Value }

#Connecting to an AD service account (which auto-loads the "AzStorageTable" cmdlets, this is required to use this commands)
$ServicePrincipalAccount = New-Object System.Management.Automation.PSCredential ("$ENV:ServicePrincipal", $(ConvertTo-SecureString "$($ENV:ServicePrincipalSecret)" -AsPlainText -Force))
Connect-AzAccount -Tenant "ce6d05e1-3c5e-4d62-87a8-4c4a2713c113" -Credential $ServicePrincipalAccount -ServicePrincipal

#Now that everything is loaded, we can prepare the function
function New-PostToTable {
    <#
    .SYNOPSIS
    Posts data to Azure Storage Table
    
    .DESCRIPTION
    Posts data to Azure Storage Table
    
    .PARAMETER StorageAccountName
    The account name for the AZ Storage Table
    
    .PARAMETER StorageAccountKey
    The key for the AZ Storage Table
    
    .PARAMETER StorageTableName
    The Name of the Azure Storage Table
    
    .PARAMETER StorageTableProperties
    All Properties to be submitted (In hashtable format)
    
    .PARAMETER PartitionKey
    The Specific Partition Key for the dataset to be added to the Table
    
    .EXAMPLE
    New-PostToTable -StorageAccountName "TableAccount" -StorageAccountKey "<SOMEKEY==>"" -StorageTableName "tablename" -PartitionKey "PartitionKey1" -StorageTableProperties @{"Name"="Cool Dude";Status="Awesome"}
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]$StorageAccountName,
        [parameter(Mandatory = $true)]$StorageAccountKey,
        [parameter(Mandatory = $true)]$StorageTableName,
        [parameter(Mandatory = $true)]$StorageTableProperties,
        [parameter(Mandatory = $true)]$PartitionKey
    )

    begin {
        # #Import the needed modules
        # Import-Module Az.Accounts
        # Import-Module Az.Storage

        #Gather the AZ Storage Context which provides information about the account to be used
        $CTX = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

        #Using the context, get the storage table and gather the "CloudTable" properties
        $CloudTable = (Get-AzStorageTable -Name $StorageTableName -Context $CTX.Context).CloudTable
    }

    process {
        <#
            Generate a randomized GUID for the RowKey because we do not have a unique value to use (user & computer may have more than one different install, so each entry must be logged).
            Additionally we dont want to query the Data Table every time to calulate the number of rows as this will reduce the speed of the code.
            In the future if actual individual single use licence codes are used, we could use that as the RowKey.
        #>
        $rowkey = ([guid]::NewGuid().tostring())

        #Generate an object that contains all of the important data related to the Row that is about to be added to the table
        $RowToAdd = @{
            Table        = $cloudTable
            PartitionKey = $PartitionKey
            RowKey       = $rowkey
            Property     = $StorageTableProperties
        }

        #Using Splatting, add the table row with the included properties
        Add-AzTableRow @RowToAdd
    }

    end {
        #No end steps
    }
}

#Running the function
New-PostToTable -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -StorageTableName "logsoftwaretest" -PartitionKey "PartitionKey1" -StorageTableProperties $Hash

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $($obj | ConvertTo-Json)
    })
