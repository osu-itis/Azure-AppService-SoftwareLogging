# Configuring the Power BI query file

- Install the Power BI Desktop
- Open the `SoftwareLoggingQuery.pbit` in the Power BI Desktop
- Right click the `SoftwareLoggingTable` > select `Edit Query`
- Click on the `Data Source Settings` icon in the top ribbon
- Click `Change Source` and type in the correct Azure Table Storage Location, click `OK`
- Click the `Edit Credentials` icon from the alert banner
- Input the secret Account Key for the Azure Table Storage, click `Connect`
- Click `Close & Apply` from the top ribbon
- Click `Pubish` from the top ribbon
  - >NOTE: This will prompt you to save your changes. If you choose yes, this will create a `.pbix` file type that has stored the Azure Table Storage Location and can be used to query the data.
  - Once the file has been published, it can be stored in your online workspace or saved to a shared workspace with colleagues that also have a `Power BI Pro Licence subscription`.
