#!/usr/bin/env node
var argv = require('yargs')
    .option('language', { alias: 'l', describe: 'Please provide language code that you wish to make the base language.' })
    .default('src', 'src')
    .default('rootModule', 'Translation')
    .option('output')
    .demand(['language'])
    .argv;
var fs = require('fs-extra')
var glob = require("glob");
var prompt = require('prompt');
var symlinkOrCopySync = require('symlink-or-copy').sync;

// check if language exists
var languageDir = argv.src + "/" + argv.rootModule + "/" + argv.language
if (!fs.existsSync(languageDir)) {
    console.error("Root module not found", languageDir);
    process.exit(1);
}

// check if base dir exists and delete if needed (after prompt)
var baseDir = argv.src + "/" + argv.rootModule + "/Base"
if (fs.existsSync(baseDir)) {
    prompt.start();
    console.log('There already is a base translation at', baseDir);
    console.log('Should I continue and replace it with <' + argv.language + '>?');
    console.log("enter 'y' to continue");

    prompt.get(['remove'], function (err, result) {
        if (result.remove !== "y") {
            console.log("aborting");
            process.exit(1);
        }

        fs.removeSync(baseDir)
        main();
    });

} else {
    main();
}


function main() {
    console.log("Will create symlink from " + languageDir + " to " + baseDir)
    symlinkOrCopySync(languageDir, baseDir);

    // clean out elm-stuff cache
    glob("elm-stuff/**/user/project/*/"+argv.rootModule+"-Base*", function (er, files) {
        files.forEach(function(file) {
            console.log("clearing out cache at", file);
            fs.removeSync(file);
        });
        build();
    });
}

function build() {
    if (argv.output) {
        var exec = require('child_process').exec;
        var cmd = 'elm-make src/Main.elm --yes --output ' + argv.output + '/' + argv.language + '.js';
        console.log(cmd);
        exec(cmd, (err, stdout, stderr) => {
          if (err) {
            console.error(err);
            return;
          }
          console.log(stdout);
        });
    }
}
