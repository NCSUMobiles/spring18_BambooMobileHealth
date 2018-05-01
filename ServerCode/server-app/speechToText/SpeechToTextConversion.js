var http = require('https');
var fs = require('fs');

const downloadURL = 'https://firebasestorage.googleapis.com/v0/b/bamboomobile-9c643.appspot.com/o/PPV44%2Frecording_2018-04-28%2022%3A25%3A37%20%2B0000?alt=media&token=f123197b-7c64-444b-8709-6ca001cd3fd9';
const outputPath = 'E:/bamboo_mobile/fileout.flac';
const downloadPath  = 'E:/bamboo_mobile/download.m4a';
// Imports the Google Cloud client library
const speech = require('@google-cloud/speech');

// Creates a client
const client = new speech.SpeechClient();


var download = function(url, dest, cb) {
    var file = fs.createWriteStream(dest);
    var request = http.get(url, function(response) {
        response.pipe(file);
        file.on('finish', function() {
            file.close(cb);  // close() is async, call cb after close completes.
        });
    }).on('error', function(err) { // Handle errors
        fs.unlink(dest); // Delete the file async. (But we don't check the result)
        if (cb) cb(err.message);
    });
};

download(downloadURL, downloadPath, (err) =>{
    if(err==null) {
        //invoke commandline
        const exec = require('child_process').execSync;
        const stats = fs.statSync(outputPath);
        if (stats != null) {
            fs.unlinkSync(outputPath);
        }

        exec('ffmpeg -i ' + downloadPath + ' -f flac ' + outputPath);//E:/bamboo_mobile/fileout.flac');

        // Perform Transcription
        // Reads a local audio file and converts it to base64
        const file = fs.readFileSync(outputPath);
        const audioBytes = file.toString('base64');

        const encoding = 'FLAC';
        const languageCode = 'en-US';

        const config = {
            encoding: encoding,
            languageCode: languageCode,
        };
        const audio = {
            //uri: gcsUri,
            content: audioBytes,
        };


        const request = {
            config: config,
            audio: audio,
        };

// Detects speech in the audio file
        client
            .recognize(request)
            .then(data => {
                const response = data[0];
                const transcription = response.results
                    .map(result => result.alternatives[0].transcript)
                    .join('\n');
                console.log(`Transcription: `, transcription);
            })
            .catch(err => {
                console.error('ERROR:', err);
            });

    }else{
        console.log(err);
    }
});