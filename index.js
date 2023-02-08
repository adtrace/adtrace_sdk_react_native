'use strict';

import { 
    NativeEventEmitter,
    NativeModules,
    Platform,
} from 'react-native';

let module_adtrace =null;
let module_adtrace_emitter = null;

if (Platform.OS === "android") {
    module_adtrace = NativeModules.AdTrace;
    module_adtrace_emitter = new NativeEventEmitter(NativeModules.AdTrace);
} else if (Platform.OS === "ios") {
    module_adtrace = NativeModules.Adtrace;
    module_adtrace_emitter = new NativeEventEmitter(NativeModules.AdtraceEventEmitter);
}

// AdTrace

var AdTrace = {};

AdTrace.create = function(adtraceConfig) {
    module_adtrace.create(adtraceConfig);
};

AdTrace.trackEvent = function(adtraceEvent) {
    module_adtrace.trackEvent(adtraceEvent);
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

AdTrace.trackAdRevenue = function(source, payload = undefined) {
    if (payload === undefined) {
        // new API
        module_adtrace.trackAdRevenueNew(source);
    } else {
        // old API
        module_adtrace.trackAdRevenue(source, payload);
    }
};

AdTrace.trackAppStoreSubscription = function(subscription) {
    if (Platform.OS === "ios") {
        module_adtrace.trackAppStoreSubscription(subscription);
    }
};

AdTrace.trackPlayStoreSubscription = function(subscription) {
    if (Platform.OS === "android") {
        module_adtrace.trackPlayStoreSubscription(subscription);
    }
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
};

AdTrace.disableThirdPartySharing = function() {
    module_adtrace.disableThirdPartySharing();
};

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

// AdTrace.getAmazonAdId = function(callback) {
    // module_adtrace.getAmazonAdId(callback);
// };

AdTrace.getSdkVersion = function(callback) {
    module_adtrace.getSdkVersion("react-native2.1.0", callback);
};

AdTrace.setReferrer = function(referrer) {
    if (Platform.OS === "android") {
        module_adtrace.setReferrer(referrer);
    }
};

AdTrace.convertUniversalLink = function(url, scheme, callback) {
    if (!url || !scheme || !callback) {
        return;
    }
    module_adtrace.convertUniversalLink(url, scheme, callback);
};

AdTrace.requestTrackingAuthorizationWithCompletionHandler = function(callback) {
    module_adtrace.requestTrackingAuthorizationWithCompletionHandler(callback);
};

AdTrace.updateConversionValue = function(conversionValue) {
    module_adtrace.updateConversionValue(conversionValue);
};

AdTrace.updateConversionValueWithErrorCallback = function(conversionValue, callback) {
    module_adtrace.updateConversionValueWithErrorCallback(conversionValue, callback);
};

AdTrace.updateConversionValueWithSkad4ErrorCallback = function(conversionValue, coarseValue, lockWindow, callback) {
    module_adtrace.updateConversionValueWithSkad4ErrorCallback(conversionValue, coarseValue, lockWindow, callback);
};

AdTrace.requestTrackingAuthorizationWithCompletionHandler = function(callback) {
    module_adtrace.requestTrackingAuthorizationWithCompletionHandler(callback);
};

AdTrace.updateConversionValue = function(conversionValue) {
    module_adtrace.updateConversionValue(conversionValue);
};

AdTrace.getAppTrackingAuthorizationStatus = function(callback) {
    module_adtrace.getAppTrackingAuthorizationStatus(callback);
};

AdTrace.trackThirdPartySharing = function(adtraceThirdPartySharing) {
    module_adtrace.trackThirdPartySharing(adtraceThirdPartySharing);
};

AdTrace.trackMeasurementConsent = function(measurementConsent) {
    module_adtrace.trackMeasurementConsent(measurementConsent);
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
    this.sdkPrefix = "react-native2.1.0";
    this.appToken = appToken;
    this.environment = environment;
    this.logLevel = null;
    this.eventBufferingEnabled = null;
    this.shouldLaunchDeeplink = null;
    this.sendInBackground = null;
    this.needsCost = null;
    this.delayStart = null;
    this.userAgent = null;
    this.isDeviceKnown = null;
    this.defaultTracker = null;
    this.externalDeviceId = null;
    this.secretId = null;
    this.info1 = null;
    this.info2 = null;
    this.info3 = null;
    this.info4 = null;
    this.urlStrategy = null;
    this.coppaCompliantEnabled = null;
    // Android only
    this.processName = null;
    this.readMobileEquipmentIdentity = null;
    this.preinstallTrackingEnabled = null;
    this.preinstallFilePath = null;
    this.playStoreKidsAppEnabled = null;
    // iOS only
    this.allowiAdInfoReading = null;
    this.allowAdServicesInfoReading = null;
    this.allowIdfaReading = null;
    this.skAdNetworkHandling = null;
    this.linkMeEnabled = null;
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
AdTraceConfig.ConversionValueUpdatedSubscription = null;
AdTraceConfig.Skad4ConversionValueUpdatedSubscription = null;

AdTraceConfig.UrlStrategyChina = "china";
AdTraceConfig.UrlStrategyIndia = "india";

AdTraceConfig.DataResidencyEU = "data-residency-eu";
AdTraceConfig.DataResidencyTR = "data-residency-tr";
AdTraceConfig.DataResidencyUS = "data-residency-us";

AdTraceConfig.AdRevenueSourceAppLovinMAX = "applovin_max_sdk";
AdTraceConfig.AdRevenueSourceMopub = "mopub";
AdTraceConfig.AdRevenueSourceAdmob = "admob_sdk";
AdTraceConfig.AdRevenueSourceIronSource = "ironsource_sdk";
AdTraceConfig.AdRevenueSourceAdmost = "admost_sdk";
AdTraceConfig.AdRevenueSourcePublisher = "publisher_sdk";

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

AdTraceConfig.prototype.setExternalDeviceId = function(externalDeviceId) {
    this.externalDeviceId = externalDeviceId;
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

AdTraceConfig.prototype.setNeedsCost = function(needsCost) {
    this.needsCost = needsCost;
};

AdTraceConfig.prototype.setSdkPrefix = function(sdkPrefix) {
    this.sdkPrefix = sdkPrefix;
};

AdTraceConfig.prototype.setUrlStrategy = function(urlStrategy) {
    this.urlStrategy = urlStrategy;
};

AdTraceConfig.prototype.setCoppaCompliantEnabled = function(coppaCompliantEnabled) {
    this.coppaCompliantEnabled = coppaCompliantEnabled;
};

AdTraceConfig.prototype.setReadMobileEquipmentIdentity = function(readMobileEquipmentIdentity) {
    // this.readMobileEquipmentIdentity = readMobileEquipmentIdentity;
};

AdTraceConfig.prototype.setPreinstallTrackingEnabled = function(isEnabled) {
    this.preinstallTrackingEnabled = isEnabled;
};

AdTraceConfig.prototype.setPreinstallFilePath = function(preinstallFilePath) {
    this.preinstallFilePath = preinstallFilePath;
};

AdTraceConfig.prototype.setPlayStoreKidsAppEnabled = function(isEnabled) {
    this.playStoreKidsAppEnabled = isEnabled;
};

AdTraceConfig.prototype.setAllowiAdInfoReading = function(allowiAdInfoReading) {
    this.allowiAdInfoReading = allowiAdInfoReading;
};

AdTraceConfig.prototype.setAllowAdServicesInfoReading = function(allowAdServicesInfoReading) {
    this.allowAdServicesInfoReading = allowAdServicesInfoReading;
};

AdTraceConfig.prototype.setAllowIdfaReading = function(allowIdfaReading) {
    this.allowIdfaReading = allowIdfaReading;
};

AdTraceConfig.prototype.setShouldLaunchDeeplink = function(shouldLaunchDeeplink) {
    this.shouldLaunchDeeplink = shouldLaunchDeeplink;
};

AdTraceConfig.prototype.deactivateSKAdNetworkHandling = function() {
    this.skAdNetworkHandling = false;
};

AdTraceConfig.prototype.setLinkMeEnabled = function(linkMeEnabled) {
    this.linkMeEnabled = linkMeEnabled;
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

AdTraceConfig.prototype.setConversionValueUpdatedCallbackListener = function(conversionValueUpdatedCallbackListener) {
    if (Platform.OS === "ios") {
        if (null == AdTraceConfig.ConversionValueUpdatedSubscription) {
            module_adtrace.setConversionValueUpdatedCallbackListener();
            AdTraceConfig.ConversionValueUpdatedSubscription = module_adtrace_emitter.addListener(
                'adtrace_conversionValueUpdated', conversionValueUpdatedCallbackListener
            );
        }
    }
};

AdTraceConfig.prototype.setSkad4ConversionValueUpdatedCallbackListener = function(skad4ConversionValueUpdatedCallbackListener) {
    if (Platform.OS === "ios") {
        if (null == AdTraceConfig.ConversionValueUpdatedSubscription) {
            module_adtrace.setConversionValueUpdatedCallbackListener();
            AdTraceConfig.ConversionValueUpdatedSubscription = module_adtrace_emitter.addListener(
                'adtrace_conversionValueUpdated', conversionValueUpdatedCallbackListener
            );
        }
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
    this.valueParameters = {};
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

AdTraceEvent.prototype.addEventParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
         this.valueParameters[key] = value;
};

AdTraceEvent.prototype.setTransactionId = function(transactionId) {
    this.transactionId = transactionId;
};

AdTraceEvent.prototype.setCallbackId = function(callbackId) {
    this.callbackId = callbackId;
};

// AdTraceAppStoreSubscription

var AdTraceAppStoreSubscription = function(price, currency, transactionId, receipt) {
    this.price = price;
    this.currency = currency;
    this.transactionId = transactionId;
    this.receipt = receipt;
    this.transactionDate = null;
    this.salesRegion = null;
    this.callbackParameters = {};
    this.partnerParameters = {};
};

AdTraceAppStoreSubscription.prototype.setTransactionDate = function(transactionDate) {
    this.transactionDate = transactionDate;
};

AdTraceAppStoreSubscription.prototype.setSalesRegion = function(salesRegion) {
    this.salesRegion = salesRegion;
};

AdTraceAppStoreSubscription.prototype.addCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.callbackParameters[key] = value;
};

AdTraceAppStoreSubscription.prototype.addPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.partnerParameters[key] = value;
};

// AdTracePlayStoreSubscription

var AdTracePlayStoreSubscription = function(price, currency, sku, orderId, signature, purchaseToken) {
    this.price = price;
    this.currency = currency;
    this.sku = sku;
    this.orderId = orderId;
    this.signature = signature;
    this.purchaseToken = purchaseToken;
    this.purchaseTime = null;
    this.callbackParameters = {};
    this.partnerParameters = {};
};

AdTracePlayStoreSubscription.prototype.setPurchaseTime = function(purchaseTime) {
    this.purchaseTime = purchaseTime;
};

AdTracePlayStoreSubscription.prototype.addCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.callbackParameters[key] = value;
};

AdTracePlayStoreSubscription.prototype.addPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.partnerParameters[key] = value;
};

// AdTraceThirdPartySharing

var AdTraceThirdPartySharing = function(isEnabled) {
    this.isEnabled = isEnabled;
    this.granularOptions = [];
    this.partnerSharingSettings = [];
};

AdTraceThirdPartySharing.prototype.addGranularOption = function(partnerName, key, value) {
    if (typeof partnerName !== 'string' || typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.granularOptions.push(partnerName);
    this.granularOptions.push(key);
    this.granularOptions.push(value);
};

AdTraceThirdPartySharing.prototype.addPartnerSharingSetting = function(partnerName, key, value) {
    if (typeof partnerName !== 'string' || typeof key !== 'string' || typeof value !== 'boolean') {
        return;
    }
    this.partnerSharingSettings.push(partnerName);
    this.partnerSharingSettings.push(key);
    this.partnerSharingSettings.push(value);
};

// AdTraceAdRevenue

var AdTraceAdRevenue = function(source) {
    this.source = source;
    this.revenue = null;
    this.currency = null;
    this.adImpressionsCount = null;
    this.adRevenueNetwork = null;
    this.adRevenueUnit = null;
    this.adRevenuePlacement = null;
    this.callbackParameters = {};
    this.partnerParameters = {};
};

AdTraceAdRevenue.prototype.setRevenue = function(revenue, currency) {
    if (revenue != null) {
        this.revenue = revenue.toString();
        this.currency = currency;
    }
};

AdTraceAdRevenue.prototype.setAdImpressionsCount = function(adImpressionsCount) {
    this.adImpressionsCount = adImpressionsCount.toString();
};

AdTraceAdRevenue.prototype.setAdRevenueNetwork = function(adRevenueNetwork) {
    this.adRevenueNetwork = adRevenueNetwork;
};

AdTraceAdRevenue.prototype.setAdRevenueUnit = function(adRevenueUnit) {
    this.adRevenueUnit = adRevenueUnit;
};

AdTraceAdRevenue.prototype.setAdRevenuePlacement = function(adRevenuePlacement) {
    this.adRevenuePlacement = adRevenuePlacement;
};

AdTraceAdRevenue.prototype.addCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.callbackParameters[key] = value;
};

AdTraceAdRevenue.prototype.addPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        return;
    }
    this.partnerParameters[key] = value;
};

module.exports = {
    AdTrace,
    AdTraceEvent,
    AdTraceConfig,
    AdTraceAppStoreSubscription,
    AdTracePlayStoreSubscription,
    AdTraceThirdPartySharing,
    AdTraceAdRevenue
}
