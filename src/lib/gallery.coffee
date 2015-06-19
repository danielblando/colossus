request = require '../utils/request'
vtexCredentials = require '../utils/vtex-credentials'
fs = require 'fs'

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
          console.log item.version
          return item.version
      return ''

  downloadFilesFromApp: (appName) ->
    vendor = appName.split('.')[0]
    name = appName.split('.')[1]
    promise = @getVersionMapFromApp appName

    promise = promise.then (version) ->
      return vtexCredentials.getToken().then (token) ->
        console.log 'asdasdasdasdasdasd'
        options =
          url: 'http://api.beta.vtex.com/' + vendor + '/apps/'+ name + '/' + version + '/files?i=colossus/&content=true'
          proxy: 'http://localhost:8888'
          headers:
            Authorization: 'token ' + token.authCookie.Value
            Accept: 'application/vnd.vtex.gallery.v0+json'
        return request.get options

    promise.then (data) ->
      appContent = JSON.parse data
      for key, value of appContent
        fs.writeFile './apps/' + key, value.content, (err) ->
          console.log err

        console.log '../../apps/' + key
        console.log value


module.exports = Gallery