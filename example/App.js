import { StatusBar } from 'expo-status-bar';
import React from 'react';
import { StyleSheet, Text, View ,TouchableHighlight} from 'react-native';
import {AdTrace,AdTraceEvent,AdTraceConfig} from 'react-native-adtrace';
import {AdTraceOaid} from 'react-native-adtrace-oaid';
export default function App() {
  AdTrace.getSdkVersion(function(sdkVersion) {
  console.log("AdTrace SDK version: " + sdkVersion);
});

const adtraceConfig = new AdTraceConfig("caedfdq89t1t", AdTraceConfig.EnvironmentSandbox);
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelVerbose);
// adtraceConfig.setDelayStart(6.0);
// adtraceConfig.setEventBufferingEnabled(true);
// adtraceConfig.setUserAgent("Custom AdTrace User Agent");
// adtraceConfig.setUrlStrategy(AdTraceConfig.UrlStrategyChina);
// adtraceConfig.deactivateSKAdNetworkHandling();
// adtraceConfig.setNeedsCost(true);
// adtraceConfig.setAttConsentWaitingInterval(16);
// adtraceConfig.setFinalAndroidAttributionEnabled(true);

adtraceConfig.setAttributionCallbackListener(function(attribution) {
  console.log("Attribution callback received");
  console.log("Tracker token = " + attribution.trackerToken);
  console.log("Tracker name = " + attribution.trackerName);
  console.log("Network = " + attribution.network);
  console.log("Campaign = " + attribution.campaign);
  console.log("Adgroup = " + attribution.adgroup);
  console.log("Creative = " + attribution.creative);
  console.log("Click label = " + attribution.clickLabel);
  console.log("Adid = " + attribution.adid);
  console.log("Cost type = " + attribution.costType);
  console.log("Cost amount = " + attribution.costAmount);
  console.log("Cost currency = " + attribution.costCurrency);
});

adtraceConfig.setEventTrackingSucceededCallbackListener(function(eventSuccess) {
  console.log("Event tracking succeeded callback received");
  console.log("Message: " + eventSuccess.message);
  console.log("Timestamp: " + eventSuccess.timestamp);
  console.log("Adid: " + eventSuccess.adid);
  console.log("Event token: " + eventSuccess.eventToken);
  console.log("Callback Id: " + eventSuccess.callbackId);
  console.log("JSON response: " + eventSuccess.jsonResponse );
});

adtraceConfig.setEventTrackingFailedCallbackListener(function(eventFailed) {
  console.log("Event tracking failed callback received");
  console.log("Message: " + eventFailed.message);
  console.log("Timestamp: " + eventFailed.timestamp);
  console.log("Adid: " + eventFailed.adid);
  console.log("Event token: " + eventFailed.eventToken);
  console.log("Callback Id: " + eventFailed.callbackId);
  console.log("Will retry: " + eventFailed.willRetry);
  console.log("JSON response: " + eventFailed.jsonResponse);
});

adtraceConfig.setSessionTrackingSucceededCallbackListener(function(sessionSuccess) {
  console.log("Session tracking succeeded callback received");
  console.log("Message: " + sessionSuccess.message);
  console.log("Timestamp: " + sessionSuccess.timestamp);
  console.log("Adid: " + sessionSuccess.adid);
  console.log("JSON response: " + sessionSuccess.jsonResponse);
});

adtraceConfig.setSessionTrackingFailedCallbackListener(function(sessionFailed) {
  console.log("Session tracking failed callback received");
  console.log("Message: " + sessionFailed.message);
  console.log("Timestamp: " + sessionFailed.timestamp);
  console.log("Adid: " + sessionFailed.adid);
  console.log("Will retry: " + sessionFailed.willRetry);
  console.log("JSON response: " + sessionFailed.jsonResponse);
});

adtraceConfig.setDeferredDeeplinkCallbackListener(function(uri) {
  console.log("Deferred Deeplink Callback received");
  console.log("URL: " + uri.uri);
});

adtraceConfig.setConversionValueUpdatedCallbackListener(function(conversionValue) {
  console.log("Conversion value updated callback recveived");
  console.log("Conversion value: " + conversionValue.conversionValue);
});

AdTrace.addSessionCallbackParameter("scpk1", "scpv1");
AdTrace.addSessionCallbackParameter("scpk2", "scpv2");

AdTrace.addSessionPartnerParameter("sppk1", "sppv1");
AdTrace.addSessionPartnerParameter("sppk2", "sppv2");

AdTrace.removeSessionCallbackParameter("scpk1");
AdTrace.removeSessionPartnerParameter("sppk2");

// AdTrace.resetSessionCallbackParameters();
// AdTrace.resetSessionPartnerParameters();

AdTrace.requestTrackingAuthorizationWithCompletionHandler(function(status) {
  console.log("Authorization status update");
  switch (status) {
      case 0:
          // ATTrackingManagerAuthorizationStatusNotDetermined case
          console.log("Authorization status: ATTrackingManagerAuthorizationStatusNotDetermined");
          break;
      case 1:
          // ATTrackingManagerAuthorizationStatusRestricted case
          console.log("Authorization status: ATTrackingManagerAuthorizationStatusRestricted");
          break;
      case 2:
          // ATTrackingManagerAuthorizationStatusDenied case
          console.log("Authorization status: ATTrackingManagerAuthorizationStatusDenied");
          break;
      case 3:
          // ATTrackingManagerAuthorizationStatusAuthorized case
          console.log("Authorization status: ATTrackingManagerAuthorizationStatusAuthorized");
          break;
  }
});

if (Platform.OS === "android") {
   AdTraceOaid.readOaid();
}
AdTrace.create(adtraceConfig);

function componentDidMount() {
  Linking.addEventListener('url', this.handleDeepLink);
  Linking.getInitialURL().then((url) => {
    if (url) {
      this.handleDeepLink({ url });
    }
  })
}

function componentWillUnmount() {
  AdTrace.componentWillUnmount();
  Linking.removeEventListener('url', this.handleDeepLink);
}

function handleDeepLink(e) {
  AdTrace.appWillOpenUrl(e.url);
}

function _onPress_trackSimpleEvent() {
  var adtraceEvent = new AdTraceEvent("udugd8");
  AdTrace.trackEvent(adtraceEvent);
  AdTrace.updateConversionValue(6);
  AdTrace.getAppTrackingAuthorizationStatus(function(status) {
    console.log("Authorization status = " + status);
  });
}

function _onPress_trackRevenueEvent() {
  var adtraceEvent = new AdTraceEvent("udugd8");
  adtraceEvent.setRevenue(10.0, "USD");
  adtraceEvent.setTransactionId("DUMMY_TRANSACTION_ID");
  AdTrace.trackEvent(adtraceEvent);
}

function _onPress_trackCallbackEvent() {
  var adtraceEvent = new AdTraceEvent("udugd8");
  adtraceEvent.addCallbackParameter("DUMMY_KEY_1", "DUMMY_VALUE_1");
  adtraceEvent.addCallbackParameter("DUMMY_KEY_2", "DUMMY_VALUE_2");
  AdTrace.trackEvent(adtraceEvent);
}

function _onPress_trackPartnerEvent() {
  var adtraceEvent = new AdTraceEvent("udugd8");
  adtraceEvent.addPartnerParameter("DUMMY_KEY_1", "DUMMY_VALUE_1");
  adtraceEvent.addPartnerParameter("DUMMY_KEY_2", "DUMMY_VALUE_2");
  AdTrace.trackEvent(adtraceEvent);
}
function _onPress_trackValueEvent() {
  var adtraceEvent = new AdTraceEvent("udugd8");
  adtraceEvent.addEventParameter("DUMMY_KEY_1", "DUMMY_VALUE_1");
  adtraceEvent.addEventParameter("DUMMY_KEY_2", "DUMMY_VALUE_2");
  AdTrace.trackEvent(adtraceEvent);
}

function _onPress_enableOfflineMode() {
  AdTrace.setOfflineMode(true);
}

function _onPress_disableOfflineMode() {
  AdTrace.setOfflineMode(false);
}

function _onPress_enableSdk() {
  AdTrace.setEnabled(true);
}

function _onPress_disableSdk() {
  AdTrace.setEnabled(false);
}

function _onPress_getIds() {
  AdTrace.getAdid((adid) => {
    console.log("Adid = " + adid);
  });

  AdTrace.getIdfa((idfa) => {
    console.log("IDFA = " + idfa);
  });

  AdTrace.getGoogleAdId((googleAdId) => {
    console.log("Google Ad Id = " + googleAdId);
  });


  AdTrace.getAttribution((attribution) => {
    console.log("Attribution:");
    console.log("Tracker token = " + attribution.trackerToken);
    console.log("Tracker name = " + attribution.trackerName);
    console.log("Network = " + attribution.network);
    console.log("Campaign = " + attribution.campaign);
    console.log("Adgroup = " + attribution.adgroup);
    console.log("Creative = " + attribution.creative);
    console.log("Click label = " + attribution.clickLabel);
    console.log("Adid = " + attribution.adid);
  });
}

function _onPress_isSdkEnabled() {
  AdTrace.isEnabled( (isEnabled) => {
    if (isEnabled) {
      console.log("SDK is enabled");
    } else {
      console.log("SDK is disabled");
    }
  });
}

return (
  <>
    <View style={styles.container}>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_trackSimpleEvent}>
        <Text>Track Simple Event</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_trackRevenueEvent}>
        <Text>Track Revenue Event</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_trackCallbackEvent}>
        <Text>Track Callback Event</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_trackPartnerEvent}>
        <Text>Track Partner Event</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_trackValueEvent}>
        <Text>Track Value Event</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_enableOfflineMode}>
        <Text>Enable Offline Mode</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_disableOfflineMode}>
        <Text>Disable Offline Mode</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_enableSdk}>
        <Text>Enable SDK</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_disableSdk}>
        <Text>Disable SDK</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_getIds}>
        <Text>Get Ids</Text>
      </TouchableHighlight>
      <TouchableHighlight
        style={styles.button}
        onPress={_onPress_isSdkEnabled}>
        <Text>is SDK Enabled?</Text>
      </TouchableHighlight>
    </View>
  </>
);
};

const styles = StyleSheet.create({
scrollView: {
  backgroundColor: '#bebebe',
},
engine: {
  position: 'absolute',
  right: 0,
},
body: {
  backgroundColor: '#ffffff',
},
sectionContainer: {
  marginTop: 32,
  paddingHorizontal: 24,
},
sectionTitle: {
  fontSize: 24,
  fontWeight: '600',
  color:'#000000',
},
sectionDescription: {
  marginTop: 8,
  fontSize: 18,
  fontWeight: '400',
  color: '#555555',
},
highlight: {
  fontWeight: '700',
},
footer: {
  color: '#555555',
  fontSize: 12,
  fontWeight: '600',
  padding: 4,
  paddingRight: 12,
  textAlign: 'right',
},
container: {
  flex: 1,
  justifyContent: 'center',
  alignItems: 'center',
  backgroundColor: '#F5FCFF',
},
button: {
  alignItems: 'center',
  backgroundColor: '#61D4FB',
  padding: 10,
  width: '60%',
  height: 40,
  margin: 10,
},
});
