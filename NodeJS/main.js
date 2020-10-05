const express = require('express')
const app = express()
const port = 3000

const fs = require('fs');
const csv=require('csvtojson')

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