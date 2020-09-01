# Azure Software Licence Logging

Software logging saved to Azure table storage

- [Azure Software Licence Logging](#azure-software-licence-logging)
  - [Azure Function App Installation Checklist](#azure-function-app-installation-checklist)
  - [Example REST Post Request](#example-rest-post-request)
  - [Application Logging On Install](#application-logging-on-install)
  - [Power BI Setup](#power-bi-setup)

## Azure Function App Installation Checklist

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
    - git clone code or copy code to the App Function
  - Custom Domains
    - Enable HTTPS Only

## Example REST Post Request

```HTTP REST
POST /api/LogSoftware
HOST: https://APPNAME.azurewebsites.net
Content-Type: application/json

{
    "BiosSerial":  "",
    "ComputerModel":  "",
    "ComputerName":  "",
    "SoftwareName":  "",
    "SoftwareVersion":  "",
    "UserName":  "",
    "WindowsBuild":  "",
    "WindowsVersion":  ""
}

```

## Application Logging On Install

- [How to set up application logging on software install](Resources\Application_Logging_on_Install\README.md)

## Power BI Setup

- [How to setup the Power BI Queries](Resources\Power_BI_Setup\README.md)
