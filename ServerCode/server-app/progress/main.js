const globals = require('../globals.js');
const moment  = require('moment');

exports.progress = function(req, res) {
  var username  = req.query.uname;
  var token     = req.query.token;
  var isActivity= req.query.act == undefined ? undefined : req.query.act == 1 ? true : false;
  var actName   = req.query.name;

  // console.log("username:", username);
  // console.log("token:", token);
  // console.log("isActivity:", isActivity);
  // console.log("actName:", actName);

  if (username == undefined || token == undefined || username == "" || token == "" || isActivity == undefined || actName == undefined) {
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
      const activity_name = isActivity ? "activities" : "exercises"
      const now = Math.floor(Date.now() / 1000)

      var num_responses = 0;

      if (username == uid && iat <= now && exp >= now && auth_time <= now && 
        sub != undefined && sub != "" && aud == globals.projectId && iss == globals.issuer) {
          // successfully authenticated. Now we can perform the queries
          const db = globals.firebaseadmin.firestore(); 
          
          var startOfWeek = moment().startOf('week');
          const endOfWeek   = moment().endOf('week');
          var res_json = {"Sun": 0, "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0};

          while (startOfWeek <= endOfWeek) {
            var dateStr = startOfWeek.format("MM-DD-YY")
            
            db.collection('user').doc(uid).collection(activity_name)
            .doc(actName).collection(dateStr).doc(dateStr).get()
            .then(function(doc) {
              console.log(doc.id);
              
              if (doc.exists) {
                console.log("Found document data");
                var values = 0;
                
                Object.values(doc.data()).forEach(function(e){
                  values += e;
                });

                switch(moment(doc.id, "MM-DD-YY").day()) {
                  case 0: res_json["Sun"] = values;
                    break;
                  case 1: res_json["Mon"] = values;
                    break;
                  case 2: res_json["Tue"] = values;
                    break;
                  case 3: res_json["Wed"] = values;
                    break;
                  case 4: res_json["Thu"] = values;
                    break;
                  case 5: res_json["Fri"] = values;
                    break;
                  case 6: res_json["Sat"] = values;
                    break;
                }
              } 
              else {
                // doc.data() will be undefined in this case
                console.log("No such document!");
                switch(moment(doc.id, "MM-DD-YY").day()) {
                  case 0: res_json["Sun"] = 0;
                    break;
                  case 1: res_json["Mon"] = 0;
                    break;
                  case 2: res_json["Tue"] = 0;
                    break;
                  case 3: res_json["Wed"] = 0;
                    break;
                  case 4: res_json["Thu"] = 0;
                    break;
                  case 5: res_json["Fri"] = 0;
                    break;
                  case 6: res_json["Sat"] = 0;
                    break;
                }
              }
              num_responses++;
              
              // wait to receive 7 responses, one for each day of the week.
              if (num_responses == 7) {
                console.log("Found responses for all 7 days. Returning doc");
                res.status(200).json(res_json); 
                return;
              }
            })
            .catch(function(error) {
              console.log("Error getting document:", error);
              res.status(500).send("Error getting document.");
              return;
            });

            startOfWeek.add(1, 'days');
          } 
        } 
        else {
          res.status(403).send("Unauthorized User");
        }
      })
    .catch(function(error) {
      // Handle error
      var errorCode = error.code;
      var errorMessage = error.message;

      console.error("Progress: Error occurred. ", errorCode, errorMessage);
      if (errorCode == "auth/argument-error") {
        res.status(401).send("Error occurred. " + errorCode + " " + errorMessage); 
      }
      else {
        res.status(500).send("Error occurred. " + errorCode + " " + errorMessage);  
      }
    });
  }
}

