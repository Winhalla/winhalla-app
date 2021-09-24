const express = require('express');
const app = express();
const data = require('./sampleData.json');
const matchData = require("./sampleMatchData.json")
app.get("/account",(req,res)=>{
    res.send(data);
});
app.get("/getMatch/613e57a522d5937857affe65",(req,res)=>{
    res.send(data);
})

app.listen(3001,()=>{
    console.log("Listening on port 3001");
});