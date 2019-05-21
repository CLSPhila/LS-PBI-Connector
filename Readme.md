

# LegalServer PowerBI Connector

Use this custom connector to load reports from the LegalServer API into PowerBI. 

**Use of this connector requires saving certain legalserver credentials to a computer's storage. Only do that if you are sure you understand and accept the risks**

## How to Build and Install

Download [Visual Studio](https://visualstudio.microsoft.com/downloads/). 

Download the [Power Query SDK](https://marketplace.visualstudio.com/items?itemName=Dakahn.PowerQuerySDK&ssr=false#qna) for Visual Studio.

Do not install the SDK yet!

You have probably downloaded Visual Studio 2019. The PQ SDK does not, by default, work with VS 2019, so you must make a few tweaks to it. Follow instructions in the Q&A section of the SDK page for installing the SDK for Visual Studio 2019. 

Double click on the SDK file to install it.

Clone this project's repository and open it with Visual Studio. 

At this point, read through the code. Its only a few lines, but you should understand the gist of what this is doing. And make sure you understand how it is managing secret credentials, so you can decide if this connector is safe for you to use. 

Build the solution. This will create the file: `LegalServerAPI/bin/Debug/LegalServerAPI.mez`. Move this file to your `Documents/Power BI Desktop/Custom Connectors` folder (you may need to create these folders under Documents).

Open Power BI Desktop.

Click Get Data

Search for the `LegalServerAPI` connector and select it. Acknowledge that this is a Preview connector. **Remember, using this connector is experimental, and could lead to exposing confidential client data. Be careful, and use at your own risk!** 

Now PowerBI will ask you for the URL of a report from LegalServer. Let's move on to the next section of this guide.

## How to download a report

After telling PowerBI to get data using this Connector, it will ask you for a report url. You should provide the url to your report **without the api key**. It should look like

```
https://clsphila.legalserver.org//modules/report/api_export.php?load=630&api_key
```

Then you'll be prompted for user credentials. Supply the username of a user with api permissions in Legalserver. 

Supply the user's password and the report's api key together in the password field, separated by a `+`, like so:

```
mysupersecrepassword+1234-7890-1234-09876
```

PowerBI will then download your report.

You may encounter some columns that load as "table" types, not regular values. This connector provides some utilities to help clean those up.

## Cleaning table-columns

To clean columns that download from legalserver as Table columns, there are helper functions in this extension to help deal with those columns. 

Currently, the only one is `LegalserverAPI.ValOrNull`. Use it to convert empty tables to `null`, or return the contents of non-empty columns as a single joined string. Use it with `Table.TransformColumns` as follows:

```
// Use this file to write queries to test your data connector
let
    result = LegalServerAPI.Contents("https://myreporturl"),
    expanded = Table.TransformColumns(result, {
        {"id", LegalServerAPI.ValOrNull}
    })
in
    expanded
```