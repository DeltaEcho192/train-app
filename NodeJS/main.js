const express = require('express')
const app = express()
const port = 3000

const fs = require('fs');
const csv=require('csvtojson');
const { send } = require('process');

//Route for application to get Baustelle specific Checklist.
//TODO have default and station merge.
app.get('/test/:id', (req, res) => {
  var jsonobj = require("./example.json");
  var trainStation = req.params.id;
  var default1 = jsonobj['Default'];
  if(trainStation == 'Default')
  {
    res.send(default1);
  }else{
    console.log(default1)
    console.log(trainStation);
    console.log(jsonobj[trainStation]);
    try{
      workingInfo = jsonobj[trainStation];
      var final = [...default1,...workingInfo];
      res.send(final)
      if(workingInfo == undefined)
      {
        throw "Incorrect TrainStation"
      }
    }catch(e){
      console.log(e);
      res.status(404);
    }
  }
  
  

})

//Route so that application can verify a user based on internal list
app.get('/check/:userId/:udid', (req, res) => {
  var usercheck = false;
  var udidC = req.params.udid;
  var deviceCheck;

  fs.readFile("devices.txt", function (err, data) {
    if (err) throw err;
    if(data.includes(udidC) == true){
     deviceCheck = true;
     emp.forEach(em => {
      console.log(em._userId)
      if(em._userId == req.params.userId)
      {
        console.log("Success")
        usercheck = true;
      }
    });
    console.log(req.params.userId);
    console.log(req.params.udid);
    console.log(usercheck);
    res.send(JSON.stringify({"userid": req.params.userId ,"status": usercheck}));
    }
    else{
      deviceCheck = false
      console.log("Not Allowed")
      res.send(JSON.stringify({"userid": req.params.userId ,"status": false}));
    }
  });

  
})

app.get('/udid/:check', (req,res) => {
  var udid = req.params.check;
  fs.readFile("devices.txt", function (err, data) {
    if (err) throw err;
    if(data.includes(udid) == true){
     res.send("Found Device");
    }
    else{res.send("Device Not found")}
  });
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})

class Employee {
  set userId(userId)
  {
    this._userId=userId;
  }
  set Name(Name)
  {
    this._Name=Name;
  }
  set Password(Password)
  {
    this._Password=Password;
  }
  set Email(Email)
  {
    this._Email=Email;
  }
}
let emp=[];

// Reads user file once on Application Start.
const converter=csv()
.fromFile('./users.csv')
.then((json)=>{
    let e;
    json.forEach((row)=>{
        e=new Employee();// New Employee Object
        Object.assign(e,row);// Assign json to the new Employee
        emp.push(e);// Add the Employee to the Array
        
    });
});