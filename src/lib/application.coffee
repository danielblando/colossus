ServiceError= require './service-error'

class Application
  constructor: () ->
    @controllers = []
  register: (controller) ->
    @controllers.push controller
  run: (accountName, appName, req, res, next) ->
    for controller in @controllers
      if controller.match(req, res, next)
        return;
    throw new ServiceError 404, "Route Not Found"
  getAppVersionMap: (accountName) ->
    path = 'http://api.beta.vtex.com/' + accountName + '/workspaces/master/apps'


module.exports = Application