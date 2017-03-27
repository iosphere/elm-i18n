#!/usr/bin/env node

"use strict";

const argv = require("yargs")
    .option("language", {alias: "l", describe: "Please provide language code that you wish to make the base language."})
    .default("rootModule", "Translation")
    .option("yes", {describe: "Reply 'yes' to all automated prompts."})
    .option("output", {describe: "If set elm-make will be called to compile a localized version of your app which will be placed in the given directory."})
    .option("src", {default: "src", describe: "The location of your elm code base. Only relevant if output is set."})
    .option("elmFile", {default: "Main.elm", describe: "File to compiled by elm-make. Only relevant if output is set."})
    .demand(["language"])
    .argv;
const fs = require("fs-extra");
const glob = require("glob");
const path = require("path");
const prompt = require("prompt");
const symlinkOrCopySync = require("symlink-or-copy").sync;

const currentDir = process.cwd();

// baseDir is the location of the translation root module as referenced in your elm app
const baseDir = path.join(currentDir, argv.src, argv.rootModule);

// check if language exists
const languageDir = path.join(currentDir, argv.rootModule, argv.language);
if (!fs.existsSync(languageDir)) {
    console.error("Language module not found", languageDir);
    process.exit(1);
}

// check if base dir exists and delete if needed (after prompt)
if (fs.existsSync(baseDir)) {
    if (!argv.yes) {
        prompt.start();
        console.log("There already is a translation at", baseDir);
        console.log("Should I continue and replace it with <" + argv.language + ">?");
        console.log("enter 'y' to continue");

        prompt.get(["remove"], function(err, result) {
            if (result.remove !== "y") {
                console.log("aborting");
                process.exit(1);
            }

            fs.removeSync(baseDir);
            main();
        });
    } else {
        fs.removeSync(baseDir);
        main();
    }
} else {
    main();
}

/**
 * main - Copies/symlinks the language into place
 */
function main() {
    console.log("Will create symlink from " + languageDir + " to " + baseDir);
    symlinkOrCopySync(languageDir, baseDir);

    // clean out elm-stuff cache
    glob(path.join(currentDir, "/elm-stuff/**/user/project/*/"+argv.rootModule+"*"), function(er, files) {
        files.forEach(function(file) {
            console.log("clearing out cache at", file);
            fs.removeSync(file);
        });
        if (argv.output) {
            build(argv.output);
        }
    });
}


/**
 * build - Builds the elm app with the current language.
 *
 * @param  {type} outputDir The directory to which the elm build should be written.
 *                          Files will be named according to the current language
 */
function build(outputDir) {
    let exec = require("child_process").exec;
    let elmFile = path.join(argv.src, argv.elmFile);
    let cmd = "elm-make " + elmFile + " --yes --output " + argv.output + "/" + argv.language + ".js";
    console.log(cmd);
    exec(cmd, (err, stdout, stderr) => {
        if(err) {
            console.error(err);
            return;
        }
        console.log(stdout);
    });
}
