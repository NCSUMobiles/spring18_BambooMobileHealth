const express    = require("express");
const login      = require('./authentication/login');
const bodyParser = require('body-parser');
const app        = express();
const port       = 80;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

var router = express.Router();

// test route
router.get('/', function(req, res) {
    res.json({ message: 'Hello World!' });
});

//route to handle user login
router.post('/login',login.login)

// route everything udner /api to router
app.use('/api', router);

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






