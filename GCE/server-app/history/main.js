const globals = require('../globals.js');
const moment  = require('moment');

function fetchData(uid, activity_name, actName, startOfRange, endOfRange, granularity, res) {
  // while (startOfRange <= endOfRange) {
  //   var dateStr = startOfRange.format("MM-DD-YY");
  //   console.log (dateStr);
  //   startOfRange.add(1, 'days');
  // } 

  //var startOfRange = moment().startOf('week');
  //const endOfRange   = moment().endOf('week');
  //var res_json = {"Sun": 0, "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0};
  const db = globals.firebaseadmin.firestore(); 
          
  var num_requests = 0;
  var num_responses = 0;

  var res_json = {};

  console.log("Start: ", startOfRange, "End: ", endOfRange);
  
  // if (granularity == "d") {
  //   for (var i = 0; i < 24; i++) {
  //     res_json[("00" + i).slice(-2)] = 0;
  //   }
  // }
  // else if (granularity == "w") {
  //   res_json = {"Sun": 0, "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0};
  // }

  while (startOfRange <= endOfRange) {
    var dateStr = startOfRange.format("MM-DD-YY")
    num_requests++;

    db.collection('user').doc(uid).collection(activity_name)
    .doc(actName).collection(dateStr).doc(dateStr).get()
    .then(function(doc) {
      console.log(doc.id);
      if (doc.exists) {
        console.log("Found document data");
        var values = 0;

        if (granularity == "d") {
          // aggregate the data by hours
          var data = doc.data();

          Object.keys(data).forEach(function(key) {
            console.log(key, data[key]);
            //res_json[key.slice(0,2)] += data[key]
            var k = ("00" + parseInt(key.slice(0,2))).slice(-2)
            console.log(k)
            res_json[k] = res_json[k]===undefined ? data[key] : res_json[k] + data[key]

          });
        }
        else if (granularity == "w") {
          // aggregte the data by days
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
        else if (granularity == "m") {
          // aggregte the data by days
          Object.values(doc.data()).forEach(function(e){
            values += e;
          });
          res_json[doc.id.slice(3,-3)] = values;
        }
        else if (granularity == "y") {
          // aggregte the data by months
          Object.values(doc.data()).forEach(function(e){
            values += e;
          });
          res_json[doc.id.slice(0,2)] = res_json[doc.id.slice(0,2)]===undefined ? values : res_json[doc.id.slice(0,2)] + values
        }

      } 
      else {
        // doc.data() will be undefined in this case
        console.log("No such document!");
      }
      
      num_responses++;
      
      // wait to receive 7 responses, one for each day of the week.
      if (num_responses == num_requests) {
        console.log("Found responses for " + num_responses + " days. Returning JSON");
        res.status(200).json(res_json); 
        return;
      }
    })
    .catch(function(error) {
      console.log("Error getting document:", error);
      res.status(500).send("Error getting document.");
      return;
    });

    startOfRange.add(1, 'days');
  } 

}

exports.history = function(req, res) {
  var username   = req.query.uname;
  var token      = req.query.token;
  var granularity= req.query.gran;
  var range      = req.query.range;
  var isActivity = req.query.act == undefined ? undefined : req.query.act == 1 ? true : false;
  var actName    = req.query.name;

  // console.log("username:", username);
  // console.log("token:", token);
  // console.log("granularity:", granularity);
  // console.log("range:", range);
  // console.log("isActivity:", isActivity);
  // console.log("actName:", actName);

  if (username == undefined || token == undefined || username == "" || token == "" || granularity == undefined || range == undefined || isActivity == undefined || actName == undefined) {
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
          var startOfRange;
          var endOfRange;

          if (granularity == "d") {
            // day as "MM-DD-YY" string
            console.log("Requested data for", range);
            startOfRange = moment(range, "MM-DD-YY");
            endOfRange   = moment(range, "MM-DD-YY");

            fetchData(uid, activity_name, actName, startOfRange, endOfRange, granularity, res);
          }
          else if (granularity == "w") {
            // week as "MM-DD-YY MM-DD-YY" string
            console.log("Requested data for", range);
            // break the range around " "
            startOfRange = moment(range.split(" ")[0], "MM-DD-YY");
            endOfRange   = moment(range.split(" ")[1], "MM-DD-YY");

            fetchData(uid, activity_name, actName, startOfRange, endOfRange, granularity, res);
          }
          else if (granularity == "m") {
            // month as "MM-YY" string
            console.log("Requested data for", range);

            startOfRange = moment(range+"-01", "MM-YY-DD");
            endOfRange   = moment(range+"-01", "MM-YY-DD").endOf("month");

            fetchData(uid, activity_name, actName, startOfRange, endOfRange, granularity, res);
          }
          else if (granularity == "y") {
            // year as "YYYY" string
            console.log("Requested data for", range);

            startOfRange = moment("01-01-" + range, "MM-DD-YYYY");
            endOfRange   = moment("12-31-" + range, "MM-DD-YYYY");

            fetchData(uid, activity_name, actName, startOfRange, endOfRange, granularity, res);
          }
          else {
            console.log("Invalid granularity:", granularity);
            res.status(400).send("Bad Request");
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

