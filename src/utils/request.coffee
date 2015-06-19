request = require 'request'
Q = require 'q';

request.defaults 'proxy':'http://localhost:8888'

class Request
  constructor: () ->
  get: (params) ->
    return Q.Promise (resolve, reject, notify) ->
      request.get params, (error, response, body) ->
        if error
          reject error
        resolve body



module.exports = new Request()