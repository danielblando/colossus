fs = require 'fs'
xmldoc = require 'xmldoc'
AWS = require 'aws-sdk'
Q = require 'q';

s3 = {}

class S3Util
  constructor: () ->
    @promise = Q.Promise (resolve, reject, notify) ->
      if process.env.aws_credential_path?
        fs.readFile process.env.aws_credential_path, 'utf8', (err, data) ->
          if not err
            xmlDoc = new xmldoc.XmlDocument data
            jsonDoc = {};
            for item in xmlDoc.children
              jsonDoc[item.name] = item.val.trim()
            AWS.config.update
              accessKeyId: jsonDoc['accesskeyid']
              secretAccessKey: jsonDoc['secretaccesskey']
              sessionToken: jsonDoc['sessiontoken']
              region: 'us-east-1'
          s3 = new AWS.S3();
          resolve AWS.config
      else
        resolve AWS.config
  list: () ->
    @promise.then (data) ->
      params = Bucket: 'vtex-masterdata'
      s3.listObjects params, (err, data) ->
        console.log data
  getFile: (bucket, path) ->
    params =
      Bucket: bucket
      Key: path
    @promise.then () ->
      Q.Promise (resolve, reject, notify) ->
        s3.getObject params, (err, data) ->
          if err
            reject err
            return
          resolve data.Body.toString()





module.exports = new S3Util()