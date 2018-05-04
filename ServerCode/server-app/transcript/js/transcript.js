function audiolist(uname, name, status) {
  var username   = uname;  //req.query.uname; //uname;
  var actName    = name;   //req.query.name; // name;
  var status     = status; // req.query.status; // status;

  console.log(username, actName, status);

  if (username == undefined || username == "" || actName == undefined) {
    //res.status(400).send("Bad Request");
    return null;
  }
  else {
    const db = globals.firebaseadmin.firestore(); 
    var res_json = [];

    if (status == undefined) {
      db.collection('user').doc(username).collection('memos')
        .where('tags.' + actName, '==', true)
        .get()
        .then(snapshot => {
          var docCount = 0;
          snapshot.forEach(doc => {
            //console.log(doc.id, '=>', doc.data());
            res_json.push(doc.data());
          });
          console.info("Sending response with " + res_json.length + " documents");
          //res.status(200).send(res_json);
          return res_json;
        })
        .catch(function(error) {
          console.log("Error getting document:", error);
          //res.status(500).send("Error getting document.");
          return null;
        });
    }
    else {
      db.collection('user').doc(username).collection('memos')
        .where('tags.' + actName, '==', true)
        .where('status', '==', status)
        .get()
        .then(snapshot => {
          var docCount = 0;
          snapshot.forEach(doc => {
            //console.log(doc.id, '=>', doc.data());
            res_json.push(doc.data());
          });
          console.info("Sending response with " + res_json.length + " documents");
          //res.status(200).send(res_json);
          return res_json;
        })
        .catch(function(error) {
          console.log("Error getting document:", error);
          //res.status(500).send("Error getting document.");
          return null;
        });
    }
  }
}