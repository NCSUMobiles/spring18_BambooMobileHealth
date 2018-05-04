const fs       = require('fs');
const http     = require('https');
const speech   = require('@google-cloud/speech');
const globals  = require('../globals.js');

const tempPath = './download.m4a'
const convPath = './converted.flac'

exports.sttAdmin = function(req, res) {
  var uri        = req.query.uri;

  console.log("uri:", uri);

  if (uri == undefined || uri == "" ) {
    res.status(400).send("Bad Request");
  }
  else {
    var file = fs.createWriteStream(tempPath);
    var request = http.get(uri, function(response) {
      response.pipe(file);
      file.on('finish', function() {
            transcript(res);
          });
    }).on('error', function(error) { 
        // Handle errors
        fs.unlinkSync(tempPath);   
        var errorCode = error.code;
        var errorMessage = error.message;
        
        console.error("STT: Error occurred.", errorCode, errorMessage);
        res.status(500).send("Error occurred. " + errorCode + " " + errorMessage);
      });
  }
}


exports.stt = function(req, res) {
  var username   = req.query.uname;
  var token      = req.query.token;
  var uri        = req.query.uri;

  console.log("username:", username);
  // console.log("token:", token);
  console.log("uri:", uri);

  if (username == undefined || token == undefined || uri == undefined || uri == "" || username == "" || token == "" ) {
    res.status(400).send("Bad Request");
  }
  else {
    globals.firebaseadmin.auth().verifyIdToken(token)
    .then(function(decodedToken) {
      const uid = decodedToken.uid;
      const iat = decodedToken.iat;
      const exp = decodedToken.exp;
      const aud = decodedToken.aud;
      const iss = decodedToken.iss;
      const sub = decodedToken.sub;
      const auth_time = decodedToken.auth_time;
      const now = Math.floor(Date.now() / 1000)

      var num_responses = 0;

      if ((username == uid || uid == "admin") && iat <= now && exp >= now && auth_time <= now && sub != undefined && sub != "" && aud == globals.projectId && iss == globals.issuer) {
          // successfully authenticated. Now we can perform the queries
          var file = fs.createWriteStream(tempPath);
          var request = http.get(uri, function(response) {
            response.pipe(file);
            file.on('finish', function() {
                  transcript(res);
                });
          }).on('error', function(error) { 
              // Handle errors
              fs.unlinkSync(tempPath);   
              var errorCode = error.code;
              var errorMessage = error.message;
              
              console.error("STT: Error occurred.", errorCode, errorMessage);
              res.status(500).send("Error occurred. " + errorCode + " " + errorMessage);
            });
        } 
        else {
          res.status(403).send("Unauthorized User");
        }
      })
    .catch(function(error) {
      // Handle error
      var errorCode = error.code;
      var errorMessage = error.message;

      console.error("History: Error occurred.", errorCode, errorMessage);
      if (errorCode == "auth/argument-error") {
        res.status(401).send("Error occurred. " + errorCode + " " + errorMessage); 
      }
      else {
        res.status(500).send("Error occurred. " + errorCode + " " + errorMessage);  
      }
    });
  }
}




// const downloadURL = 'https://firebasestorage.googleapis.com/v0/b/bamboomobile-9c643.appspot.com/o/PPV44%2Frecording_2018-04-28%2022%3A25%3A37%20%2B0000?alt=media&token=f123197b-7c64-444b-8709-6ca001cd3fd9';
// const outputPath = './fileout.flac';
// const downloadPath  = './download.m4a';

function transcript(res) {
  const client = new speech.SpeechClient({
    projectId: globals.projectId
  });

  //invoke commandline
  const exec = require('child_process').execSync;
  
  try {
    const stats = fs.statSync(convPath);
  
    if (stats != null) {
      fs.unlinkSync(convPath);
    }
  }
  catch (error) {
    var errorCode = error.code;
    var errorMessage = error.message;
    
    console.error("STT: Error occurred.", errorCode, errorMessage);
  }

  exec('ffmpeg -i ' + tempPath + ' -f flac ' + convPath);

  // Perform Transcription
  // Reads a local audio file and converts it to base64
  const file       = fs.readFileSync(convPath);
  const audioBytes = file.toString('base64');

  const encoding     = 'FLAC';
  const languageCode = 'en-US';

  const config = {
    encoding:     encoding,
    languageCode: languageCode,
  };

  const audio = {
    //uri: gcsUri,
    content: audioBytes,
  };

  const request = {
    config: config,
    audio:  audio,
  };

  // Detects speech in the audio file and returns the result
  client
    .recognize(request)
    .then(data => {
      const response = data[0];
      const transcription = response.results
                                    .map(result => result.alternatives[0].transcript)
                                    .join('\n');
      console.log('Transcription: ', transcription);
      res.status(200).send(transcription);
  })
  .catch(error => {
    var errorCode = error.code;
    var errorMessage = error.message;
    
    console.error("STT: Error occurred.", errorCode, errorMessage);
    res.status(500).send("Error occurred. " + errorCode + " " + errorMessage);
  });
}