const mysql = require('mysql');

// First you need to create a connection to the db
const con = mysql.createConnection({
  host: 'localhost',
  user: 'bmh_user',
  password: 'Id0ntKn0w',
  database: 'BMH'
});

con.connect((err) => {
  if(err){
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
    res.send({
      "code":400,
      "failed":"error ocurred"
    })
  }else{
    // console.log('The solution is: ', results);
    if(results.length > 0){
      if(results[0].password == password){
        res.send({
          "code":200,
          "success":"Login Sucessfull"
            });
      }
      else{
        res.send({
          "code":204,
          "success":"Invalid Username/Password"
            });
      }
    }
    else{
      res.send({
        "code":204,
        "success":"Username does not exist"
          });
    }
  }
  });
}

