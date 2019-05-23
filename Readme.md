

# LegalServer PowerBI Connector

Use this custom connector to load reports from the LegalServer API into PowerBI. This project is experimental, so use at your own risk.

**Use of this connector requires saving certain legalserver credentials to a computer's storage. Only do that if you are sure you understand and accept the risks.**

## How to Build
Download [Visual Studio](https://visualstudio.microsoft.com/downloads/). 

Download the [Power Query SDK](https://marketplace.visualstudio.com/items?itemName=Dakahn.PowerQuerySDK&ssr=false#qna) for Visual Studio.

Do not install the SDK yet.

You have probably downloaded Visual Studio 2019. The PQ SDK does not, by default, work with VS 2019, so you must make a few tweaks to it. Follow instructions in the Q&A section of the SDK page for installing the SDK for Visual Studio 2019. 

Double click on the SDK file to install it.

Clone this project's repository and open it with Visual Studio. 

At this point, read through the code. Its only a few lines, but you should understand the gist of what this is doing. And make sure you understand how it is managing secret credentials, so you can decide if this connector is safe for you to use. 

Build the solution. This will create the file: `LegalServerAPI/bin/Debug/LegalServerAPI.mez`. 

## Install for PowerBI Desktop

Move this `.mez` file to your `Documents/Power BI Desktop/Custom Connectors` folder (you may need to create these folders under Documents).

Open Power BI Desktop.

Click Get Data

Search for the `LegalServerAPI` connector and select it. Acknowledge that this is a Preview connector. **Remember, using this connector is experimental, and could lead to exposing confidential client data. Be careful, and use at your own risk!** 

Now PowerBI will ask you for the URL of a report from LegalServer. Let's move on to the next section of this guide.

## How to download a report

After telling PowerBI to get data using this Connector, it will ask you for a report url. You should provide the url to your report **without the api key**. It should look like

```
https://url_to_my_report?load=200&api_key
```

Note the `api_key` at the end of the url. This format is required, although it may go away in a future version of this connector.

Then you'll be prompted for user credentials. Supply the username of a user with api permissions in Legalserver. 

Supply the user's password and the report's api key together in the password field, separated by a `+`, like so:

```
mysupersecrepassword+1234-7890-1234-09876
```

PowerBI will then download your report.

## Cleaning your downloaded report

LegalServer's Reports API returns an `xml` document whose children are `row` elements. Each row contains elements that are the columns of your report. 

The Connector transforms this xml document into a table, but you will need to do some additional cleaning on your own.

Cleaning will probably be much easier if you use the Advanced Query Editor and write the M language code for the cleaning steps. Check out the [Introduction](https://docs.microsoft.com/en-us/powerquery-m/quick-tour-of-the-power-query-m-formula-language). 

### Cleaning table-columns

Many columns will load in PowerBI as `Table` type columns, where every cell in the column is a `Table`. 

To clean columns that download from legalserver as Table columns, this Connector provides `LegalserverAPI.ValOrNull`. Use it to convert empty tables to `null`, or return the contents of non-empty columns as a single joined string. Use it with `Table.TransformColumns` as follows:

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

### A useful pattern for cleaning a LegalServer Report

My experience has been that a handful of steps are useful pretty much every time I use the connector.

First, download the report with a line like 

```
Source = LegalServerAPI.Contents("reporturl&apikey")
```

Then clean it with a separate cleaning function, like so

```

```

The cleaning function should have several steps: 

1. Removing unwanted columns with `Table.RemoveColumns()`,
2. Expanding table columns with `Table.TransformColumns()` and `LegalServerAPI.ValOrNull`,
3. Changing the types of columns with `Table.TransformColumns()`, and 
4. Rename the columns from LegalServer's default internal names to something friendlier with `TableRenameColumns`. 

Here's an example:

```
let
    CleanReport = (t as table) as table =>
        let
            RemoveColumns = Table.RemoveColumns(t, 
                {"col1", "col2"}),
            ExpandedColumns = Table.TransformColumns(
                RemoveColumns,
                {
                 {"table_col", LegalServerAPI.ValOrNull},
                }
            ),
            retyped = Table.TransformColumns(
                ExpandedColumns,
                {
                 {"case_id", DateTime.FromText},
                 {"date_open", DateTime.FromText}
                }
            ),
            cleaned = Table.RenameColumns(retyped,
                {
                 {"matter_builtin_lookup_long_internal_db_name", "Legal Problem Code"}
                }
            )
        in
            cleaned,

    Source = LegalServerAPI.Contents("https://myorg.legalserver.org ... "),
    CleanedReport = CleanReport(Source),
in
    CleanedReport

```

Once you've gotten this far, you will have a report ready for amazing powerbi-full visualization and analysis. Congratulations!