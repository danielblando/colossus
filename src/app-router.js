// Generated by CoffeeScript 1.7.1
(function() {
  var AppRouter, vtexCredentials;

  vtexCredentials = require('./utils/vtex-credentials');

  AppRouter = (function() {
    function AppRouter(router) {
      this.router = router;
      this.router.route('/:accountName/:appName/*').get(function(req, res, next) {
        var accountName, appName, appPath, application;
        accountName = req.params.accountName;
        appName = req.params.appName;
        appPath = '../apps/' + accountName + '/' + appName;
        application = require(appPath);
        return application.run(accountName, appName, req, res, next);
      });
    }

    return AppRouter;

  })();

  module.exports = function(router) {
    return new AppRouter(router);
  };

}).call(this);

//# sourceMappingURL=app-router.map
