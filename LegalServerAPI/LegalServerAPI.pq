// This file contains your Data Connector logic


section LegalServerAPI;

[DataSource.Kind="LegalServerAPI", Publish="LegalServerAPI.Publish"]
shared LegalServerAPI.Contents = (url as text) =>
    let
        PasswordAPIKey = Text.Split(Extension.CurrentCredential()[Password], "+"),
        username = Extension.CurrentCredential()[Username],
        userpass = List.First(PasswordAPIKey),
        reportkey = List.Last(PasswordAPIKey),
        basicAuth = Binary.ToText(Text.ToBinary(Text.Combine({username, ":", userpass}))),
        //basicAuth = Text.Combine({username, ":", userpass}),
        url = Text.Combine({url, "=", PasswordAPIKey{1}}),
        // headers = [Authorization = Text.Combine({"Basic: ", Binary.ToText(user})]
        source = Web.Contents(url,
            [
                ManualCredentials = true,
                Headers = [#"Authorization" = Text.Combine({"Basic ", basicAuth})]
                //ManualStatusHandling = {403, 404} // Useful for debugging.
            ]),
        // metad = Value.Metadata(source), // Useful for debugging 
        report = Xml.Tables(source){0}[Table]
    in
        report;

// Data Source Kind description
LegalServerAPI = [
    Authentication = [
        UsernamePassword = [
            UsernameLabel="API Username",
            PasswordLabel="API user password, then a '+', then the api key of the report you're downloading.",
            Label="API User Credentials"]
    ]
    //Label = Extension.LoadString("DataSourceLabel")
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

shared LegalServerAPI.ValOrNull = (tbl as table) as any => 
        let
            combined = Text.Combine(Table.ToList(tbl, Combiner.CombineTextByDelimiter(",")), ","),
            stillEmpty = if Text.Trim(combined) = "" then null else combined
        in
            stillEmpty;