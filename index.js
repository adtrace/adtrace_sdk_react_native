'use strict';

import { 
    NativeEventEmitter,
    NativeModules,
    Platform,
} from 'react-native';

const module_adtrace = NativeModules.AdTrace;

let module_adtrace_emitter = null;
if (Platform.OS === "android") {
    module_adtrace_emitter = new NativeEventEmitter(NativeModules.AdTrace);
} else if (Platform.OS === "ios") {
    module_adtrace_emitter = new NativeEventEmitter(NativeModules.AdtraceEventEmitter);
}

// AdTrace

var AdTrace = {};

AdTrace.create = function(AdTraceConfig) {
    module_adtrace.create(AdTraceConfig);
};

AdTrace.trackEvent = function(AdTraceEvent) {
    module_adtrace.trackEvent(AdTraceEvent);
};

AdTrace.setEnabled = function(enabled) {
    module_adtrace.setEnabled(enabled);
};

AdTrace.isEnabled = function(callback) {
    module_adtrace.isEnabled(callback);
};

AdTrace.setOfflineMode = function(enabled) {
    module_adtrace.setOfflineMode(enabled);
};

AdTrace.setPushToken = function(token) {
    module_adtrace.setPushToken(token);
};

AdTrace.appWillOpenUrl = function(uri) {
    module_adtrace.appWillOpenUrl(uri);
};

AdTrace.sendFirstPackages = function() {
    module_adtrace.sendFirstPackages();
};

AdTrace.addSessionCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    module_adtrace.addSessionCallbackParameter(key, value);
};

AdTrace.addSessionPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    module_adtrace.addSessionPartnerParameter(key, value);
};

AdTrace.removeSessionCallbackParameter = function(key) {
    module_adtrace.removeSessionCallbackParameter(key);
};

AdTrace.removeSessionPartnerParameter = function(key) {
    module_adtrace.removeSessionPartnerParameter(key);
};

AdTrace.resetSessionCallbackParameters = function() {
    module_adtrace.resetSessionCallbackParameters();
};

AdTrace.resetSessionPartnerParameters = function() {
    module_adtrace.resetSessionPartnerParameters();
};

AdTrace.gdprForgetMe = function() {
    module_adtrace.gdprForgetMe();
}

AdTrace.getIdfa = function(callback) {
    module_adtrace.getIdfa(callback);
};

AdTrace.getGoogleAdId = function(callback) {
    module_adtrace.getGoogleAdId(callback);
};

AdTrace.getAdid = function(callback) {
    module_adtrace.getAdid(callback);
};

AdTrace.getAttribution = function(callback) {
    module_adtrace.getAttribution(callback);
};

AdTrace.getAmazonAdId = function(callback) {
    module_adtrace.getAmazonAdId(callback);
};

AdTrace.getSdkVersion = function(callback) {
    module_adtrace.getSdkVersion("react-native1.1.0", callback);
}

AdTrace.setReferrer = function(referrer) {
    module_adtrace.setReferrer(referrer);
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
    module_adtrace.teardown();
};

AdTrace.setTestOptions = function(testOptions) {
    module_adtrace.setTestOptions(testOptions);
};

AdTrace.onResume = function(testParam) {
    if (testParam === null || testParam === undefined || testParam !== 'test') {
        return;
    }
    module_adtrace.onResume();
};

AdTrace.onPause = function(testParam) {
    if (testParam === null || testParam === undefined || testParam !== 'test') {
        return;
    }
    module_adtrace.onPause();
};

// AdTraceConfig

var AdTraceConfig = function(appToken, environment) {
    this.sdkPrefix = "react-native1.0.6";
    this.appToken = appToken;
    this.environment = environment;
    this.logLevel = null;
    this.eventBufferingEnabled = null;
    this.shouldLaunchDeeplink = null;
    this.sendInBackground = null;
    this.enableInstalledApps = null;
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

AdTraceConfig.prototype.setEnableInstalledApps = function(enableInstalledApps) {
    this.enableInstalledApps = enableInstalledApps;
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
        module_adtrace.setAttributionCallbackListener();
        AdTraceConfig.AttributionSubscription = module_adtrace_emitter.addListener(
            'adtrace_attribution', attributionCallbackListener
        );
    }
};

AdTraceConfig.prototype.setEventTrackingSucceededCallbackListener = function(eventTrackingSucceededCallbackListener) {
    if (null == AdTraceConfig.EventTrackingSucceededSubscription) {
        module_adtrace.setEventTrackingSucceededCallbackListener();
        AdTraceConfig.EventTrackingSucceededSubscription = module_adtrace_emitter.addListener(
            'adtrace_eventTrackingSucceeded', eventTrackingSucceededCallbackListener
        );
    }
};

AdTraceConfig.prototype.setEventTrackingFailedCallbackListener = function(eventTrackingFailedCallbackListener) {
    if (null == AdTraceConfig.EventTrackingFailedSubscription) {
        module_adtrace.setEventTrackingFailedCallbackListener();
        AdTraceConfig.EventTrackingFailedSubscription = module_adtrace_emitter.addListener(
            'adtrace_eventTrackingFailed', eventTrackingFailedCallbackListener
        );
    }
};

AdTraceConfig.prototype.setSessionTrackingSucceededCallbackListener = function(sessionTrackingSucceededCallbackListener) {
    if (null == AdTraceConfig.SessionTrackingSucceededSubscription) {
        module_adtrace.setSessionTrackingSucceededCallbackListener();
        AdTraceConfig.SessionTrackingSucceededSubscription = module_adtrace_emitter.addListener(
            'adtrace_sessionTrackingSucceeded', sessionTrackingSucceededCallbackListener
        );
    }
};

AdTraceConfig.prototype.setSessionTrackingFailedCallbackListener = function(sessionTrackingFailedCallbackListener) {
    if (null == AdTraceConfig.SessionTrackingFailedSubscription) {
        module_adtrace.setSessionTrackingFailedCallbackListener();
        AdTraceConfig.SessionTrackingFailedSubscription = module_adtrace_emitter.addListener(
            'adtrace_sessionTrackingFailed', sessionTrackingFailedCallbackListener
        );
    }
};

AdTraceConfig.prototype.setDeferredDeeplinkCallbackListener = function(deferredDeeplinkCallbackListener) {
    if (null == AdTraceConfig.DeferredDeeplinkSubscription) {
        module_adtrace.setDeferredDeeplinkCallbackListener();
        AdTraceConfig.DeferredDeeplinkSubscription = module_adtrace_emitter.addListener(
            'adtrace_deferredDeeplink', deferredDeeplinkCallbackListener
        );
    }
};

// AdTraceEvent

var AdTraceEvent = function(eventToken) {
    this.eventToken = eventToken;
    this.revenue = null;
    this.currency = null;
    this.callbackId = null;
    this.eventValue = null;
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

AdTraceEvent.prototype.setCallbackId = function(callbackId) {
    this.callbackId = callbackId;
};

AdTraceEvent.prototype.setEventValue = function(value) {
    this.eventValue = value;
};

module.exports = { AdTrace, AdTraceEvent, AdTraceConfig }
