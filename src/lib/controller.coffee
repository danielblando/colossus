Route = require('route-parser');
ServiceError= require './service-error'

class Controller
  constructor: () ->
    @routes = {}
  match: (req, res, next) ->
    for key of @routes
      route = new Route(key)
      if route.match req.originalUrl
        @routes[key] req, res, next
        return true;
    #route = @routes["/testeDoido"]
    #if not route
    #  throw  new ServiceError 404, 'asd'
    #route res, res, next
  get: (route, func) ->
    @routes["/:accountName/colossus/:appName" + route] = func

module.exports = Controller

