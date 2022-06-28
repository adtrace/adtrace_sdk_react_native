const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { podspecPath: path.join(__dirname, 'react-native-adtrace.podspec') },
      android: {
        packageImportPath: 'import io.adtrace.nativemodule.AdTracePackage;',
        packageInstance: 'new AdTracePackage()',
      },
    },
  },
};
