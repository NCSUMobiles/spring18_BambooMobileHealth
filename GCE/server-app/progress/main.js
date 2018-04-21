const globals = require('../globals.js');

exports.progress = function(req, res) {
  var username  = req.query.uname;
  var token     = req.query.token;
  var start_date= req.query.sd;
  var end_date  = req.query.ed;
  var isActivity= req.query.act == undefined ? undefined : req.query.act == 1 ? true : false;
  var actName   = req.query.name;

  if (username == undefined || token == undefined || 
      username == "" || token == "" || 
      start_date == undefined || end_date == undefined ||
      isActivity == undefined || actName == undefined) {
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
       
        if (username == uid && iat <= now && exp >= now && auth_time <= now && 
            sub != undefined && sub != "" && aud == globals.projectId && iss == globals.issuer) {
          
          // successfully authenticated. Now we can perform the queries
          const db = globals.firebaseadmin.firestore(); 
          db.collection('users').get()
            .then((snapshot) => {
              console.log (snapshot);
              snapshot.forEach((doc) => {
                console.log(doc.id, '=>', doc.data());
              });
              res.status(200).send("Successfully Authenticated");
            })
            .catch((err) => {
              console.log('Error getting documents', err);
              res.status(500).send("Error getting documents");
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
      
        console.error("Progress: Error occurred signing in.", errorCode, errorMessage);
        res.status(500).send("Error occurred");  
      });
    }
}

