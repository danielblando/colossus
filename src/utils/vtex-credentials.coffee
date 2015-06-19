s3Util = require './s3-util'
request = require './request'

class VtexCredentials
  constructor: () ->
    bucket = 'vtex-id'
    path = 'tokens/vtexappkey-appvtex.json'
    @promise = s3Util.getFile bucket, path
    @promise = @promise.then (data) ->
      credentials = JSON.parse data
      token = credentials[0]
      #console.log token.token
      return request.get 'https://vtexid.vtex.com.br/api/vtexid/pub/authenticate/default?user=vtexappkey-appvtex&scope=&pass=' + token.token
  getToken: () ->
    return @promise.then (data) ->
      return JSON.parse(data)


module.exports = new VtexCredentials()