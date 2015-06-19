Gallery = require './lib/gallery'

class AppRouter
  constructor: (@router) ->
    @router.route '/:accountName/:appName/*'
      .get (req, res, next) ->

        accountName = req.params.accountName
        appName = req.params.appName

        gallery = new Gallery accountName

        promise = gallery.downloadFilesFromApp(appName).then (path) ->
          appPath = path
          application = require '../' + appPath + 'colossus'
          application.run accountName, appName, req, res, next

        promise.catch (err) ->
          next err

module.exports = (router) ->
  return new AppRouter(router)