'use strict';

import { 
    NativeEventEmitter,
    NativeModules,
    Platform,
} from 'react-native';

const module_adtrace_oaid = NativeModules.AdTraceOaid;

var AdTraceOaid = {};

AdTraceOaid.readOaid = function() {
    if (Platform.OS === "android") {
        module_adtrace_oaid.readOaid();
    }
};

AdTraceOaid.doNotReadOaid = function() {
    if (Platform.OS === "android") {
        module_adtrace_oaid.doNotReadOaid();
    }
};

module.exports = { AdTraceOaid }
