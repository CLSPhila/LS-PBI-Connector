// This file contains your Data Connector logic


section LegalServerAPI;

[DataSource.Kind="LegalServerAPI", Publish="LegalServerAPI.Publish"]
shared LegalServerAPI.Contents = (url as text) =>
    let
        source = Web.Contents(url),
        report = Xml.Tables(source){0}[Table]
    in
        report;

// Data Source Kind description
LegalServerAPI = [
    Authentication = [
        UsernamePassword = [
            UsernameLabel="API Username",
            PasswordLabel="API user password",
            Label="API User Credentials"]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
LegalServerAPI.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = LegalServerAPI.Icons,
    SourceTypeImage = LegalServerAPI.Icons
];

LegalServerAPI.Icons = [
    Icon16 = { Extension.Contents("LegalServerAPI16.png"), Extension.Contents("LegalServerAPI20.png"), Extension.Contents("LegalServerAPI24.png"), Extension.Contents("LegalServerAPI32.png") },
    Icon32 = { Extension.Contents("LegalServerAPI32.png"), Extension.Contents("LegalServerAPI40.png"), Extension.Contents("LegalServerAPI48.png"), Extension.Contents("LegalServerAPI64.png") }
];