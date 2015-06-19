module.exports = class ServiceError extends Error
  constructor: (@statusCode, @message) ->
    super @message