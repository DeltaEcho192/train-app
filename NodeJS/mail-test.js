const nodemailer = require('nodemailer');
const fs = require('fs');



let jsonData = require('./config.json')
console.log(jsonData)
var hostI = jsonData.host;
var portI = jsonData.port;
var userI = jsonData.senderemail;
var pwI = jsonData.senderpw;
console.log(hostI,portI,userI,pwI)

let transport = nodemailer.createTransport({
    host: hostI,
    port: portI,
    auth: {
       user: userI,
       pass: pwI
    }
});

const message = {
    from: 'xortest@vanoli-ag.ch', // Sender address
    to: 'anthony.durrer@vanoli-ag.ch',         // List of recipients
    subject: 'Email Test', // Subject line
    text: 'I sent this email over my node server/ this is automated' // Plain text body
};
transport.sendMail(message, function(err, info) {
    if (err) {
      console.log(err)
    } else {
      console.log(info);
    }
}); 