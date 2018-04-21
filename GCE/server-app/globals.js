const firebaseadmin    = require('firebase-admin');
const serviceAccount   = require('./serviceAccountKey.json');
const projectId        = "bamboomobile-9c643"
const issuer           = "https://securetoken.google.com/bamboomobile-9c643"

exports.firebaseadmin  = firebaseadmin;
exports.serviceAccount = serviceAccount;
exports.projectId      = projectId;
exports.issuer         = issuer;
