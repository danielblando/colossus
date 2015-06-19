// Generated by CoffeeScript 1.7.1
(function() {
  var AppRouter, Gallery, fresh, pkg;

  Gallery = require('./lib/gallery');

  fresh = require('fresh-require');

  pkg = require('../package.json');

  AppRouter = (function() {
    function AppRouter(router) {
      this.router = router;
      this.router.route('/:accountName/:appName/*').get(function(req, res, next) {
        var accountName, appName, gallery, promise, sandBox, version;
        accountName = req.params.accountName;
        appName = req.params.appName;
        sandBox = req.headers['x-vtex-sandbox'];
        version = req.headers['x-vtex-env-version'];
        gallery = new Gallery(accountName);
        if ((version != null) || (sandBox != null)) {
          promise = gallery.downloadFilesFromCustomApp(appName, version, sandBox);
        } else {
          promise = gallery.downloadFilesFromDefaultApp(appName);
        }
        promise = promise.then(function(path) {
          var appPath, application;
          appPath = path;
          if (sandBox) {
            application = require('../' + appPath + 'colossus');
          } else {
            application = fresh('../' + appPath + 'colossus', require);
          }
          return application.run(accountName, appName, req, res, next);
        });
        return promise["catch"](function(err) {
          return next(err);
        });
      });
      this.router.route('/healthcheck').get(function(req, res, next) {
        return res.json("ok");
      });
      this.router.route('/meta/whoami').get(function(req, res, next) {
        var whoami;
        whoami = {
          app: pkg.name,
          appShortName: pkg.name,
          version: pkg.version,
          roots: pkg.paths,
          hosts: pkg.hosts
        };
        return res.json(whoami);
      });
    }

    return AppRouter;

  })();

  module.exports = function(router) {
    return new AppRouter(router);
  };

}).call(this);

//# sourceMappingURL=app-router.map
