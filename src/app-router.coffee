vtexCredentials = require './utils/vtex-credentials'

class AppRouter
  constructor: (@router) ->
    @router.route '/:accountName/:appName/*'
      .get (req, res, next) ->
        accountName = req.params.accountName
        appName = req.params.appName
        appPath = '../apps/' + accountName + '/' + appName
        application = require appPath
        application.run accountName, appName, req, res, next

module.exports = (router) ->
  return new AppRouter(router)