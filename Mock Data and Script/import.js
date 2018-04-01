//with reference from https://github.com/dalenguyen/firestore-import-export

var admin = require("firebase-admin");
var fs = require('fs');
var serviceAccount = require("./bamboomobile-9c643-firebase-adminsdk-ifqpg-9335cf4bfa.json");

var fileName = process.argv[2];
var collectionName = 'users';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:  "https://bamboomobile-9c643.firebaseio.com"
});

var db = admin.firestore();
var activities = require("./inputone.json");
var stepsinday = require("./inputtwo.json");
var act;
var username;
var datehere;



    // ---------------- single write
var setDoc = db.collection('users').doc("PPV44").collection('activities').doc("PTC")
    .collection("02-23-18").doc("02-23-18")
    .set(stepsinday);





for(var row in activities) {
    if (activities[row].ActivityCode != '') {
        console.log(activities[row]);
        act = activities[row].ActivityCode;
        username = activities[row].UID;
        datehere = activities[row].Date;
        var data;

        //------------  if steps file are available for other activities
        /* if(stepsinday[1].Time.indexOf(datehere) > -1){
             for(var i in stepsinday){
                 console.log(stepsinday[i]);
                 data = stepsinday[i];
                 var setDoc = db.collection('users').doc(username).collection('activities').doc(act)
                     .collection(datehere).doc(datehere)
                     .set(data);
             }

         }else {
             data = {
                 Time: datehere,
                 value: 0
             };
         }*/


        // -------------  for custom data addition
        /* if (JSON.stringify(stepsinday).indexOf(datehere) > -1) {
             data = stepsinday;
         } else {
             data = {
                 Time: datehere,
                 value: 0
             };
         }

         console.log(act + "  " +username);
         var setDoc = db.collection('users').doc(username).collection('activities').doc(act)
             .collection(datehere).doc(datehere)
             .set(data);*/

    }
};


    //-------------  to read data

       /* var getDoc =db.collection('users').doc("PPV44").collection('activities').doc("PTC").get()
            .then(doc => {
            if (!doc.exists) {
            console.log('No such document!');
        } else {
            console.log('Document data:', doc.data());
        }
    })
    .catch(err => {
            console.log('Error getting document', err);
    });*/


       //misc read file : with reference from https://github.com/dalenguyen/firestore-import-export



/*
fs.readFile(fileName, 'utf8', function(err, data){
    if(err){
        return console.log(err);
    }

    // Turn string from file to an Array
    dataArray = JSON.parse(data);

    udpateCollection(dataArray).then(() => {
        console.log('Successfully import collection!');
})

})

async function udpateCollection(dataArray){
    for(var index in dataArray){
        var collectionName = index;
        for(var doc in dataArray[index]){
            if(dataArray[index].hasOwnProperty(doc)){
                await startUpading(collectionName, doc, dataArray[index][doc])
            }
        }
    }
}

function startUpading(collectionName, doc, data){
    return new Promise(resolve => {
        db.collection(collectionName).doc(doc)
        .set(data)
        .then(() => {
        console.log(`${doc} is successed adding to firestore!`);
    resolve('Data wrote!');
})
.catch(error => {
        console.log(error);
});
})
}*/