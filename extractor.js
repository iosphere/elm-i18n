#!/usr/bin/env node

"use strict";

const argv = require("yargs")
    .option("file", {alias: "f"})
    .option("import", {alias: "i", describe: "The destination to which the csv file (given in f) should be written."})
    .demand("file")
    .argv;
const Elm = require("./elm.js");
const fs = require("fs-extra");
const path = require("path");

const currentDir = process.cwd();

fs.readFile(argv.file, function(err, data) {
    let filecontent = data.toString();
    let worker = Elm.Main.worker({
        "source": filecontent,
        "operation": argv.import?"import":"export",
    });

    worker.ports.result.subscribe(function(resultString) {
        if (!argv.import) {
            handleExport(resultString);
        } else {
            handleImport(resultString);
        }
    });
});


function handleExport(resultString) {
    fs.writeFile(path.join(currentDir, "export.csv"), resultString, function(err) {
        if(err) {
            return console.log(err);
        }

        console.log("The file was saved!");
    });
}

function handleImport(resultString) {
    let importPath = argv.import;
    if (!importPath) {
        console.error("No file found")
        return;
    }

    let elmPath = importPath.replace(/\.[^/.]+$/, ".elm");
    console.log("Writting to ", elmPath);

    fs.writeFile(path.join(currentDir, elmPath), resultString, function(err) {
        if(err) {
            return console.log(err);
        }

        console.log("The file was saved!");
    });
}
