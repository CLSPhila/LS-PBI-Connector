﻿// Use this file to write queries to test your data connector
let
    result = LegalServerAPI.Contents("https://clsphila.legalserver.org//modules/report/api_export.php?load=630&api_key"),
    expanded = Table.TransformColumns(result, {
        {"id", LegalServerAPI.ValOrNull}
    })
in
    expanded

