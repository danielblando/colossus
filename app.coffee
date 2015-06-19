express = require 'express'
cluster = require 'cluster'

workers = {}
count = require('os').cpus().length;

app = require './server';

debug = typeof v8debug == 'object'

spawn = () ->
  console.log 'fork'
  worker = cluster.fork();
  workers[worker.pid] = worker
  return worker

if !debug
  console.log 'Release'
  if cluster.isMaster

    for i in [0..count]
      console.log i
      spawn()

    cluster.on 'exit', (worker)->
      console.log 'exit' + worker.process.pid
      delete workers[worker.pid]
      spawn()
  else
    console.log 'Listener'
    app.listen process.env.PORT || 5000
else
  console.log 'Debug'
  app.listen process.env.PORT || 5000
