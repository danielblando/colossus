Gallery = require './lib/gallery'
fresh = require 'fresh-require'

class AppRouter
  constructor: (@router) ->
    @router.route '/:accountName/:appName/*'
      .get (req, res, next) ->

        accountName = req.params.accountName
        appName = req.params.appName
        sandBox = req.headers['x-vtex-sandbox']

        gallery = new Gallery accountName

        promise = gallery.downloadFilesFromApp(appName, sandBox).then (path) ->
          appPath = path
          application = fresh '../' + appPath + 'colossus', require
          application.run accountName, appName, req, res, next

        promise.catch (err) ->
          next err

module.exports = (router) ->
  return new AppRouter(router)