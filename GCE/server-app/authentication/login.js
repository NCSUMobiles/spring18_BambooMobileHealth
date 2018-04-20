const mysql = require('mysql');
const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://bamboomobile-9c643.firebaseio.com'
});

// First you need to create a connection to the db
const con = mysql.createConnection({
  host: 'localhost',
  user: 'bmh_user',
  password: 'Id0ntKn0w',
  database: 'BMH'
});

con.connect((err) => {
  if(err) {
    console.error('Error connecting to DB: ', err);
    return;
  }
  console.info('Connection established to DB');
});

exports.con = con

exports.login = function(req, res) {
  var username = req.body.username;
  var password = req.body.password;

  //console.log("Username=", username, "and password=", password);
  
  con.query('SELECT * FROM users WHERE username = ?',[username], function (error, results, fields) {
    if (error) {
      console.error("Error ocurred executing query:",error);
      res.status(400).send("Error occurred");
    } 
    else {
      // console.log('The solution is: ', results);
      if(results.length > 0) {
        if(results[0].password == password) {
          // generate an authentication token that will be sent back to the user
          var uid = username;
	  admin.auth()
               .createCustomToken(uid)
               .then(function(customToken) {
    	         // Send token back to client
                 res.status(200).send({"token": customToken});
  	  })
  	  .catch(function(error) {
    	    console.log("Error creating custom token:", error);
            res.status(500).send("Error creating authentication token");
  	  });
        }
        else {
          res.status(401).send("Incorrect Username/Password");
        }
      }
      else {
        res.status(403).send("Username does not exist");
      }
    }
  });
}

