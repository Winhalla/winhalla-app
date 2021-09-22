const express = require('express');
const app = express();
const data = require('./sampleData.json');

app.get("/account",(req,res)=>{
    res.send(data);
});

app.listen(3001,()=>{
    console.log("Listening on port 3001");
});