request = require '../utils/request'
vtexCredentials = require '../utils/vtex-credentials'
path = require 'path'
mkdirp = require 'mkdirp'
fs = require 'fs'
Q = require 'q'

class Gallery
  constructor: (@accountName) ->
  getVersionMap: () ->
    promise = vtexCredentials.getToken()
    accountName = @accountName
    promise = promise.then (token) ->
      options =
        url: 'http://api.beta.vtex.com/' + accountName + '/workspaces/master/apps'
        proxy: 'http://localhost:8888'
        headers:
          Authorization: 'token ' + token.authCookie.Value
          Accept: 'application/vnd.vtex.gallery.v0+json'
      return request.get options

    return promise.then (data) ->
      return JSON.parse data

  getVersionMapFromApp: (appName) ->
    vendor = appName.split('.')[0]
    name = appName.split('.')[1]
    promise = @getVersionMap()
    return promise.then (map) ->
      for item in map
        if item.owner is vendor and item.name is name
          return item.version
      return ''

  downloadFilesFromApp: (appName) ->
    vendor = appName.split('.')[0]
    name = appName.split('.')[1]
    promise = @getVersionMapFromApp appName
    saveFile = (appName, version, key, content) ->
      return Q.Promise (resolve, reject, notify) ->
        appPath = './apps/' + appName + '/' + version + '/'
        dir = path.dirname(appPath + key)
        console.log version
        mkdirp dir, (err) ->
          fs.writeFile appPath + key, content,  (err) ->
            console.log key
            resolve(appPath)

    promise = promise.then (version) ->
      return vtexCredentials.getToken().then (token) ->
        options =
          url: 'http://api.beta.vtex.com/' + vendor + '/apps/'+ name + '/' + version + '/files?i=colossus/&content=true'
          proxy: 'http://localhost:8888'
          headers:
            Authorization: 'token ' + token.authCookie.Value
            Accept: 'application/vnd.vtex.gallery.v0+json'
        return request.get(options).then (data)->
          appContent = JSON.parse data
          promisses = []
          for key, value of appContent
            promisses.push saveFile appName, version, key, value.content
          return Q.all promisses

    return promise.then (paths) ->
      return paths[0];


module.exports = Gallery