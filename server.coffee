express    = require 'express'
bodyParser = require 'body-parser'
fs = require('fs');
domain = require 'domain';
vm = require 'vm'

ServiceError = require './src/exceptions/service-error'
appRouter = require './src/app-router'


app = module.exports = express();

app.use bodyParser.urlencoded {extended: true}
app.use bodyParser.json()

app.use "/", (err,req,res,next) ->
  requestDomain = domain.create();
  requestDomain.add req;
  requestDomain.add res;
  requestDomain.on 'error', next;
  requestDomain.run next;

router = express.Router();

app.use '/', router

appRouter(router)

app.use (err,req,res,next) ->
  if err instanceof ServiceError
    res.status(err.statusCode)
    res.send err.message;
  else if err instanceof Error
    throw err
  else
    throw  err

