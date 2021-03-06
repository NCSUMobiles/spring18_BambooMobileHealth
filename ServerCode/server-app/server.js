const express    = require('express');
const bodyParser = require('body-parser');
const path       = require('path');

const login      = require('./authentication/main');
const progress   = require('./progress/main');
const history    = require('./history/main');
const audio      = require('./audio/main');
const stt        = require('./stt/main');
const globals    = require('./globals.js');

const app        = express();
const port       = 80;

// initialize firebaseadmin
globals.firebaseadmin.initializeApp({
  credential: globals.firebaseadmin.credential.cert(globals.serviceAccount),
  databaseURL: 'https://bamboomobile-9c643.firebaseio.com'
});

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

var router = express.Router();

// test route
// app.get('/', function(req, res) {
//     res.json({ message: 'Hello World from BMH API!' });
// });

// get the transcript page 
app.get('/', function(req, res){
  return res.sendFile(path.join(__dirname + '/transcript/login.html'));
});

// route to handle user login
router.post('/login',login.login)

// route to handle requests for progress tab
router.get('/progress', progress.progress)

// route to handle requests for history tab
router.get('/history', history.history)

// route to handle requests for history tab, audio memos
router.get('/audio', audio.audio)

// route to handle requests for audio files from the transcript interface
router.get('/audiolist', audio.audiolist)

// route to handle requests for stt
router.get('/stt', stt.stt)

// route to handle requests for stt using admin
router.get('/sttAdmin', stt.sttAdmin)

// route everything udner /api to router
app.use('/api', router);

// route everything under /transcript for static pages
app.use(express.static(path.join(__dirname, '/transcript')));

// start listening on port
const server = app.listen(port, (err) => {
  if (err) {
    return console.error('Error occured starting server on port', port, err);
  }

  console.info('Server is listening on port', port);
});

// handle graceful shutdown
process.on('SIGTERM', function onSigterm () {
  console.info('Got SIGTERM. Graceful shutdown start', new Date().toISOString());

  // start graceul shutdown here
  shutdown()
});

process.on('SIGINT', function onSigterm () {
  console.info('Got SIGINT. Graceful shutdown start', new Date().toISOString());

  // start graceul shutdown here
  shutdown()
});

process.on('SIGUSR2', function onSigterm () {
  console.info('Got SIGUSR2. Graceful shutdown start', new Date().toISOString());
    
  // start graceul shutdown here
  shutdown()
}); 

function shutdown() {
  server.close(function onServerClosed (err) {
    if (err) {
      console.error(err);
      process.exit(1);
    }
    
    login.con.end((err) => {
      // The connection is terminated gracefully
      // Ensures all previously enqueued queries are still
      // before sending a COM_QUIT packet to the MySQL server.
      console.info('Closing connection to DB');
      if (err) {
        console.error(err);
        process.exit(1);
      }

      console.info('Server shutdown', new Date().toISOString(), '\n');
    });
  });
}
