'use strict';

import { 
    NativeEventEmitter,
    NativeModules,
    Platform,
} from 'react-native';

const module_AdTrace = NativeModules.AdTrace;

let module_AdTrace_emitter = null;
if (Platform.OS === "android") {
    module_AdTrace_emitter = new NativeEventEmitter(NativeModules.AdTrace);
} else if (Platform.OS === "ios") {
    module_AdTrace_emitter = new NativeEventEmitter(NativeModules.AdTraceEventEmitter);
}

// AdTrace

var AdTrace = {};

AdTrace.create = function(AdTraceConfig) {
    module_AdTrace.create(AdTraceConfig);
};

AdTrace.trackEvent = function(AdTraceEvent) {
    module_AdTrace.trackEvent(AdTraceEvent);
};

AdTrace.setEnabled = function(enabled) {
    module_AdTrace.setEnabled(enabled);
};

AdTrace.isEnabled = function(callback) {
    module_AdTrace.isEnabled(callback);
};

AdTrace.setOfflineMode = function(enabled) {
    module_AdTrace.setOfflineMode(enabled);
};

AdTrace.setPushToken = function(token) {
    module_AdTrace.setPushToken(token);
};

AdTrace.appWillOpenUrl = function(uri) {
    module_AdTrace.appWillOpenUrl(uri);
};

AdTrace.sendFirstPackages = function() {
    module_AdTrace.sendFirstPackages();
};

AdTrace.addSessionCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    module_AdTrace.addSessionCallbackParameter(key, value);
};

AdTrace.addSessionPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    module_AdTrace.addSessionPartnerParameter(key, value);
};

AdTrace.removeSessionCallbackParameter = function(key) {
    module_AdTrace.removeSessionCallbackParameter(key);
};

AdTrace.removeSessionPartnerParameter = function(key) {
    module_AdTrace.removeSessionPartnerParameter(key);
};

AdTrace.resetSessionCallbackParameters = function() {
    module_AdTrace.resetSessionCallbackParameters();
};

AdTrace.resetSessionPartnerParameters = function() {
    module_AdTrace.resetSessionPartnerParameters();
};

AdTrace.gdprForgetMe = function() {
    module_AdTrace.gdprForgetMe();
}

AdTrace.getIdfa = function(callback) {
    module_AdTrace.getIdfa(callback);
};

AdTrace.getGoogleAdId = function(callback) {
    module_AdTrace.getGoogleAdId(callback);
};

AdTrace.getAdid = function(callback) {
    module_AdTrace.getAdid(callback);
};

AdTrace.getAttribution = function(callback) {
    module_AdTrace.getAttribution(callback);
};

AdTrace.getAmazonAdId = function(callback) {
    module_AdTrace.getAmazonAdId(callback);
};

AdTrace.getSdkVersion = function(callback) {
    module_AdTrace.getSdkVersion("react-native4.17.2", callback);
}

AdTrace.setReferrer = function(referrer) {
    module_AdTrace.setReferrer(referrer);
};

AdTrace.componentWillUnmount = function() {
    if (AdTraceConfig.AttributionSubscription != null) {
        AdTraceConfig.AttributionSubscription.remove();
        AdTraceConfig.AttributionSubscription = null;
    }

    if (AdTraceConfig.EventTrackingSucceededSubscription != null) {
        AdTraceConfig.EventTrackingSucceededSubscription.remove();
        AdTraceConfig.EventTrackingSucceededSubscription = null;
    }

    if (AdTraceConfig.EventTrackingFailedSubscription != null) {
        AdTraceConfig.EventTrackingFailedSubscription.remove();
        AdTraceConfig.EventTrackingFailedSubscription = null;
    }

    if (AdTraceConfig.SessionTrackingSucceededSubscription != null) {
        AdTraceConfig.SessionTrackingSucceededSubscription.remove();
        AdTraceConfig.SessionTrackingSucceededSubscription = null;
    }

    if (AdTraceConfig.SessionTrackingFailedSubscription != null) {
        AdTraceConfig.SessionTrackingFailedSubscription.remove();
        AdTraceConfig.SessionTrackingFailedSubscription = null;
    }

    if (AdTraceConfig.DeferredDeeplinkSubscription != null) {
        AdTraceConfig.DeferredDeeplinkSubscription.remove();
        AdTraceConfig.DeferredDeeplinkSubscription = null;
    }
};

// =========================================== //
// AdTrace methods used for SDK testing only.   //
// Do NOT use any of these in production code. //
// =========================================== //

AdTrace.teardown = function(testParam) {
    if (testParam === null || testParam === undefined || testParam !== 'test') {
        return;
    }
    AdTrace.componentWillUnmount();
    module_AdTrace.teardown();
};

AdTrace.setTestOptions = function(testOptions) {
    module_AdTrace.setTestOptions(testOptions);
};

AdTrace.onResume = function(testParam) {
    if (testParam === null || testParam === undefined || testParam !== 'test') {
        return;
    }
    module_AdTrace.onResume();
};

AdTrace.onPause = function(testParam) {
    if (testParam === null || testParam === undefined || testParam !== 'test') {
        return;
    }
    module_AdTrace.onPause();
};

// AdTraceConfig

var AdTraceConfig = function(appToken, environment) {
    this.sdkPrefix = "react-native1.0.0";
    this.appToken = appToken;
    this.environment = environment;
    this.logLevel = null;
    this.eventBufferingEnabled = null;
    this.shouldLaunchDeeplink = null;
    this.sendInBackground = null;
    this.delayStart = null;
    this.userAgent = null;
    this.isDeviceKnown = null;
    this.defaultTracker = null;
    this.secretId = null;
    this.info1 = null;
    this.info2 = null;
    this.info3 = null;
    this.info4 = null;
    // Android only
    this.processName = null;
    this.readMobileEquipmentIdentity = null;
};

AdTraceConfig.EnvironmentSandbox = "sandbox";
AdTraceConfig.EnvironmentProduction = "production";
AdTraceConfig.LogLevelVerbose = "VERBOSE";
AdTraceConfig.LogLevelDebug = "DEBUG";
AdTraceConfig.LogLevelInfo = "INFO";
AdTraceConfig.LogLevelWarn = "WARN";
AdTraceConfig.LogLevelError = "ERROR";
AdTraceConfig.LogLevelAssert = "ASSERT";
AdTraceConfig.LogLevelSuppress = "SUPPRESS";
AdTraceConfig.AttributionSubscription = null;
AdTraceConfig.EventTrackingSucceededSubscription = null;
AdTraceConfig.EventTrackingFailedSubscription = null;
AdTraceConfig.SessionTrackingSucceededSubscription = null;
AdTraceConfig.SessionTrackingFailedSubscription = null;
AdTraceConfig.DeferredDeeplinkSubscription = null;

AdTraceConfig.prototype.setEventBufferingEnabled = function(isEnabled) {
    this.eventBufferingEnabled = isEnabled;
};

AdTraceConfig.prototype.setLogLevel = function(logLevel) {
    this.logLevel = logLevel;
};

AdTraceConfig.prototype.setProcessName = function(processName) {
    this.processName = processName;
};

AdTraceConfig.prototype.setDefaultTracker = function(defaultTracker) {
    this.defaultTracker = defaultTracker;
};

AdTraceConfig.prototype.setUserAgent = function(userAgent) {
    this.userAgent = userAgent;
};

AdTraceConfig.prototype.setAppSecret = function(secretId, info1, info2, info3, info4) {
    if (secretId != null) {
        this.secretId = secretId.toString();
    }
    if (info1 != null) {
        this.info1 = info1.toString();
    }
    if (info2 != null) {
        this.info2 = info2.toString();
    }
    if (info3 != null) {
        this.info3 = info3.toString();
    }
    if (info4 != null) {
        this.info4 = info4.toString();
    }
};

AdTraceConfig.prototype.setDelayStart = function(delayStart) {
    this.delayStart = delayStart;
};

AdTraceConfig.prototype.setSendInBackground = function(sendInBackground) {
    this.sendInBackground = sendInBackground;
};

AdTraceConfig.prototype.setDeviceKnown = function(isDeviceKnown) {
    this.isDeviceKnown = isDeviceKnown;
};

AdTraceConfig.prototype.setSdkPrefix = function(sdkPrefix) {
    this.sdkPrefix = sdkPrefix;
};

AdTraceConfig.prototype.setReadMobileEquipmentIdentity = function(readMobileEquipmentIdentity) {
    // this.readMobileEquipmentIdentity = readMobileEquipmentIdentity;
};

AdTraceConfig.prototype.setShouldLaunchDeeplink = function(shouldLaunchDeeplink) {
    this.shouldLaunchDeeplink = shouldLaunchDeeplink;
};

AdTraceConfig.prototype.setAttributionCallbackListener = function(attributionCallbackListener) {
    if (null == AdTraceConfig.AttributionSubscription) {
        module_AdTrace.setAttributionCallbackListener();
        AdTraceConfig.AttributionSubscription = module_AdTrace_emitter.addListener(
            'AdTrace_attribution', attributionCallbackListener
        );
    }
};

AdTraceConfig.prototype.setEventTrackingSucceededCallbackListener = function(eventTrackingSucceededCallbackListener) {
    if (null == AdTraceConfig.EventTrackingSucceededSubscription) {
        module_AdTrace.setEventTrackingSucceededCallbackListener();
        AdTraceConfig.EventTrackingSucceededSubscription = module_AdTrace_emitter.addListener(
            'AdTrace_eventTrackingSucceeded', eventTrackingSucceededCallbackListener
        );
    }
};

AdTraceConfig.prototype.setEventTrackingFailedCallbackListener = function(eventTrackingFailedCallbackListener) {
    if (null == AdTraceConfig.EventTrackingFailedSubscription) {
        module_AdTrace.setEventTrackingFailedCallbackListener();
        AdTraceConfig.EventTrackingFailedSubscription = module_AdTrace_emitter.addListener(
            'AdTrace_eventTrackingFailed', eventTrackingFailedCallbackListener
        );
    }
};

AdTraceConfig.prototype.setSessionTrackingSucceededCallbackListener = function(sessionTrackingSucceededCallbackListener) {
    if (null == AdTraceConfig.SessionTrackingSucceededSubscription) {
        module_AdTrace.setSessionTrackingSucceededCallbackListener();
        AdTraceConfig.SessionTrackingSucceededSubscription = module_AdTrace_emitter.addListener(
            'AdTrace_sessionTrackingSucceeded', sessionTrackingSucceededCallbackListener
        );
    }
};

AdTraceConfig.prototype.setSessionTrackingFailedCallbackListener = function(sessionTrackingFailedCallbackListener) {
    if (null == AdTraceConfig.SessionTrackingFailedSubscription) {
        module_AdTrace.setSessionTrackingFailedCallbackListener();
        AdTraceConfig.SessionTrackingFailedSubscription = module_AdTrace_emitter.addListener(
            'AdTrace_sessionTrackingFailed', sessionTrackingFailedCallbackListener
        );
    }
};

AdTraceConfig.prototype.setDeferredDeeplinkCallbackListener = function(deferredDeeplinkCallbackListener) {
    if (null == AdTraceConfig.DeferredDeeplinkSubscription) {
        module_AdTrace.setDeferredDeeplinkCallbackListener();
        AdTraceConfig.DeferredDeeplinkSubscription = module_AdTrace_emitter.addListener(
            'AdTrace_deferredDeeplink', deferredDeeplinkCallbackListener
        );
    }
};

// AdTraceEvent

var AdTraceEvent = function(eventToken) {
    this.eventToken = eventToken;
    this.revenue = null;
    this.currency = null;
    this.transactionId = null;
    this.callbackId = null;
    this.callbackParameters = {};
    this.partnerParameters = {};
};

AdTraceEvent.prototype.setRevenue = function(revenue, currency) {
    if (revenue != null) {
        this.revenue = revenue.toString();
        this.currency = currency;
    }
};

AdTraceEvent.prototype.addCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.callbackParameters[key] = value;
};

AdTraceEvent.prototype.addPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.partnerParameters[key] = value;
};

AdTraceEvent.prototype.setTransactionId = function(transactionId) {
    this.transactionId = transactionId;
};

AdTraceEvent.prototype.setCallbackId = function(callbackId) {
    this.callbackId = callbackId;
};

module.exports = { AdTrace, AdTraceEvent, AdTraceConfig }
