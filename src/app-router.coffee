Gallery = require './lib/gallery'
fresh = require 'fresh-require'
pkg = require '../package.json'

class AppRouter
  constructor: (@router) ->
    @router.route '/:accountName/colossus/:appName/*'
      .all (req, res, next) ->

        accountName = req.params.accountName
        appName = req.params.appName
        sandBox = req.headers['x-vtex-sandbox']
        version = req.headers['x-vtex-env-version']

        gallery = new Gallery accountName

        if version? or sandBox?
          promise = gallery.downloadFilesFromCustomApp(appName, version, sandBox)
        else
          promise = gallery.downloadFilesFromDefaultApp(appName)

        promise = promise.then (path) ->
          appPath = path
          if sandBox?
            application = fresh '../' + appPath + 'colossus', require
          else
            application = require '../' + appPath + 'colossus'
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