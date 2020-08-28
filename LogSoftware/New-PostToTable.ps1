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
        [string][parameter(Mandatory = $true)]$Tenant,
        [System.Management.Automation.PSCredential][parameter(Mandatory = $true)]$ServicePrincipalCredential,
        [string][parameter(Mandatory = $true)]$StorageAccountName,
        [string][parameter(Mandatory = $true)]$StorageAccountKey,
        [string][parameter(Mandatory = $true)]$StorageTableName,
        [string][parameter(Mandatory = $true)]$PartitionKey,
        [pscustomobject][parameter(Mandatory = $true)]$StorageTableProperties
    )

    begin {
        # Import the needed modules
        $Modules = Get-Module
        if ($Modules.name -notcontains "Az.Accounts") { Import-Module Az.Accounts }
        if ($Modules.name -notcontains "Az.Storage") { Import-Module Az.Storage }
        if ($Modules.name -notcontains "AzTable") { Import-Module AzTable }

        # Connecting to an AD service account (which auto loads the "AzStorageTable" cmdlets, this is required to use these commands)
        $null = Connect-AzAccount -Tenant $Tenant -Credential $ServicePrincipalCredential -ServicePrincipal

        # Gather the AZ Storage Context which provides information about the account to be used
        $CTX = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

        # Using the context, get the storage table and gather the "CloudTable" properties
        $CloudTable = (Get-AzStorageTable -Name $StorageTableName -Context $CTX.Context).CloudTable
    }

    process {
        <#
            Generate a randomized GUID for the RowKey because we do not have a unique value to use (user & computer may have more than one different install, so each entry must be logged).
            Additionally we dont want to query the Data Table every time to calulate the number of rows as this will reduce the speed of the code.
            In the future if actual individual single use licence codes are used, we could use that as the RowKey.
        #>
        $rowkey = ([guid]::NewGuid().tostring())

        # Generate an object that contains all of the important data related to the Row that is about to be added to the table
        $RowToAdd = @{
            Table        = $cloudTable
            PartitionKey = $PartitionKey
            RowKey       = $rowkey
            Property     = $StorageTableProperties
        }

        # Using Splatting, add the table row with the included properties
        Add-AzTableRow @RowToAdd
    }

    end {
        # Disconnect the AZ Account info
        Disconnect-AzAccount
        
        # Disconnect the modules now that the function is completed.
        $Modules = Get-Module
        if ($Modules.name -contains "Az.Accounts") { Remove-Module Az.Accounts }
        if ($Modules.name -contains "Az.Storage") { Remove-Module Az.Storage }
        if ($Modules.name -contains "AzTable") { Remove-Module AzTable }
    }
}
