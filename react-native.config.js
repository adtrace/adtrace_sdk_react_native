const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        packageImportPath: 'import io.adtrace.nativemodule.AdTracePackage;',
        packageInstance: 'new AdTracePackage()',
      },
    },
  },
};
