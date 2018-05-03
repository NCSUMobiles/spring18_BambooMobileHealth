const firebaseadmin    = require('firebase-admin');
const serviceAccount   = require('./serviceAccountKey.json');
const sttSvcAccount    = require('./sttServiceAccountKey.json');
const projectId        = "bamboomobile-9c643"
const issuer           = "https://securetoken.google.com/bamboomobile-9c643"

exports.firebaseadmin  = firebaseadmin;
exports.serviceAccount = serviceAccount;
exports.sttSvcAccount  = sttSvcAccount;
exports.projectId      = projectId;
exports.issuer         = issuer;
