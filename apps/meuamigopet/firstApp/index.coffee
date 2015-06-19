Enterprise = require "../../../src/lib"
application = new Enterprise.Application()
controller = new Enterprise.Controller()

controller.get "/items", (req, res, next) ->
  res.json a: "testeDoido"

controller2 = new Enterprise.Controller()

controller2.get "/testeDoido2", (req, res, next) ->
  res.json a: "testeDoido22222"


application.register controller
application.register controller2

module.exports = application