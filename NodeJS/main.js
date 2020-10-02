const express = require('express')
const app = express()
const port = 3000

const fs = require('fs');
const csv=require('csvtojson')

app.get('/test/:id', (req, res) => {
  var jsonobj = require("./example.json");
  var trainStation = req.params.id;
  console.log(trainStation);
  console.log(jsonobj[trainStation]);
  try{
    workingInfo = jsonobj[trainStation];
    res.send(workingInfo)
    if(workingInfo == undefined)
    {
      throw "Incorrect TrainStation"
    }
  }catch(e){
    console.log(e);
  }

})

app.get('/check/:userId', (req, res) => {
  var usercheck = false;
  emp.forEach(em => {
    console.log(em._userId)
    if(em._userId == req.params.userId)
    {
      console.log("Success")
      usercheck = true;
    }
  });
  console.log(req.params.userId);
  console.log(usercheck);
  res.send(JSON.stringify({"userid": req.params.userId ,"status": usercheck}));
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

// Invoking csv returns a promise
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