Route = require('route-parser');
ServiceError= require './service-error'

class Controller
  constructor: () ->
    @routes = []
  match: (req, res, next) ->
    for item in @routes
      route = new Route(item.route)
      if route.match(req.originalUrl) and req.method is item.method
        item.func req, res, next
        return true;

  get: (route, func) ->
    @routes.push
      method: "GET"
      route: "/:accountName/colossus/:appName" + route
      func: func

  post: (route, func) ->
    @routes.push
      method: "POST"
      route: "/:accountName/colossus/:appName" + route
      func: func

  put: (route, func) ->
    @routes.push
      method: "PUT"
      route: "/:accountName/colossus/:appName" + route
      func: func

  delete: (route, func) ->
    @routes.push
      method: "DELETE"
      route: "/:accountName/colossus/:appName" + route
      func: func

module.exports = Controller

