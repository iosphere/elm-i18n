#!/usr/bin/env node

"use strict";

const esprima = require("esprima");
const acorn = require("acorn");
const argv = require("yargs")
    .option("file")
    .demand("file")
    .argv;
const fs = require("fs-extra");


fs.readFile(argv.file, function(err, data) {
    let filecontent = data.toString();
    let tokenized = esprima.tokenize(filecontent);


    tokenized.forEach(function(item) {
        if (item.type === "Identifier" && item.value.startsWith("_user$project$Translation_") && !item.value.endsWith("$main")) {
            console.log(item);
        }
    });
    acorn.parse(filecontent, function(node) {
        console.log(node);
    });

});
