//
//  AdTrace.java
//  AdTrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

package io.adtrace.nativemodule;

import android.net.Uri;
import android.util.Log;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Map.Entry;
import javax.annotation.Nullable;
import org.json.JSONObject;
import org.json.JSONException;
import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.*;
import io.adtrace.sdk.*;

public class AdTrace extends ReactContextBaseJavaModule implements LifecycleEventListener,
                OnAttributionChangedListener,
                OnEventTrackingSucceededListener,
                OnEventTrackingFailedListener,
                OnSessionTrackingSucceededListener,
                OnSessionTrackingFailedListener,
                OnDeeplinkResponseListener {
    private static String TAG = "AdTraceBridge";
    private boolean attributionCallback;
    private boolean eventTrackingSucceededCallback;
    private boolean eventTrackingFailedCallback;
    private boolean sessionTrackingSucceededCallback;
    private boolean sessionTrackingFailedCallback;
    private boolean deferredDeeplinkCallback;
    private boolean shouldLaunchDeeplink = true;

    public AdTrace(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "AdTrace";
    }

    @Override
    public void initialize() {
        getReactApplicationContext().addLifecycleEventListener(this);
    }

    @Override
    public void onHostPause() {
        io.adtrace.sdk.AdTrace.onPause();
    }

    @Override
    public void onHostResume() {
        io.adtrace.sdk.AdTrace.onResume();
    }

    @Override
    public void onHostDestroy() {}

    @Override
    public void onAttributionChanged(AdTraceAttribution attribution) {
        sendEvent(getReactApplicationContext(), "adtrace_attribution", AdTraceUtil.attributionToMap(attribution));
    }

    @Override
    public void onFinishedEventTrackingSucceeded(AdTraceEventSuccess event) {
        sendEvent(getReactApplicationContext(), "adtrace_eventTrackingSucceeded", AdTraceUtil.eventSuccessToMap(event));
    }

    @Override
    public void onFinishedEventTrackingFailed(AdTraceEventFailure event) {
        sendEvent(getReactApplicationContext(), "adtrace_eventTrackingFailed", AdTraceUtil.eventFailureToMap(event));
    }

    @Override
    public void onFinishedSessionTrackingSucceeded(AdTraceSessionSuccess session) {
        sendEvent(getReactApplicationContext(), "adtrace_sessionTrackingSucceeded", AdTraceUtil.sessionSuccessToMap(session));
    }

    @Override
    public void onFinishedSessionTrackingFailed(AdTraceSessionFailure session) {
        sendEvent(getReactApplicationContext(), "adtrace_sessionTrackingFailed", AdTraceUtil.sessionFailureToMap(session));
    }

    @Override
    public boolean launchReceivedDeeplink(Uri uri) {
        sendEvent(getReactApplicationContext(), "adtrace_deferredDeeplink", AdTraceUtil.deferredDeeplinkToMap(uri));
        return this.shouldLaunchDeeplink;
    }

    @ReactMethod
    public void create(ReadableMap mapConfig) {
        if (mapConfig == null) {
            return;
        }

        String appToken = null;
        String environment = null;
        String logLevel = null;
        String sdkPrefix = null;
        String userAgent = null;
        String processName = null;
        String defaultTracker = null;
        String externalDeviceId = null;
        String urlStrategy = null;
        String preinstallFilePath = null;
        long secretId  = 0L;
        long info1 = 0L;
        long info2 = 0L;
        long info3 = 0L;
        long info4 = 0L;
        double delayStart = 0.0;
        boolean isDeviceKnown = false;
        boolean sendInBackground = false;
        boolean isLogLevelSuppress = false;
        boolean shouldLaunchDeeplink = false;
        boolean eventBufferingEnabled = false;
        boolean readMobileEquipmentIdentity = false;
        boolean preinstallTrackingEnabled = false;
        boolean needsCost = false;
        boolean playStoreKidsAppEnabled = false;
        boolean coppaCompliantEnabled = false;

        // Suppress log level.
        if (checkKey(mapConfig, "logLevel")) {
            logLevel = mapConfig.getString("logLevel");
            if (logLevel.equals("SUPPRESS")) {
                isLogLevelSuppress = true;
            }
        }

        // App token.
        if (checkKey(mapConfig, "appToken")) {
            appToken = mapConfig.getString("appToken");
        }

        // Environment.
        if (checkKey(mapConfig, "environment")) {
            environment = mapConfig.getString("environment");
        }

        final AdTraceConfig adtraceConfig = new AdTraceConfig(getReactApplicationContext(), appToken, environment, isLogLevelSuppress);
        if (!adtraceConfig.isValid()) {
            return;
        }

        // Log level.
        if (checkKey(mapConfig, "logLevel")) {
            logLevel = mapConfig.getString("logLevel");
            if (logLevel.equals("VERBOSE")) {
                adtraceConfig.setLogLevel(LogLevel.VERBOSE);
            } else if (logLevel.equals("DEBUG")) {
                adtraceConfig.setLogLevel(LogLevel.DEBUG);
            } else if (logLevel.equals("INFO")) {
                adtraceConfig.setLogLevel(LogLevel.INFO);
            } else if (logLevel.equals("WARN")) {
                adtraceConfig.setLogLevel(LogLevel.WARN);
            } else if (logLevel.equals("ERROR")) {
                adtraceConfig.setLogLevel(LogLevel.ERROR);
            } else if (logLevel.equals("ASSERT")) {
                adtraceConfig.setLogLevel(LogLevel.ASSERT);
            } else if (logLevel.equals("SUPPRESS")) {
                adtraceConfig.setLogLevel(LogLevel.SUPRESS);
            } else {
                adtraceConfig.setLogLevel(LogLevel.INFO);
            }
        }

        // Event buffering.
        if (checkKey(mapConfig, "eventBufferingEnabled")) {
            eventBufferingEnabled = mapConfig.getBoolean("eventBufferingEnabled");
            adtraceConfig.setEventBufferingEnabled(eventBufferingEnabled);
        }

        // SDK prefix.
        if (checkKey(mapConfig, "sdkPrefix")) {
            sdkPrefix = mapConfig.getString("sdkPrefix");
            adtraceConfig.setSdkPrefix(sdkPrefix);
        }

        // Main process name.
        if (checkKey(mapConfig, "processName")) {
            processName = mapConfig.getString("processName");
            adtraceConfig.setProcessName(processName);
        }

        // Default tracker.
        if (checkKey(mapConfig, "defaultTracker")) {
            defaultTracker = mapConfig.getString("defaultTracker");
            adtraceConfig.setDefaultTracker(defaultTracker);
        }

        // External device ID.
        if (checkKey(mapConfig, "externalDeviceId")) {
            externalDeviceId = mapConfig.getString("externalDeviceId");
            adtraceConfig.setExternalDeviceId(externalDeviceId);
        }

        // URL strategy.
        if (checkKey(mapConfig, "urlStrategy")) {
            urlStrategy = mapConfig.getString("urlStrategy");
            if (urlStrategy.equalsIgnoreCase("china")) {
                adtraceConfig.setUrlStrategy(AdTraceConfig.URL_STRATEGY_CHINA);
            } else if (urlStrategy.equalsIgnoreCase("india")) {
                adtraceConfig.setUrlStrategy(AdTraceConfig.URL_STRATEGY_INDIA);
            } else if (urlStrategy.equalsIgnoreCase("data-residency-eu")) {
                adtraceConfig.setUrlStrategy(AdTraceConfig.DATA_RESIDENCY_EU);
            } else if (urlStrategy.equalsIgnoreCase("data-residency-us")) {
                adtraceConfig.setUrlStrategy(AdTraceConfig.DATA_RESIDENCY_US);
            } else if (urlStrategy.equalsIgnoreCase("data-residency-tr")) {
                adtraceConfig.setUrlStrategy(AdTraceConfig.DATA_RESIDENCY_TR);
            }
        }

        // User agent.
        if (checkKey(mapConfig, "userAgent")) {
            userAgent = mapConfig.getString("userAgent");
            adtraceConfig.setUserAgent(userAgent);
        }

        // Preinstall file path.
        if (checkKey(mapConfig, "preinstallFilePath")) {
            preinstallFilePath = mapConfig.getString("preinstallFilePath");
            adtraceConfig.setPreinstallFilePath(preinstallFilePath);
        }

        // App secret.
        if (checkKey(mapConfig, "secretId")
                && checkKey(mapConfig, "info1")
                && checkKey(mapConfig, "info2")
                && checkKey(mapConfig, "info3")
                && checkKey(mapConfig, "info4")) {
            try {
                secretId = Long.parseLong(mapConfig.getString("secretId"), 10);
                info1 = Long.parseLong(mapConfig.getString("info1"), 10);
                info2 = Long.parseLong(mapConfig.getString("info2"), 10);
                info3 = Long.parseLong(mapConfig.getString("info3"), 10);
                info4 = Long.parseLong(mapConfig.getString("info4"), 10);
                adtraceConfig.setAppSecret(secretId, info1, info2, info3, info4);
            } catch (NumberFormatException ignore) {}
        }

        // Background tracking.
        if (checkKey(mapConfig, "sendInBackground")) {
            sendInBackground = mapConfig.getBoolean("sendInBackground");
            adtraceConfig.setSendInBackground(sendInBackground);
        }

        // Set device known.
        if (checkKey(mapConfig, "isDeviceKnown")) {
            isDeviceKnown = mapConfig.getBoolean("isDeviceKnown");
            adtraceConfig.setDeviceKnown(isDeviceKnown);
        }

        // Deprecated.
        // Set read mobile equipment ID.
        // if (checkKey(mapConfig, "readMobileEquipmentIdentity")) {
        //     readMobileEquipmentIdentity = mapConfig.getBoolean("readMobileEquipmentIdentity");
        //     adtraceConfig.setReadMobileEquipmentIdentity(readMobileEquipmentIdentity);
        // }

        // Preinstall tracking.
        if (checkKey(mapConfig, "preinstallTrackingEnabled")) {
            preinstallTrackingEnabled = mapConfig.getBoolean("preinstallTrackingEnabled");
            adtraceConfig.setPreinstallTrackingEnabled(preinstallTrackingEnabled);
        }

        // Cost data.
        if (checkKey(mapConfig, "needsCost")) {
            needsCost = mapConfig.getBoolean("needsCost");
            adtraceConfig.setNeedsCost(needsCost);
        }

        // Google Play Store kids app.
        if (checkKey(mapConfig, "playStoreKidsAppEnabled")) {
            playStoreKidsAppEnabled = mapConfig.getBoolean("playStoreKidsAppEnabled");
            adtraceConfig.setPlayStoreKidsAppEnabled(playStoreKidsAppEnabled);
        }

        // Launching deferred deep link.
        if (checkKey(mapConfig, "shouldLaunchDeeplink")) {
            shouldLaunchDeeplink = mapConfig.getBoolean("shouldLaunchDeeplink");
            this.shouldLaunchDeeplink = shouldLaunchDeeplink;
        }

        // Delayed start.
        if (checkKey(mapConfig, "delayStart")) {
            delayStart = mapConfig.getDouble("delayStart");
            adtraceConfig.setDelayStart(delayStart);
        }

        // COPPA compliance.
        if (checkKey(mapConfig, "coppaCompliantEnabled")) {
            coppaCompliantEnabled = mapConfig.getBoolean("coppaCompliantEnabled");
            adtraceConfig.setCoppaCompliantEnabled(coppaCompliantEnabled);
        }

        // Attribution callback.
        if (attributionCallback) {
            adtraceConfig.setOnAttributionChangedListener(this);
        }

        // Event tracking succeeded callback.
        if (eventTrackingSucceededCallback) {
            adtraceConfig.setOnEventTrackingSucceededListener(this);
        }

        // Event tracking failed callback.
        if (eventTrackingFailedCallback) {
            adtraceConfig.setOnEventTrackingFailedListener(this);
        }

        // Session tracking succeeded callback.
        if (sessionTrackingSucceededCallback) {
            adtraceConfig.setOnSessionTrackingSucceededListener(this);
        }

        // Session tracking failed callback.
        if (sessionTrackingFailedCallback) {
            adtraceConfig.setOnSessionTrackingFailedListener(this);
        }

        // Deferred deeplink callback.
        if (deferredDeeplinkCallback) {
            adtraceConfig.setOnDeeplinkResponseListener(this);
        }

        // Start SDK.
        io.adtrace.sdk.AdTrace.onCreate(adtraceConfig);
        io.adtrace.sdk.AdTrace.onResume();
    }

    @ReactMethod
    public void trackEvent(ReadableMap mapEvent) {
        if (mapEvent == null) {
            return;
        }

        double revenue = -1.0;
        String eventToken = null;
        String currency = null;
        String transactionId = null;
        String callbackId = null;
        Map<String, Object> callbackParameters = null;
        Map<String, Object> eventParameters = null;

        // Event token.
        if (checkKey(mapEvent, "eventToken")) {
            eventToken = mapEvent.getString("eventToken");
        }

        final AdTraceEvent event = new AdTraceEvent(eventToken);
        if (!event.isValid()) {
            return;
        }

        // Revenue.
        if (checkKey(mapEvent, "revenue") || checkKey(mapEvent, "currency")) {
            try {
                revenue = Double.parseDouble(mapEvent.getString("revenue"));
            } catch (NumberFormatException ignore) {}
            currency = mapEvent.getString("currency");
            event.setRevenue(revenue, currency);
        }

        // Callback parameters.
        if (checkKey(mapEvent, "callbackParameters")) {
            callbackParameters = AdTraceUtil.toMap(mapEvent.getMap("callbackParameters"));
            if (null != callbackParameters) {
                for (Map.Entry<String, Object> entry : callbackParameters.entrySet()) {
                    event.addCallbackParameter(entry.getKey(), entry.getValue().toString());
                }
            }
        }

        // Value parameters.
        if (checkKey(mapEvent, "valueParameters")) {
            eventParameters = AdTraceUtil.toMap(mapEvent.getMap("valueParameters"));
            if (null != eventParameters) {
                for (Map.Entry<String, Object> entry : eventParameters.entrySet()) {
                    event.addEventParameter(entry.getKey(), entry.getValue().toString());
                }
            }
        }

        // Revenue deduplication.
        if (checkKey(mapEvent, "transactionId")) {
            transactionId = mapEvent.getString("transactionId");
            if (null != transactionId) {
                event.setOrderId(transactionId);
            }
        }

        // Callback ID.
        if (checkKey(mapEvent, "callbackId")) {
            callbackId = mapEvent.getString("callbackId");
            if (null != callbackId) {
                event.setCallbackId(callbackId);
            }
        }

        // Track event.
        io.adtrace.sdk.AdTrace.trackEvent(event);
    }

    @ReactMethod
    public void setEnabled(Boolean enabled) {
        io.adtrace.sdk.AdTrace.setEnabled(enabled);
    }

    @ReactMethod
    public void isEnabled(Callback callback) {
        callback.invoke(io.adtrace.sdk.AdTrace.isEnabled());
    }

    @ReactMethod
    public void setReferrer(String referrer) {
        io.adtrace.sdk.AdTrace.setReferrer(referrer, getReactApplicationContext());
    }

    @ReactMethod
    public void setOfflineMode(Boolean enabled) {
        io.adtrace.sdk.AdTrace.setOfflineMode(enabled);
    }

    @ReactMethod
    public void setPushToken(String token) {
        io.adtrace.sdk.AdTrace.setPushToken(token, getReactApplicationContext());
    }

    @ReactMethod
    public void appWillOpenUrl(String strUri) {
        final Uri uri = Uri.parse(strUri);
        io.adtrace.sdk.AdTrace.appWillOpenUrl(uri, getReactApplicationContext());
    }

    @ReactMethod
    public void sendFirstPackages() {
        io.adtrace.sdk.AdTrace.sendFirstPackages();
    }

    @ReactMethod
    public void trackAdRevenue(String source, String payload) {
        try {
            JSONObject jsonPayload = new JSONObject(payload);
            io.adtrace.sdk.AdTrace.trackAdRevenue(source, jsonPayload);
        } catch (JSONException err) {
             Log.d(TAG, "Give ad revenue payload is not a valid JSON string");
        }
    }

    @ReactMethod
    public void trackAdRevenueNew(ReadableMap mapAdRevenue) {
        if (mapAdRevenue == null) {
            return;
        }

        double revenue = -1.0;
        int adImpressionsCount = -1;
        String source = null;
        String currency = null;
        String adRevenueNetwork = null;
        String adRevenueUnit = null;
        String adRevenuePlacement = null;
        Map<String, Object> callbackParameters = null;
        Map<String, Object> partnerParameters = null;

        // Source.
        if (checkKey(mapAdRevenue, "source")) {
            source = mapAdRevenue.getString("source");
        }

        final AdTraceAdRevenue adRevenue = new AdTraceAdRevenue(source);

        // Revenue.
        if (checkKey(mapAdRevenue, "revenue") || checkKey(mapAdRevenue, "currency")) {
            try {
                revenue = Double.parseDouble(mapAdRevenue.getString("revenue"));
            } catch (NumberFormatException ignore) {}
            currency = mapAdRevenue.getString("currency");
            adRevenue.setRevenue(revenue, currency);
        }

        // Ad impressions count.
        if (checkKey(mapAdRevenue, "adImpressionsCount")) {
            try {
                adImpressionsCount = Integer.parseInt(mapAdRevenue.getString("adImpressionsCount"));
            } catch (NumberFormatException ignore) {}
            adRevenue.setAdImpressionsCount(adImpressionsCount);
        }

        // Ad revenue network.
        if (checkKey(mapAdRevenue, "adRevenueNetwork")) {
            adRevenueNetwork = mapAdRevenue.getString("adRevenueNetwork");
            if (null != adRevenueNetwork) {
                adRevenue.setAdRevenueNetwork(adRevenueNetwork);
            }
        }

        // Ad revenue unit.
        if (checkKey(mapAdRevenue, "adRevenueUnit")) {
            adRevenueUnit = mapAdRevenue.getString("adRevenueUnit");
            if (null != adRevenueUnit) {
                adRevenue.setAdRevenueUnit(adRevenueUnit);
            }
        }

        // Ad revenue placement.
        if (checkKey(mapAdRevenue, "adRevenuePlacement")) {
            adRevenuePlacement = mapAdRevenue.getString("adRevenuePlacement");
            if (null != adRevenuePlacement) {
                adRevenue.setAdRevenuePlacement(adRevenuePlacement);
            }
        }

        // Callback parameters.
        if (checkKey(mapAdRevenue, "callbackParameters")) {
            callbackParameters = AdTraceUtil.toMap(mapAdRevenue.getMap("callbackParameters"));
            if (null != callbackParameters) {
                for (Map.Entry<String, Object> entry : callbackParameters.entrySet()) {
                    adRevenue.addCallbackParameter(entry.getKey(), entry.getValue().toString());
                }
            }
        }

        // Partner parameters.
        if (checkKey(mapAdRevenue, "partnerParameters")) {
            partnerParameters = AdTraceUtil.toMap(mapAdRevenue.getMap("partnerParameters"));
            if (null != partnerParameters) {
                for (Map.Entry<String, Object> entry : partnerParameters.entrySet()) {
                    adRevenue.addPartnerParameter(entry.getKey(), entry.getValue().toString());
                }
            }
        }

        // Track ad revenue.
        io.adtrace.sdk.AdTrace.trackAdRevenue(adRevenue);
    }

    @ReactMethod
    public void trackPlayStoreSubscription(ReadableMap mapEvent) {
        if (mapEvent == null) {
            return;
        }

        long price = -1;
        String currency = null;
        String sku = null;
        String orderId = null;
        String signature = null;
        String purchaseToken = null;
        long purchaseTime = -1;
        Map<String, Object> callbackParameters = null;
        Map<String, Object> partnerParameters = null;

        // Price.
        if (checkKey(mapEvent, "price")) {
            try {
                price = Long.parseLong(mapEvent.getString("price"));
            } catch (NumberFormatException ignore) {}
        }

        // Currency.
        if (checkKey(mapEvent, "currency")) {
            currency = mapEvent.getString("currency");
        }

        // SKU.
        if (checkKey(mapEvent, "sku")) {
            sku = mapEvent.getString("sku");
        }

        // Order ID.
        if (checkKey(mapEvent, "orderId")) {
            orderId = mapEvent.getString("orderId");
        }

        // Signature.
        if (checkKey(mapEvent, "signature")) {
            signature = mapEvent.getString("signature");
        }

        // Purchase token.
        if (checkKey(mapEvent, "purchaseToken")) {
            purchaseToken = mapEvent.getString("purchaseToken");
        }

        AdTracePlayStoreSubscription subscription = new AdTracePlayStoreSubscription(
                price,
                currency,
                sku,
                orderId,
                signature,
                purchaseToken);

        // Purchase time.
        if (checkKey(mapEvent, "purchaseTime")) {
            try {
                purchaseTime = Long.parseLong(mapEvent.getString("purchaseTime"));
                subscription.setPurchaseTime(purchaseTime);
            } catch (NumberFormatException ignore) {}
        }

        // Callback parameters.
        if (checkKey(mapEvent, "callbackParameters")) {
            callbackParameters = AdTraceUtil.toMap(mapEvent.getMap("callbackParameters"));
            if (null != callbackParameters) {
                for (Map.Entry<String, Object> entry : callbackParameters.entrySet()) {
                    subscription.addCallbackParameter(entry.getKey(), entry.getValue().toString());
                }
            }
        }

        // Partner parameters.
        if (checkKey(mapEvent, "partnerParameters")) {
            partnerParameters = AdTraceUtil.toMap(mapEvent.getMap("partnerParameters"));
            if (null != partnerParameters) {
                for (Map.Entry<String, Object> entry : partnerParameters.entrySet()) {
                    subscription.addPartnerParameter(entry.getKey(), entry.getValue().toString());
                }
            }
        }

        // Track subscription.
        io.adtrace.sdk.AdTrace.trackPlayStoreSubscription(subscription);
    }

    @ReactMethod
    public void addSessionCallbackParameter(String key, String value) {
        io.adtrace.sdk.AdTrace.addSessionCallbackParameter(key, value);
    }

    @ReactMethod
    public void addSessionPartnerParameter(String key, String value) {
        io.adtrace.sdk.AdTrace.addSessionPartnerParameter(key, value);
    }

    @ReactMethod
    public void removeSessionCallbackParameter(String key) {
        io.adtrace.sdk.AdTrace.removeSessionCallbackParameter(key);
    }

    @ReactMethod
    public void removeSessionPartnerParameter(String key) {
        io.adtrace.sdk.AdTrace.removeSessionPartnerParameter(key);
    }

    @ReactMethod
    public void resetSessionCallbackParameters() {
        io.adtrace.sdk.AdTrace.resetSessionCallbackParameters();
    }

    @ReactMethod
    public void resetSessionPartnerParameters() {
        io.adtrace.sdk.AdTrace.resetSessionPartnerParameters();
    }

    @ReactMethod
    public void gdprForgetMe() {
        io.adtrace.sdk.AdTrace.gdprForgetMe(getReactApplicationContext());
    }

    @ReactMethod
    public void disableThirdPartySharing() {
        io.adtrace.sdk.AdTrace.disableThirdPartySharing(getReactApplicationContext());
    }

    @ReactMethod
    public void getIdfa(Callback callback) {
        callback.invoke("");
    }

    @ReactMethod
    public void getGoogleAdId(final Callback callback) {
        io.adtrace.sdk.AdTrace.getGoogleAdId(getReactApplicationContext(), new io.adtrace.sdk.OnDeviceIdsRead() {
            @Override
            public void onGoogleAdIdRead(String googleAdId) {
                callback.invoke(googleAdId);
            }
        });
    }

    @ReactMethod
    public void getAdid(Callback callback) {
        callback.invoke(io.adtrace.sdk.AdTrace.getAdid());
    }

    @ReactMethod
    public void getAmazonAdId(Callback callback) {
        callback.invoke(io.adtrace.sdk.AdTrace.getAmazonAdId(getReactApplicationContext()));
    }

    @ReactMethod
    public void getAttribution(Callback callback) {
        callback.invoke(AdTraceUtil.attributionToMap(io.adtrace.sdk.AdTrace.getAttribution()));
    }

    @ReactMethod
    public void getSdkVersion(String sdkPrefix, Callback callback) {
        String sdkVersion = io.adtrace.sdk.AdTrace.getSdkVersion();
        if (sdkVersion == null) {
            callback.invoke("");
        } else {
            callback.invoke(sdkPrefix + "@" + sdkVersion);
        }
    }

    @ReactMethod
    public void convertUniversalLink(final String url, final String scheme, final Callback callback) {
        callback.invoke("");
    }

    @ReactMethod
    public void requestTrackingAuthorizationWithCompletionHandler(Callback callback) {
        callback.invoke("");
    }

    @ReactMethod
    public void updateConversionValue(int conversionValue) {
        // do nothing
    }

    @ReactMethod
    public void getAppTrackingAuthorizationStatus(Callback callback) {
        callback.invoke("-1");
    }

    @ReactMethod
    public void trackThirdPartySharing(ReadableMap mapThirdPartySharing) {
        if (mapThirdPartySharing == null) {
            return;
        }

        Boolean isEnabled = null;
        List<Object> granularOptions = null;
        List<Object> partnerSharingSettings = null;

        // Enabled.
        if (checkKey(mapThirdPartySharing, "isEnabled")) {
            isEnabled = mapThirdPartySharing.getBoolean("isEnabled");
        }

        final AdTraceThirdPartySharing thirdPartySharing = new AdTraceThirdPartySharing(isEnabled);

        // Granular options.
        if (checkKey(mapThirdPartySharing, "granularOptions")) {
            granularOptions = AdTraceUtil.toList(mapThirdPartySharing.getArray("granularOptions"));
            if (null != granularOptions) {
                for (int i = 0; i < granularOptions.size(); i += 3) {
                    thirdPartySharing.addGranularOption(
                        granularOptions.get(i).toString(),
                        granularOptions.get(i+1).toString(),
                        granularOptions.get(i+2).toString());
                }
            }
        }

        // Partner sharing settings.
        if (checkKey(mapThirdPartySharing, "partnerSharingSettings")) {
            partnerSharingSettings = AdTraceUtil.toList(mapThirdPartySharing.getArray("partnerSharingSettings"));
            if (null != partnerSharingSettings) {
                for (int i = 0; i < partnerSharingSettings.size(); i += 3) {
                    thirdPartySharing.addPartnerSharingSetting(
                        partnerSharingSettings.get(i).toString(),
                        partnerSharingSettings.get(i+1).toString(),
                        Boolean.parseBoolean(partnerSharingSettings.get(i+2).toString()));
                }
            }
        }

        // Track third party sharing.
        io.adtrace.sdk.AdTrace.trackThirdPartySharing(thirdPartySharing);
    }

    @ReactMethod
    public void trackMeasurementConsent(boolean measurementConsent) {
        io.adtrace.sdk.AdTrace.trackMeasurementConsent(measurementConsent);
    }

    @ReactMethod
    public void checkForNewAttStatus() {
        // do nothing
    }

    @ReactMethod
    public void getLastDeeplink(Callback callback) {
        callback.invoke("");
    }

    @ReactMethod
    public void setAttributionCallbackListener() {
        this.attributionCallback = true;
    }

    @ReactMethod
    public void setEventTrackingSucceededCallbackListener() {
        this.eventTrackingSucceededCallback = true;
    }

    @ReactMethod
    public void setEventTrackingFailedCallbackListener() {
        this.eventTrackingFailedCallback = true;
    }

    @ReactMethod
    public void setSessionTrackingSucceededCallbackListener() {
        this.sessionTrackingSucceededCallback = true;
    }

    @ReactMethod
    public void setSessionTrackingFailedCallbackListener() {
        this.sessionTrackingFailedCallback = true;
    }

    @ReactMethod
    public void setDeferredDeeplinkCallbackListener() {
        this.deferredDeeplinkCallback = true;
    }

    @ReactMethod
    public void teardown() {
        this.attributionCallback = false;
        this.eventTrackingSucceededCallback = false;
        this.eventTrackingFailedCallback = false;
        this.sessionTrackingSucceededCallback = false;
        this.sessionTrackingFailedCallback = false;
        this.deferredDeeplinkCallback = false;
    }

    @ReactMethod
    public void setTestOptions(ReadableMap mapTest) {
        if (mapTest == null) {
            return;
        }

        final AdTraceTestOptions testOptions = new AdTraceTestOptions();
        if (checkKey(mapTest, "hasContext")) {
            boolean value = mapTest.getBoolean("hasContext");
            if (value) {
                testOptions.context = getReactApplicationContext();
            }
        }
        if (checkKey(mapTest, "baseUrl")) {
            String value = mapTest.getString("baseUrl");
            testOptions.baseUrl = value;
        }
        if (checkKey(mapTest, "gdprUrl")) {
            String value = mapTest.getString("gdprUrl");
            testOptions.gdprUrl = value;
        }
        if (checkKey(mapTest, "subscriptionUrl")) {
            String value = mapTest.getString("subscriptionUrl");
            testOptions.subscriptionUrl = value;
        }
        if (checkKey(mapTest, "basePath")) {
            String value = mapTest.getString("basePath");
            testOptions.basePath = value;
        }
        if (checkKey(mapTest, "gdprPath")) {
            String value = mapTest.getString("gdprPath");
            testOptions.gdprPath = value;
        }
        if (checkKey(mapTest, "subscriptionPath")) {
            String value = mapTest.getString("subscriptionPath");
            testOptions.subscriptionPath = value;
        }
        // if (checkKey(mapTest, "useTestConnectionOptions")) {
        //     boolean value = mapTest.getBoolean("useTestConnectionOptions");
        //     testOptions.useTestConnectionOptions = value;
        // }
        if (checkKey(mapTest, "timerIntervalInMilliseconds")) {
            try {
                Long value = Long.parseLong(mapTest.getString("timerIntervalInMilliseconds"));
                testOptions.timerIntervalInMilliseconds = value;
            } catch (NumberFormatException ex) {
                ex.printStackTrace();
                Log.d(TAG, "Can't format number");
            }
        }
        if (checkKey(mapTest, "timerStartInMilliseconds")) {
            try {
                Long value = Long.parseLong(mapTest.getString("timerStartInMilliseconds"));
                testOptions.timerStartInMilliseconds = value;
            } catch (NumberFormatException ex) {
                ex.printStackTrace();
                Log.d(TAG, "Can't format number");
            }
        }
        if (checkKey(mapTest, "sessionIntervalInMilliseconds")) {
            try {
                Long value = Long.parseLong(mapTest.getString("sessionIntervalInMilliseconds"));
                testOptions.sessionIntervalInMilliseconds = value;
            } catch (NumberFormatException ex) {
                ex.printStackTrace();
                Log.d(TAG, "Can't format number");
            }
        }
        if (checkKey(mapTest, "subsessionIntervalInMilliseconds")) {
            try {
                Long value = Long.parseLong(mapTest.getString("subsessionIntervalInMilliseconds"));
                testOptions.subsessionIntervalInMilliseconds = value;
            } catch (NumberFormatException ex) {
                ex.printStackTrace();
                Log.d(TAG, "Can't format number");
            }
        }
        if (checkKey(mapTest, "noBackoffWait")) {
            boolean value = mapTest.getBoolean("noBackoffWait");
            testOptions.noBackoffWait = value;
        }
        if (checkKey(mapTest, "teardown")) {
            boolean value = mapTest.getBoolean("teardown");
            testOptions.teardown = value;
        }

        io.adtrace.sdk.AdTrace.setTestOptions(testOptions);
    }

    @ReactMethod
    public void onResume() {
        io.adtrace.sdk.AdTrace.onResume();
    }

    @ReactMethod
    public void onPause() {
        io.adtrace.sdk.AdTrace.onPause();
    }

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
    }

    private boolean checkKey(ReadableMap map, String key) {
        return map.hasKey(key) && !map.isNull(key);
    }

    @ReactMethod
    public void addListener(String eventName) {
        // Keep: Required for RN built in Event Emitter Calls.
    }

    @ReactMethod
    public void removeListeners(double count) {
        // Keep: Required for RN built in Event Emitter Calls.
    }
}
