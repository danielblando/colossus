Gallery = require './lib/gallery'
pkg = require '../package.json'
path = require 'path'

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

        promise = promise.then (path) =>
          appPath = path
          if sandBox?
            @clearSandboxCache '../' + appPath + 'colossus'
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

  clearSandboxCache: (completePath) ->
    file = require.resolve(completePath)
    folder = path.dirname(file)
    for key of require.cache
      if key.indexOf(folder, 0) is 0
        delete require.cache[key]
    console.log folder


module.exports = (router) ->
  return new AppRouter(router)