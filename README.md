## Summary

This is the React Native SDK of Adtrace™. You can read more about Adtrace™ at [adtrace.io].

## Table of contents

* [Example app](#example-app)
* [Basic integration](#basic-integration)
   * [Get the SDK](#sdk-get)
   * [Integrate the SDK into your app](#sdk-integrate)
   * [Adtrace logging](#sdk-logging)
   * [Adtrace project settings](#adtrace-project-settings)
      * [Android permissions](#android-permissions)
      * [Google Play Services](#android-gps)
      * [Proguard settings](#android-proguard)
      * [Install referrer](#android-referrer)
         * [Google Play Referrer API](#android-referrer-gpr-api)
         * [Google Play Store intent](#android-referrer-gps-intent)
      * [iOS frameworks](#ios-frameworks)
* [Additional features](#additional-features)
   * [Event tracking](#event-tracking)
      * [Revenue tracking](#revenue-tracking)
      * [Revenue deduplication](#revenue-deduplication)
      * [In-app purchase verification](#iap-verification)
      * [Callback parameters](#callback-parameters)
      * [Partner parameters](#partner-parameters)
      * [Callback identifier](#callback-id)
   * [Session parameters](#session-parameters)
      * [Session callback parameters](#session-callback-parameters)
      * [Session partner parameters](#session-partner-parameters)
      * [Delay start](#delay-start)
   * [Attribution callback](#attribution-callback)
   * [Session and event callbacks](#session-event-callbacks)
   * [Disable tracking](#disable-tracking)
   * [Offline mode](#offline-mode)
   * [Event buffering](#event-buffering)
   * [GDPR right to be forgotten](#gdpr-forget-me)
   * [SDK signature](#sdk-signature)
   * [Background tracking](#background-tracking)
   * [Device IDs](#device-ids)
      * [iOS advertising identifier](#di-idfa)
      * [Google Play Services advertising identifier](#di-gps-adid)
      * [Amazon advertising identifier](#di-fire-adid)
      * [Adtrace device identifier](#di-adid)
   * [Push token](#push-token)
   * [Track additional device identifiers](#track-additional-ids)
   * [Pre-installed trackers](#pre-installed-trackers)
   * [Deep linking](#deeplinking)
      * [Standard deep linking](#deeplinking-standard)
      * [Deferred deep linking](#deeplinking-deferred)
      * [Reattribution via deep links](#deeplinking-reattribution)
* [License](#license)

## <a id="example-app"></a>Example app

There is an example app inside the [`example` directory][example].

## <a id="basic-integration"></a>Basic integration

We will describe the steps to integrate the Adtrace SDK into your React Native project. You can use any text editor or IDE for React Native development. There are no assumptions made regarding development environment.

### <a id="sdk-get"></a>Get the SDK

First, download the library from `npm`:

```
$ npm install react-native-adtrace --save
```

Then you must install the native dependencies. You can use `react-native` cli tool to add native dependencies automatically and then continue the directions below depending on your target OS.

```
$ react-native link
```

**Or** if you use CocoaPods for **iOS**, add the following to your `Podfile` and run `pod install` afterwards:

```
pod 'react-native-adtrace', :path => '../node_modules/react-native-adtrace'
```

For **iOS**, you don't need to do anything else.

For **Android**, you *may* need to check if Adtrace package was added to the native module's package list.

- Go to your app's `MainApplication.java` class. It should be located in
`./android/app/src/main/java/[your app]/MainApplication.java`

- There is a method called `getPackages()` that looks like this by default:

```java
@Override
protected List<ReactPackage> getPackages() {
  return Arrays.<ReactPackage>asList(
      new MainReactPackage()
  );
}
```

- After adding Adtrace SDK via `npm` and running `react-native link` command, Adtrace package should be added automatically to this list and it should look something like this:

```java
import com.adtrace.nativemodule.AdtracePackage;

// ...

@Override
protected List<ReactPackage> getPackages() {
  return Arrays.<ReactPackage>asList(
      new MainReactPackage(),
      new AdtracePackage()
  );
}
```

- In case that the line `new AdtracePackage()` was not added automatically, you'll have to add it to the list of packages by yourself like described above. Also, don't forget to add the import statement on top of the `MainApplication.java` file:

```java
import com.adtrace.nativemodule.AdtracePackage;
```

### <a id="sdk-integrate"></a>Integrate the SDK into your app

You should use the following import statement on top of your `.js` file

```javascript
import { Adtrace, AdtraceEvent, AdtraceConfig } from 'react-native-adtrace';
```

In your `index.android.js` or `index.ios.js` file, add the following code to initialize the Adtrace SDK:

```javascript
componentWillMount() {
    var adtraceConfig = new AdtraceConfig("{YourAppToken}", AdtraceConfig.EnvironmentSandbox);
    Adtrace.create(adtraceConfig);
}

componentWillUnmount() {
  Adtrace.componentWillUnmount();
}
```

Replace `{YourAppToken}` with your app token. You can find this in your Adtrace dashboard.

Depending on whether you build your app for testing or for production, you must set the environment with one of these values:

```
AdtraceConfig.EnvironmentSandbox
AdtraceConfig.EnvironmentProduction
```

**Important**: This value should be set to `AdtraceConfig.EnvironmentSandbox` if and only if you or someone else is testing your app. Make sure to set the environment to `AdtraceConfig.EnvironmentProduction` just before you publish the app. Set it back to `AdtraceConfig.EnvironmentSandbox` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. It is very important that you keep this value meaningful at all times!

### <a id="sdk-logging"></a>Adtrace logging

You can increase or decrease the amount of logs you see in tests by calling `setLogLevel` on your `AdtraceConfig` instance with one of the following parameters:

```js
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelVerbose);   // enable all logging
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelDebug);     // enable more logging
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelInfo);      // the default
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelWarn);      // disable info logging
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelError);     // disable warnings as well
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelAssert);    // disable errors as well
adtraceConfig.setLogLevel(AdtraceConfig.LogLevelSuppress);  // disable all logging
```

### <a id="adtrace-project-settings"></a>Adtrace project settings

Once the Adtrace SDK has been added to your app, certain tweaks are going to be performed so that the Adtrace SDK can work properly. Below you can find a description of every additional thing that the Adtrace SDK performs after you've added it to your app and what needs to be done by you in order for Adtrace SDK to work properly.

### <a id="android-permissions"></a>Android permissions

The Adtrace SDK by default adds two permissions to your app's `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

The `INTERNET` permission might be needed by our SDK at any point in time. The `ACCESS_WIFI_STATE` permission is needed by the Adtrace SDK if your app is not targeting the Google Play Store and doesn't use Google Play Services. If you are targeting the Google Play Store and you are using Google Play Services, the Adtrace SDK doesn't need this permission and, if you don't need it anywhere else in your app, you can remove it.

### <a id="android-gps"></a>Google Play Services

Since August 1, 2014, apps in the Google Play Store must use the [Google Advertising ID][google-ad-id] to uniquely identify devices. To allow the Adtrace SDK to use the Google Advertising ID, you must integrate [Google Play Services][google-play-services]. 

In order to do this, open your app's `build.gradle` file and find the `dependencies` block. Add the following line:

```gradle
compile 'com.google.android.gms:play-services-analytics:10.0.1'
```
    
**Note**: The version of the Google Play Services library that you're using is not relevant to the Adtrace SDK, as long as the analytics part of the library is present in your app. In the example above, we just used the most recent version of the library at the time of writing.

To check whether the analytics part of the Google Play Services library has been successfully added to your app so that the Adtrace SDK can read it properly, you should start your app by configuring the SDK to run in `sandbox` mode and set the log level to `verbose`. After that, track a session or some events in your app and observe the list of parameters in the verbose logs which are being read once the session or event has been tracked. If you see a parameter called `gps_adid` in there, you have successfully added the analytics part of the Google Play Services library to your app and our SDK is reading the necessary information from it.

In case you encounter any issue with attempts to read Google Advertising Identifier, feel free to open an issue in our Github repository or write an email to support@adtrace.com.

### <a id="android-proguard"></a>Proguard settings

If you are using Proguard, add these lines to your Proguard file:

```
-keep public class com.adtrace.sdk.** { *; }
-keep class com.google.android.gms.common.ConnectionResult {
    int SUCCESS;
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient {
    com.google.android.gms.ads.identifier.AdvertisingIdClient$Info getAdvertisingIdInfo(android.content.Context);
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
    java.lang.String getId();
    boolean isLimitAdTrackingEnabled();
}
-keep public class com.android.installreferrer.** { *; }
```

### <a id="android-referrer"></a>Install referrer

In order to correctly attribute an install of your Android app to its source, Adtrace needs information about the **install referrer**. This can be obtained by using the **Google Play Referrer API** or by catching the **Google Play Store intent** with a broadcast receiver.

**Important**: The Google Play Referrer API is newly introduced by Google with the express purpose of providing a more reliable and secure way of obtaining install referrer information and to aid attribution providers in the fight against click injection. It is **strongly advised** that you support this in your application. The Google Play Store intent is a less secure way of obtaining install referrer information. It will continue to exist in parallel with the new Google Play Referrer API temporarily, but it is set to be deprecated in future.

#### <a id="android-referrer-gpr-api"></a>Google Play Referrer API

In order to support this, add the following line to your app's `build.gradle` file:

```gradle
compile 'com.android.installreferrer:installreferrer:1.0'
```

`installreferrer` library is part of Google Maven repository, so in order to be able to build your app, you need to add Google Maven repository to your app's `build.gradle` file if you haven't added it already:

```gradle
allprojects {
    repositories {
        jcenter()
        maven {
            url "https://maven.google.com"
        }
    }
}
```

Also, make sure that you have paid attention to the [Proguard settings](#android-proguard) chapter and that you have added all the rules mentioned in it, especially the one needed for this feature:

```
-keep public class com.android.installreferrer.** { *; }
```

This feature is supported if you are using the **Adtrace SDK v4.12.0 or above**.

#### <a id="android-referrer-gps-intent"></a>Google Play Store intent

The Google Play Store `INSTALL_REFERRER` intent should be captured with a broadcast receiver. The Adtrace install referrer broadcast receiver is added to your app by default. For more information, you can check our native [Android SDK README][broadcast-receiver]. You can see this in the `AndroidManifest.xml` file which is part of our React Native plugin:

```xml
<receiver android:name="com.adtrace.sdk.AdtraceReferrerReceiver" 
          android:exported="true" >
    <intent-filter>
        <action android:name="com.android.vending.INSTALL_REFERRER" />
    </intent-filter>
</receiver>
```

Please bear in mind that, if you are using your own broadcast receiver which handles the `INSTALL_REFERRER` intent, you don't need to add the Adtrace broadcast receiver to your manifest file. You can remove it, but inside your own receiver add the call to the Adtrace broadcast receiver as described in our [Android guide][broadcast-receiver-custom].

### <a id="ios-frameworks"></a>iOS frameworks

Select your project in the Project Navigator. In the left hand side of the main view, select your target. In the tab `Build Phases`, expand the group `Link Binary with Libraries`. On the bottom of that section click on the `+` button. Select the `AdSupport.framework` and click the `Add` button. Unless you are using `tvOS`, repeat the same steps to add the `iAd.framework` and `CoreTelephony.framework`. Change the `Status` of both frameworks to `Optional`. Adtrace SDK uses these frameworks with following purpose:

* `iAd.framework` - in case you are running iAd campaigns
* `AdSupport.framework` - for reading iOS Advertising Id (IDFA)
* `CoreTelephony.framework` - for reading MCC and MNC information

If you are not running any iAd campaigns, you can feel free to remove the `iAd.framework` dependency.

## <a id="additional-features"></a>Additional features

You can take advantage of the following features once the Adtrace SDK is integrated into your project.

### <a id="event-tracking"></a>Event tracking

You can use Adtrace to track all kinds of events. Let's say you want to track every tap on a button. Simply create a new event token in your [dashboard]. Let's say that event token is `abc123`. You can add the following line in your button’s click handler method to track the click:

```js
var adtraceEvent = new AdtraceEvent("abc123");
Adtrace.trackEvent(adtraceEvent);
```

### <a id="revenue-tracking"></a>Revenue tracking

If your users can generate revenue by tapping on advertisements or making In-App Purchases, then you can track those revenues with events. Let's say a tap is worth €0.01. You could track the revenue event like this:

```js
var adtraceEvent = new AdtraceEvent("abc123");

adtraceEvent.setRevenue(0.01, "EUR");

Adtrace.trackEvent(adtraceEvent);
```

When you set a currency token, Adtrace will automatically convert the incoming revenues into a reporting revenue of your choice. Read more about [currency conversion here][currency-conversion].

### <a id="revenue-deduplication"></a>Revenue deduplication

You can also add an optional transaction ID to avoid tracking duplicate revenues. The last ten transaction IDs are remembered, and revenue events with duplicate transaction IDs are skipped. This is especially useful for In-App Purchase tracking. You can see an example below.

If you want to track in-app purchases, please make sure to call the `trackEvent` only if the transaction is finished and an item is purchased. That way you can avoid tracking revenue that is not actually being generated.

```js
var adtraceEvent = new AdtraceEvent("abc123");

adtraceEvent.setRevenue(0.01, "EUR");
adtraceEvent.setTransactionId("{YourTransactionId}");

Adtrace.trackEvent(adtraceEvent);
```

**Note**: Transaction ID is the iOS term, unique identifier for successfully finished Android In-App-Purchases is named **Order ID**.

### <a id="iap-verification"></a>In-app purchase verification

In-app purchase verification can be conducted through the React Native Purchase SDK which is currently in development and will soon be made publicly available. For more information, please contact support@adtrace.com.

### <a id="callback-parameters"></a>Callback parameters

You can also register a callback URL for that event in your [dashboard][dashboard] and we will send a GET request to that URL whenever the event gets tracked. In that case you can also put some key-value pairs in an object and pass it to the `trackEvent` method. We will then append these named parameters to your callback URL.

For example, suppose you have registered the URL `http://www.adtrace.io/callback` for your event with event token `abc123` and execute the following lines:

```js
var adtraceEvent = new AdtraceEvent("abc123");

adtraceEvent.addCallbackParameter("key", "value");
adtraceEvent.addCallbackParameter("foo", "bar");

Adtrace.trackEvent(adtraceEvent);
```

In that case we would track the event and send a request to:

```
http://www.adtrace.com/callback?key=value&foo=bar
```

It should be mentioned that we support a variety of placeholders like `{idfa}` for iOS or `{gps_adid}` for Android that can be used as parameter values. In the resulting callback the `{idfa}` placeholder would be replaced with the ID for Advertisers of the current device for iOS and the `{gps_adid}` would be replaced with the Google Advertising ID of the current device for Android. Also note that we don't store any of your custom parameters, but only append them to your callbacks. If you haven't registered a callback for an event, these parameters won't even be read.

You can read more about using URL callbacks, including a full list of available values, in our
[callbacks guide][callbacks-guide].

**Note**: **Both** parameters in this method must be **strings**. If either of the passed parameters is not a string, the key-value pair will not be added to the parameters list.

### <a id="partner-parameters"></a>Partner parameters

Similarly to the callback parameters mentioned above, you can also add parameters that Adtrace will transmit to the network partners of your choice. You can activate these networks in your Adtrace dashboard.

This works similarly to the callback parameters mentioned above, but can be added by calling the `addPartnerParameter` method on your `AdtraceEvent` instance.

```js
var adtraceEvent = new AdtraceEvent("abc123");

adtraceEvent.addPartnerParameter("key", "value");
adtraceEvent.addPartnerParameter("foo", "bar");

Adtrace.trackEvent(adtraceEvent);
```

You can read more about special partners and networks in our [guide to special partners][special-partners].

**Note**: **Both** parameters in this method must be **strings**. If either of the passed parameters is not a string, the key-value pair will not be added to the parameters list.

### <a id="callback-id"></a>Callback identifier

You can also add custom string identifier to each event you want to track. This identifier will later be reported in event success and/or event failure callbacks to enable you to keep track on which event was successfully tracked or not. You can set this identifier by calling the `setCallbackId` method on your `AdtraceEvent` instance:

```js
var adtraceEvent = new AdtraceEvent("abc123");

adtraceEvent.setCallbackId("Your-Custom-Id");

Adtrace.trackEvent(adtraceEvent);
```

### <a id="session-parameters"></a>Session parameters

Some parameters are saved to be sent in every event and session of the Adtrace SDK. Once you have added any of these parameters, you don't need to add them every time, since they will be saved locally. If you add the same parameter twice, there will be no effect.

These session parameters can be called before the Adtrace SDK is launched to make sure they are sent even on install. If you need to send them with an install, but can only obtain the needed values after launch, it's possible to [delay](#delay-start) the first launch of the Adtrace SDK to allow this behaviour.

### <a id="session-callback-parameters"></a>Session callback parameters

The same callback parameters that are registered for [events](#callback-parameters) can be also saved to be sent in every event or session of the Adtrace SDK.

The session callback parameters have a similar interface of the event callback parameters. Instead of adding the key and its value to an event, it's added through a call to method `addSessionCallbackParameter` of the `Adtrace` instance:

```js
Adtrace.addSessionCallbackParameter("foo", "bar");
```

The session callback parameters will be merged with the callback parameters and added to an event. The callback parameters added to an event have precedence over the session callback parameters. Meaning that, when adding a callback parameter to an event with the same key to one added from the session, the value that prevails is the callback parameter added to the event.

**Note**: **Both** parameters in this method must be **strings**. If either of the passed parameters is not a string, the key-value pair will not be added to the parameters list.

It's possible to remove a specific session callback parameter by passing the desiring key to the method `removeSessionCallbackParameter` of the `Adtrace` instance:

```js
Adtrace.removeSessionCallbackParameter("foo");
```

If you wish to remove all key and values from the session callback parameters, you can reset it with the method `resetSessionCallbackParameters` of the `Adtrace` instance:

```js
Adtrace.resetSessionCallbackParameters();
```

### <a id="session-partner-parameters"></a>Session partner parameters

In the same way that there are [session callback parameters](#session-callback-parameters) that are sent for every event or session of the Adtrace SDK, there are also session partner parameters.

These will be transmitted to network partners, for the integrations that have been activated in your Adtrace [dashboard].

The session partner parameters have a similar interface to the event partner parameters. Instead of adding the key and its value to an event, it's added through a call to method `addSessionPartnerParameter` of the `Adtrace` instance:

```js
Adtrace.addSessionPartnerParameter("foo", "bar");
```

The session partner parameters will be merged with the partner parameters and added to an event. The partner parameters added to an event have precedence over the session partner parameters. Meaning that, when adding a partner parameter to an event with the same key to one added from the session, the value that prevails is the partner parameter added to the event.

**Note**: **Both** parameters in this method must be **strings**. If either of the passed parameters is not a string, the key-value pair will not be added to the parameters list.

It's possible to remove a specific session partner parameter by passing the desiring key to the method `removeSessionPartnerParameter` of the `Adtrace` instance:

```js
Adtrace.removeSessionPartnerParameter("foo");
```

If you wish to remove all keys and values from the session partner parameters, you can reset it with the method `resetSessionPartnerParameters` of the `Adtrace` instance:

```js
Adtrace.resetSessionPartnerParameters();
```

### <a id="delay-start"></a>Delay start

Delaying the start of the Adtrace SDK allows your app some time to obtain session parameters, such as unique identifiers, to be sent on install.

Set the initial delay time in seconds with the `setDelayStart` field of the `AdtraceConfig` instance:

```js
adtraceConfig.setDelayStart(5.5);
```

In this case this will make the Adtrace SDK not send the initial install session and any event created for 5.5 seconds. After this time is expired or if you call `sendFirstPackages()` of the `Adtrace` instance in the meanwhile, every session parameter will be added to the delayed install session and events and the Adtrace SDK will resume as usual.

**The maximum delay start time of the Adtrace SDK is 10 seconds**.

### <a id="attribution-callback"></a>Attribution callback

You can register a listener to be notified of tracker attribution changes. Due to the different sources considered for attribution, this information cannot be provided synchronously. The simplest way is to create a single anonymous listener which is going to be called **each time your user's attribution value changes**:

With the `AdtraceConfig` instance, before starting the SDK, add the anonymous listener:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setAttributionCallbackListener(function(attribution) {
    // Printing all attribution properties.
    console.log("Attribution changed!");
    console.log(attribution.trackerToken);
    console.log(attribution.trackerName);
    console.log(attribution.network);
    console.log(attribution.campaign);
    console.log(attribution.adgroup);
    console.log(attribution.creative);
    console.log(attribution.clickLabel);
    console.log(attribution.adid);
});

Adtrace.create(adtraceConfig);
```

Within the listener function you have access to the `attribution` parameters. Here is a quick summary of its properties:

- `trackerToken`    the tracker token of the current attribution.
- `trackerName`     the tracker name of the current attribution.
- `network`         the network grouping level of the current attribution.
- `campaign`        the campaign grouping level of the current attribution.
- `adgroup`         the ad group grouping level of the current attribution.
- `creative`        the creative grouping level of the current attribution.
- `clickLabel`      the click label of the current attribution.
- `adid`            the Adtrace device identifier.

Please make sure to consider our [applicable attribution data policies][attribution-data].

### <a id="session-event-callbacks"></a>Session and event callbacks

You can register a callback to be notified of successful and failed tracked events and/or sessions.

Follow the same steps as for attribution callback to implement the following callback function for successfully tracked events:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setEventTrackingSucceededCallbackListener(function(eventSuccess) {
    // Printing all event success properties.
    console.log("Event tracking succeeded!");
    console.log(eventSuccess.message);
    console.log(eventSuccess.timestamp);
    console.log(eventSuccess.eventToken);
    console.log(eventSuccess.callbackId);
    console.log(eventSuccess.adid);
    console.log(eventSuccess.jsonResponse);
});

Adtrace.create(adtraceConfig);
```

The following callback function for failed tracked events:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setEventTrackingFailedCallbackListener(function(eventFailure) {
    // Printing all event failure properties.
    console.log("Event tracking failed!");
    console.log(eventSuccess.message);
    console.log(eventSuccess.timestamp);
    console.log(eventSuccess.eventToken);
    console.log(eventSuccess.callbackId);
    console.log(eventSuccess.adid);
    console.log(eventSuccess.willRetry);
    console.log(eventSuccess.jsonResponse);
});

Adtrace.create(adtraceConfig);
```

For successfully tracked sessions:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setSessionTrackingSucceededCallbackListener(function(sessionSuccess) {
    // Printing all session success properties.
    console.log("Session tracking succeeded!");
    console.log(sessionSuccess.message);
    console.log(sessionSuccess.timestamp);
    console.log(sessionSuccess.adid);
    console.log(sessionSuccess.jsonResponse);
});

Adtrace.create(adtraceConfig);
```

And for failed tracked sessions:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setSessionTrackingFailedCallbackListener(function(sessionFailure) {
    // Printing all session failure properties.
    console.log("Session tracking failed!");
    console.log(sessionSuccess.message);
    console.log(sessionSuccess.timestamp);
    console.log(sessionSuccess.adid);
    console.log(sessionSuccess.willRetry);
    console.log(sessionSuccess.jsonResponse);
});

Adtrace.create(adtraceConfig);
```

The callback functions will be called after the SDK tries to send a package to the server. Within the callback you have access to a response data object specifically for the callback. Here is a quick summary of the session response data properties:

- `var message` the message from the server or the error logged by the SDK.
- `var timestamp` timestamp from the server.
- `var adid` a unique device identifier provided by Adtrace.
- `var jsonResponse` the JSON object with the response from the server.

Both event response data objects contain:

- `var eventToken` the event token, if the package tracked was an event.
- `var callbackId` the custom defined callback ID set on event object.

And both event and session failed objects also contain:

- `var willRetry` indicates there will be an attempt to resend the package at a later time.

### <a id="disable-tracking"></a>Disable tracking

You can disable the Adtrace SDK from tracking by invoking the method `setEnabled` of the `Adtrace` instance with the enabled parameter as `false`. This setting is **remembered between sessions**, but it can only be activated after the first session.

```js
Adtrace.setEnabled(false);
```

You can verify if the Adtrace SDK is currently active with the method `isEnabled` of the `Adtrace` instance. It is always possible to activate the Adtrace SDK by invoking `setEnabled` with the parameter set to `true`.

### <a id="offline-mode"></a>Offline mode

You can put the Adtrace SDK in offline mode to suspend transmission to our servers while retaining tracked data to be sent later. When in offline mode, all information is saved in a file, so be careful not to trigger too many events while in offline mode.

You can activate offline mode by calling the method `setOfflineMode` of the `Adtrace` instance with the parameter `true`.

```js
Adtrace.setOfflineMode(true);
```

Conversely, you can deactivate offline mode by calling `setOfflineMode` with `false`. When the Adtrace SDK is put back in online mode, all saved information is send to our servers with the correct time information.

Unlike disabling tracking, **this setting is not remembered** between sessions. This means that the SDK is in online mode whenever it is started, even if the app was terminated in offline mode.

### <a id="event-buffering"></a>Event buffering

If your app makes heavy use of event tracking, you might want to delay some HTTP requests in order to send them in one batch every minute. You can enable event buffering with your `AdtraceConfig` instance by calling `setEventBufferingEnabled` method:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setEventBufferingEnabled(true);

Adtrace.create(adtraceConfig);
```

### <a id="gdpr-forget-me"></a>GDPR right to be forgotten

In accordance with article 17 of the EU's General Data Protection Regulation (GDPR), you can notify Adtrace when a user has exercised their right to be forgotten. Calling the following method will instruct the Adtrace SDK to communicate the user's choice to be forgotten to the Adtrace backend:

```js
Adtrace.gdprForgetMe();
```

Upon receiving this information, Adtrace will erase the user's data and the Adtrace SDK will stop tracking the user. No requests from this device will be sent to Adtrace in the future.

### <a id="sdk-signature"></a>SDK signature

An account manager must activate the Adtrace SDK signature. Contact Adtrace support (support@adtrace.com) if you are interested in using this feature.

If the SDK signature has already been enabled on your account and you have access to App Secrets in your Adtrace Dashboard, please use the method below to integrate the SDK signature into your app.

An App Secret is set by passing all secret parameters (`secretId`, `info1`, `info2`, `info3`, `info4`) to `setAppSecret` method of `AdtraceConfig` instance:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setAppSecret(secretId, info1, info2, info3, info4);

Adtrace.create(adtraceConfig);
```

### <a id="background-tracking"></a>Background tracking

The default behaviour of the Adtrace SDK is to **pause sending HTTP requests while the app is in the background**. You can change this in your `AdtraceConfig` instance by calling `setSendInBackground` method:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setSendInBackground(true);

Adtrace.create(adtraceConfig);
```

If nothing is set, sending in background is **disabled by default**.

### <a id="device-ids"></a>Device IDs

Certain services (such as Google Analytics) require you to coordinate device and client IDs in order to prevent duplicate reporting.

### <a id="di-idfa"></a>iOS advertising identifier

You can access the IDFA value of an iOS device by invoking the `getIdfa` method of the `Adtrace` instance and passing it a callback that will get triggered once the IDFA value has been obtained by the native iOS SDK:

```javascript
Adtrace.getIdfa((idfa) => {
    console.log("IDFA = " + idfa);
});
```

### <a id="di-gps-adid"></a>Google Play Services advertising identifier

The Adtrace SDK allows you to read the Google advertising identifier of the Android device on which your app is running. In order to do this, call the `getGoogleAdId` method of the `Adtrace` instance and pass your callback as a parameter. Once obtained by the native Android SDK, you will receive the Google advertising identifier value in your callback method:

```javascript
Adtrace.getGoogleAdId((googleAdId) => {
    console.log("Google Ad Id = " + googleAdId);
});
```


### <a id="di-fire-adid"></a>Amazon advertising identifier

If you need to obtain the Amazon advertising ID, you can call the `getAmazonAdId` method of the `Adtrace` instance and pass your callback as a parameter to which the Amazon advertising ID value will be sent once obtained:

```javascript
Adtrace.getAmazonAdId((amazonAdId) => {
    console.log("Amazon Ad Id = " + amazonAdId);
});
```

### <a id="di-adid"></a>Adtrace device identifier

For every device with your app installed on it, the Adtrace backend generates a unique **Adtrace device identifier** (**adid**). In order to obtain this identifier, call the `getAdid` method of the `Adtrace` instance and pass your callback as a parameter to which the **adid** value will be sent once obtained:

```javascript
Adtrace.getAdid((adid) => {
    console.log("Adid = " + adid);
});
```

**Note**: Information about the **adid** is only available after an app installation has been tracked by the Adtrace backend. From that moment on, the Adtrace SDK has information about the device **adid** and you can access it with this method. So, **it is not possible** to access the **adid** value before the SDK has been initialized and installation of your app has been successfully tracked.

### <a id="user-attribution"></a>User attribution

This callback is triggered as described in the [attribution callback section](#attribution-callback), providing you with information about a new attribution whenever it changes. If you want to access information about a user's current attribution status at any other time, you can make a call to the `getAttribution` method of the `Adtrace` instance and pass your callback as a parameter to which the attribution value will be sent once obtained:

```javascript
Adtrace.getAttribution((attribution) => {
    console.log("Tracker token = " + attribution.trackerToken);
    console.log("Tracker name = " + attribution.trackerName);
    console.log("Network = " + attribution.network);
    console.log("Campaign = " + attribution.campaign);
    console.log("Adgroup = " + attribution.adgroup);
    console.log("Creative = " + attribution.creative);
    console.log("Click label = " + attribution.clickLabel);
    console.log("Adid = " + attribution.adid);
});
```

**Note**: Information about a user's current attribution status is only available after an app installation has been tracked by the Adtrace backend and the attribution callback has been triggered. From that moment on, the Adtrace SDK has information about a user's attribution status and you can access it with this method. So, **it is not possible** to access a user's attribution value before the SDK has been initialized and an attribution callback has been triggered.

### <a id="push-token"></a>Push token

To send us the push notification token, add the following call to Adtrace **whenever you get your token in the app or when it gets updated**:

```js
Adtrace.setPushToken("YourPushNotificationToken");
```

Push tokens are used for Audience Builder and client callbacks, and they are required for the upcoming uninstall tracking feature.

### <a id="track-additional-ids"></a>Track additional device identifiers

If you are distributing your Android app **outside of the Google Play Store** and would like to track additional device identifiers (IMEI and MEID), you need to explicitly instruct the Adtrace SDK to do so. You can do that by calling the `setReadMobileEquipmentIdentity` method of the `AdtraceConfig` instance. **The Adtrace SDK does not collect these identifiers by default**.

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setReadMobileEquipmentIdentity(true);

Adtrace.create(adtraceConfig);
```

You will also need to add the `READ_PHONE_STATE` permission to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

In order to use this feature, additional steps are required within your Adtrace Dashboard. For more information, please contact your dedicated account manager or write an email to support@adtrace.com.

### <a id="pre-installed-trackers"></a>Pre-installed trackers

If you want to use the Adtrace SDK to recognize users that found your app pre-installed on their device, follow these steps.

1. Create a new tracker in your [dashboard].
2. Open your app delegate and add set the default tracker of your `AdtraceConfig` instance:

    ```js
    var adtraceConfig = new AdtraceConfig(appToken, environment);

    adtraceConfig.setDefaultTracker("{TrackerToken}");

    Adtrace.create(adtraceConfig);
    ```

  Replace `{TrackerToken}` with the tracker token you created in step 2. Please note that the dashboard displays a tracker
  URL (including `http://app.adtrace.io/`). In your source code, you should specify only the six-character token and not the
  entire URL.

3. Build and run your app. You should see a line like the following in the app's log output:

    ```
    Default tracker: 'abc123'
    ```

### <a id="deeplinking"></a>Deep linking

If you are using the Adtrace tracker URL with an option to deep link into your app from the URL, there is the possibility to get info about the deep link URL and its content. Hitting the URL can happen when the user has your app already installed (standard deep linking scenario) or if they don't have the app on their device (deferred deep linking scenario).

### <a id="deeplinking-standard"></a>Standard deep linking scenario

To support deep linking in Android, the app's `AndroidManifest.xml` file will need to be modified. Please refer to this [page of our Android SDK][android-sdk-deeplink] for the needed modifications to `AndroidManifest.xml`.

To support deep linking in iOS 8 or earlier, the app's `Info.plist` file will need to be modified. Please refer to this [page of our iOS SDK][ios-sdk-deeplink-early] for the needed modifications to `Info.plist`.

To support deep linking in iOS 9 or later, your app would have to handle Universal Links. Please refer to this [page of our iOS SDK][ios-sdk-deeplink-late] for the needed modifications.

After that, refer to this page of the [React Native offical docs][rn-linking] for instructions on how to support both platforms and obtain deep link URL in your JavaScript code.

### <a id="deeplinking-deferred"></a>Deferred deep linking scenario

While deferred deep linking is not supported out of the box on Android and iOS, our Adtrace SDK makes it possible.

In order to get info about the URL content in a deferred deep linking scenario, you should set a callback method on the `AdtraceConfig` object which will receive one parameter where the content of the URL will be delivered. You should set this method on the config object by calling the method `setDeeplinkCallbackListener`:

```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setDeferredDeeplinkCallbackListener(function(deeplink) {
    console.log("Deferred deep link URL content: " + deeplink);
});

Adtrace.create(adtraceConfig);
```

In the deferred deep linking scenario, there is one additional setting which can be set on the `AdtraceConfig` object. Once the Adtrace SDK gets the deferred deep link info, we are offering you the possibility to choose whether our SDK should open this URL or not. You can choose to set this option by calling the `setShouldLaunchDeeplink` method on the config object:


```js
var adtraceConfig = new AdtraceConfig(appToken, environment);

adtraceConfig.setShouldLaunchDeeplink(true);
// or adtraceConfig.setShouldLaunchDeeplink(false);

adtraceConfig.setDeeplinkCallbackListener(function(deeplink) {
    console.log("Deferred deep link URL content: " + deeplink);
});

Adtrace.create(adtraceConfig);
```

If nothing is set, **the Adtrace SDK will always try to launch the URL by default**.

### <a id="deeplinking-reattribution"></a>Reattribution via deep links

Adtrace enables you to run re-engagement campaigns by using deep links. For more information on this, please check our [official docs][reattribution-with-deeplinks].

If you are using this feature, in order for your user to be properly reattributed, you need to make one additional call to the Adtrace SDK in your app. Once you have received deep link content information in your app, add a call to `appWillOpenUrl` method of the `Adtrace` instance. By making this call, the Adtrace SDK will try to find if there is any new attribution info inside of the deep link and if any, it will be sent to the Adtrace backend. If your user should be reattributed due to a click on the Adtrace tracker URL with deep link content in it, you will see the [attribution callback](#attribution-callback) in your app being triggered with new attribution info for this user.

Call to the `appWillOpenUrl` method in a React component would look like this:

```js
componentDidMount() {
    Linking.addEventListener('url', this.handleDeepLink);
    Linking.getInitialURL().then((url) => {
        if (url) {
            this.handleDeepLink({ url });
        }
    })
}

componentWillUnmount() {
    Linking.removeEventListener('url', this.handleDeepLink);
}

handleDeepLink(event) {
    Adtrace.appWillOpenUrl(event.url);
}
```

[dashboard]:    http://panel.adtrace.io
[adtrace.io]:   http://adtrace.io

[example]:      ./example
[npm-repo]:     https://www.npmjs.com/package/react-native-adtrace

[rn-linking]:           https://facebook.github.io/react-native/docs/linking.html
[google-ad-id]:         https://support.google.com/googleplay/android-developer/answer/6048248?hl=en
[enable-ulinks]:        https://github.com/adtrace/ios_sdk#deeplinking-setup-new
[event-tracking]:       https://docs.adtrace.com/en/event-tracking
[callbacks-guide]:      https://docs.adtrace.com/en/callbacks
[attribution-data]:     https://github.com/adtrace/sdks/blob/master/doc/attribution-data.md
[special-partners]:     https://docs.adtrace.com/en/special-partners
[broadcast-receiver]:   https://github.com/adtrace/android_sdk#gps-intent

[google-launch-modes]:        http://developer.android.com/guide/topics/manifest/activity-element.html#lmode
[currency-conversion]:        https://docs.adtrace.com/en/event-tracking/#tracking-purchases-in-different-currencies
[google-play-services]:       http://developer.android.com/google/play-services/index.html
[android-sdk-deeplink]:       https://github.com/adtrace/android_sdk#deeplinking-standard
[google-play-services]:       http://developer.android.com/google/play-services/setup.html
[ios-sdk-deeplink-late]:      https://github.com/adtrace/ios_sdk#-deep-linking-on-ios-9-and-later
[ios-sdk-deeplink-early]:     https://github.com/adtrace/ios_sdk#-deep-linking-on-ios-8-and-earlier
[broadcast-receiver-custom]:  https://github.com/adtrace/android_sdk/blob/master/doc/english/referrer.md

[reattribution-with-deeplinks]: https://docs.adtrace.com/en/deeplinking/#manually-appending-attribution-data-to-a-deep-link
