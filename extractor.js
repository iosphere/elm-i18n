#!/usr/bin/env node

"use strict";

const argv = require("yargs")
    .option("file")
    .demand("file")
    .argv;
const fs = require("fs-extra");
const Elm = require("./elm.js");


fs.readFile(argv.file, function(err, data) {
    let filecontent = data.toString();
    let worker = Elm.Main.worker({"source": filecontent});
});
