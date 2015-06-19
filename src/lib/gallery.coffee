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
        #proxy: 'http://localhost:8888'
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


  getFilesFromVersion: (vendor, appName, token, version) ->
    options =
      url: 'http://api.beta.vtex.com/' + vendor + '/apps/'+ appName + '/' + version + '/files?i=colossus/&content=true'
      headers:
        Authorization: 'token ' + token.authCookie.Value
        Accept: 'application/vnd.vtex.gallery.v0+json'
    return request.get(options)

  getFiles: (vendor, appName, token, version, sandbox) ->
    if version?
      return @getFilesFromVersion(vendor, appName, token, version)
    else if sandbox?
      return @getFilesFromSandbox(vendor, appName, token, sandbox)
    else
      throw new Error()


  getFilesFromSandbox: (vendor, appName, token, sandbox) ->
    sandBoxName = sandbox.replace(':', '/').split('/')[1]
    options =
      url: 'http://api.beta.vtex.com/' + vendor + '/sandboxes/' + sandBoxName +  '/' + appName + '/files?i=colossus/&content=true'
      #proxy: 'http://localhost:8888'
      headers:
        Authorization: 'token ' + token.authCookie.Value
        Accept: 'application/vnd.vtex.gallery.v0+json'

    options.headers['x-vtex-sandbox'] = sandbox
    return request.get(options)


  downloadFilesFromDefaultApp: (appName) ->
    vendor = appName.split('.')[0]
    name = appName.split('.')[1]

    promise = @getVersionMapFromApp appName

    thz = @

    return promise.then (version) ->
      return thz.downloadFilesFromCustomApp(appName, version)

  downloadFilesFromCustomApp: (appName, version, sandbox) ->
    vendor = appName.split('.')[0]
    name = appName.split('.')[1]

    saveFile = (appName, version, key, content, sandbox) ->
      return Q.Promise (resolve, reject, notify) ->
        if not sandbox
          appPath = './apps/' + appName + '/' + version + '/'
        else
          sandBoxName = sandbox.replace(':', '/').split('/')[1]
          appPath = './apps/sandbox/' + sandBoxName + '/' + appName + '/'
        dir = path.dirname(appPath + key)
        console.log version
        mkdirp dir, (err) ->
          fs.writeFile appPath + key, content,  (err) ->
            console.log key
            resolve(appPath)

    thz = @

    promise = vtexCredentials.getToken().then (token) ->
        return thz.getFiles(vendor, name, token, version, sandbox).then (data)->
          console.log data
          appContent = JSON.parse data
          promisses = []
          for key, value of appContent
            promisses.push saveFile appName, version, key, value.content, sandbox
          return Q.all promisses

    return promise.then (paths) ->
      return paths[0];




module.exports = Gallery