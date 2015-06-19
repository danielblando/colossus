Gallery = require './lib/gallery'
fresh = require 'fresh-require'
pkg = require '../package.json'

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

    @router.route '/healthcheck'
      .get (req, res, next) ->
        res.json "ok"

    @router.route '/meta/whoami'
      .get (req, res, next) ->
        whoami =
          app: pkg.name
          appShortName: pkg.name
          version: pkg.version
          roots: pkg.paths
          hosts: pkg.hosts

        res.json whoami

module.exports = (router) ->
  return new AppRouter(router)