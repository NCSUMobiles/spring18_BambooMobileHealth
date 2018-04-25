const globals = require('../globals.js');
const moment  = require('moment');

exports.audio = function(req, res) {
  var username   = req.query.uname;
  var token      = req.query.token;
  var actName    = req.query.name;

  console.log(actName);

  if (username == undefined || token == undefined || username == "" || token == "" || actName == undefined) {
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

      if (username == uid && iat <= now && exp >= now && auth_time <= now && sub != undefined && sub != "" && aud == globals.projectId && iss == globals.issuer) {
        // successfully authenticated. Now we can perform the queries
        const db = globals.firebaseadmin.firestore(); 
        var res_json = [];

        db.collection('user').doc(uid).collection('memos')
          .where('tags.' + actName, '==', true)
          .get()
          .then(snapshot => {
            var docCount = 0;
            snapshot.forEach(doc => {
              //console.log(doc.id, '=>', doc.data());
              res_json.push(doc.data());
            });
            console.info("Sending response with " + res_json.length + " documents");
            res.status(200).send(res_json);
          })
          .catch(function(error) {
            console.log("Error getting document:", error);
            res.status(500).send("Error getting document.");
            return;
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

