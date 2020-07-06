# Synopsis

Software logging saved to Azure table storage

## Installation Checklist

- Generate Resource group (which all resources will be under)
- Create App Registration
  - Create new secret
- Create storage account
  - Generate azure table
    - Set Access policy (right click on the table and choose "Access Policy") and add the client ID of the App Registration
    - Add Read & Update
- Create App Function
  - Add application insights (software monitoring)
  - Configure:
    - Application Settings
      - Add storage account name and key (so they are env variables to the script)
      - Add service principal and secret (AKA the app registration's client ID and secret)  (if needed to connect and azure and load the aztablerow commands)
  - New Function
    - Remove "get" from the function.json
    - Set function.json to "anonymous" rather than function
    - Copy code to run.ps1
    - Copy code to requirements.psd1
  - Custom Domains
    - Enable HTTPS Only
    
