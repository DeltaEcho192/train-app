const express = require('express')
const app = express()
const port = 3000

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

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})