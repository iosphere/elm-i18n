#!/usr/bin/env node

"use strict";

const argv = require("yargs")
    .default("root", "Translation")
    .option("language", {alias: "l"})
    .option("export", {alias: "e", describe: "A glob pattern for files to include in the exported CSV. Use this to create exports per module."})
    .option("exportOutput", {default: "export.csv"})
    .option("import", {alias: "i", describe: "A CSV file to be imported and to generate code from. Generate elm files will be placed in './import/'"})
    .option("importOutput", {default: "import"})
    .demand("language")
    .conflicts("import", "export")
    .argv;
const Elm = require("./elm.js");
const fs = require("fs-extra");
const path = require("path");
const glob = require("glob");

if (!argv.export && !argv.import) {
    console.error("Please provide import or export option");
    process.exit(403);
}

const currentDir = process.cwd();

if (argv.export) {
    let fullPath = path.join(currentDir, argv.root, argv.language);
    console.log("reading from ", fullPath);
    let fileContents = [];
    let fileNames = glob.sync(fullPath + "/**.elm");
    console.log("found files for export: ", fileNames);

    fileNames.forEach(function(file) {
        let data = fs.readFileSync(file);
        let content = data.toString();
        fileContents.push(content);
    });

    let worker = Elm.Main.worker({
        "sources": fileContents,
        "operation": "export",
    });

    worker.ports.exportResult.subscribe(function(resultString) {
        handleExport(resultString);
    });
} else {
    let fullPath = path.join(currentDir, argv.import);
    let data = fs.readFileSync(fullPath);
    let content = data.toString();

    let worker = Elm.Main.worker({
        "sources": [content],
        "operation": "import",
    });

    worker.ports.importResult.subscribe(function(resultString) {
        handleImport(resultString);
    });
}


function handleExport(resultString) {
    console.error(resultString);
    fs.writeFileSync(path.join(currentDir, argv.exportOutput), resultString);
}

function handleImport(results) {
    console.error(results);
    let importDir = path.join(currentDir, argv.importOutput, argv.language);
    fs.ensureDirSync(importDir);
    results.forEach(function(result) {
        let moduleName = result[0];
        let filePath = path.join(importDir, moduleName + ".elm");
        fs.ensureDirSync(path.dirname(filePath));
        fs.writeFileSync(filePath, result[1]);
    });
}
