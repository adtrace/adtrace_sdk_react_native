<p align="center"><a href="https://adtrace.io" target="_blank" rel="noopener noreferrer"><img width="100" src="http://adtrace.io/fa/wp-content/uploads/2019/02/logo.png" alt="Adtrace logo"></a></p>

<p align="center">
  <a href='https://www.npmjs.com/package/react-native-adtrace'><img src='https://img.shields.io/npm/v/react-native-adtrace.svg'></a>
  <a href='https://opensource.org/licenses/MIT'><img src='https://img.shields.io/badge/License-MIT-green.svg'></a>
</p>

## Summary

This is the React Native SDK of AdTrace™. You can read more about AdTrace™ at [adtrace.io].

## Table of contents

### Quick start   

* [Example app](#qs-example-app)
* [Getting started](#qs-getting-started)
  * [Get the SDK](#qs-sdk-get) 
  * [AdTrace project settings](#qs-adtrace-project-settings)
    * [Android permissions](#qs-android-permissions)
    * [Google Play Services](#qs-android-gps)
    * [Proguard settings](#qs-android-proguard)
    * [Install referrer](#qs-android-referrer)
      * [Google Play Referrer API](#qs-android-referrer-gpr-api)
      * [Google Play Store intent](#qs-android-referrer-gps-intent)
    * [iOS frameworks](#qs-ios-frameworks)
* [Integrate the SDK into your app](#qs-sdk-integrate)
  * [SDK signature](#qs-sdk-signature)
  * [AdTrace logging](#qs-sdk-logging)

### Deep linking

* [Deep linking overview](#dl-overview) 
* [Standard deep linking](#dl-standard) 
* [Deferred deep linking](#dl-deferred) 
* [Reattribution via deep links](#dl-reattribution) 

### Event tracking

* [Track event](#et-track-event) 
* [Track revenue](#et-track-revenue) 
* [Deduplicate revenue](#et-track-deduplicate)

### Custom parameters

* [Custom parameters overview](#cp-overview) 
* [Event parameters](#cp-event) 
  * [Event callback parameters](#cp-event-callback) 
  * [Event partner parameters](#cp-event-partner) 
  * [Event callback identifier](#cp-event-identifier) 
  * [Event value](#cp-event-value)  
* [Session parameters](#cp-session) 
  * [Session callback parameters](#cp-session-callback) 
  * [Session partner parameters](#cp-session-partner)
  * [Delay start](#cp-delay-start)

### Additional features

* [Push token (uninstall tracking)](#af-push-token)
* [Attribution callback](#af-attribution-callback)
* [Session and event callbacks](#af-session-event-callbacks)
* [User attribution](#af-user-attribution) 
* [Send installed apps](#af-send-installed-apps) 
* [Device IDs](#af-di) 
  * [iOS advertising identifier](#af-di-idfa)
  * [Google Play Services advertising identifier](#af-di-gps-adid)
  * [Amazon advertising identifier](#af-di-fire-idfa)
  * [AdTrace device identifier](#af-di-adid)
* [Pre-installed trackers](#af-pre-installed-trackers)
* [Offline mode](#af-offline-mode)
* [Disable tracking](#af-disable-tracking)
* [Event buffering](#af-event-buffering)
* [Background tracking](#af-background-tracking)
* [Track additional device identifiers](#af-track-additional-ids)
* [GDPR right to be forgotten](#af-gdpr-forget-me)

## Quick start

### <a id="qs-example-app"></a>Example app

There are example React native app inside the  [`example`  directory][example-app]. In there you can check how the AdTrace SDK can be integrated.

### <a id="qs-getting-started"></a>Getting started

We will describe the steps to integrate the AdTrace SDK into your React Native project. You can use any text editor or IDE for React Native development. There are no assumptions made regarding development environment.

### <a id="qs-sdk-get"></a>Get the SDK

First, download the library from `npm` or `yarn`:

```
$ npm install react-native-adtrace --save
```

Then you must install the native dependencies. You can use `react-native` CLI tool to add native dependencies automatically and then continue the directions below depending on your target OS.

```
$ react-native link react-native-adtrace
```

**Or** if you use CocoaPods for **iOS**, add the following to your `Podfile` and run `pod install` afterwards:

```
pod 'react-native-adtrace', :path => '../node_modules/react-native-adtrace'
```

For **iOS**, you don't need to do anything else.

For **Android**, you *may* need to check if AdTrace package was added to the native module's package list.

- Go to your app's `MainApplication.java` class. It should be located in
`./android/app/src/main/java/[your app]/MainApplication.java`

- There is a method called `getPackages()` that looks like this by default:

  ```java
  @Override
  protected List<ReactPackage> getPackages() {
    @SuppressWarnings("UnnecessaryLocalVariable")
    List<ReactPackage> packages = new PackageList(this).getPackages();
    return packages;
  }
  ```

- After adding AdTrace SDK via `npm` and running `react-native link` command, AdTrace package should be added automatically to this list and it should look something like this:

  ```java
  import com.adtrace.nativemodule.AdTracePackage;

  // ...

  @Override
  protected List<ReactPackage> getPackages() {
    @SuppressWarnings("UnnecessaryLocalVariable")
    List<ReactPackage> packages = new PackageList(this).getPackages();
    packages.add(new AdTracePackage());
    return packages;
  }
  ```

- In case that the line `new AdTracePackage()` was not added automatically, you'll have to add it to the list of packages by yourself like described above. Also, don't forget to add the import statement on top of the `MainApplication.java` file:

  ```java
  import com.adtrace.nativemodule.AdTracePackage;
  ```

### <a id="qs-adtrace-project-settings"></a>AdTrace project settings

Once the AdTrace SDK has been added to your app, certain tweaks are going to be performed so that the AdTrace SDK can work properly. Below you can find a description of every additional thing that the AdTrace SDK performs after you've added it to your app and what needs to be done by you in order for AdTrace SDK to work properly.

### <a id="qs-android-permissions"></a>Android permissions

The AdTrace SDK by default adds two permissions to your app's `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

The `INTERNET` permission might be needed by our SDK at any point in time. The `ACCESS_WIFI_STATE` permission is needed by the AdTrace SDK if your app is not targeting the Google Play Store and doesn't use Google Play Services. If you are targeting the Google Play Store and you are using Google Play Services, the AdTrace SDK doesn't need this permission and, if you don't need it anywhere else in your app, you can remove it.

### <a id="qs-android-gps"></a>Google Play Services

Since August 1, 2014, apps in the Google Play Store must use the [Google Advertising ID][google-ad-id] to uniquely identify devices. To allow the AdTrace SDK to use the Google Advertising ID, you must integrate [Google Play Services][google-play-services]. 

In order to do this, open your app's `build.gradle` file and find the `dependencies` block. Add the following line:

```gradle
implementation 'com.google.android.gms:play-services-ads-identifier:17.0.0'
```
    
**Note**: The version of the Google Play Services library that you're using is not relevant to the AdTrace SDK, as long as the analytics part of the library is present in your app. In the example above, we just used the most recent version of the library at the time of writing.

To check whether the analytics part of the Google Play Services library has been successfully added to your app so that the AdTrace SDK can read it properly, you should start your app by configuring the SDK to run in `sandbox` mode and set the log level to `verbose`. After that, track a session or some events in your app and observe the list of parameters in the verbose logs which are being read once the session or event has been tracked. If you see a parameter called `gps_adid` in there, you have successfully added the analytics part of the Google Play Services library to your app and our SDK is reading the necessary information from it.

### <a id="qs-android-proguard"></a>Proguard settings

If you are using Proguard, add these lines to your Proguard file:

```
-keep public class io.adtrace.sdk.** { *; }
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

### <a id="qs-android-referrer"></a>Install referrer

In order to correctly attribute an install of your Android app to its source, AdTrace needs information about the **install referrer**. This can be obtained by using the **Google Play Referrer API** or by catching the **Google Play Store intent** with a broadcast receiver.

**Important**: The Google Play Referrer API is newly introduced by Google with the express purpose of providing a more reliable and secure way of obtaining install referrer information and to aid attribution providers in the fight against click injection. It is **strongly advised** that you support this in your application. The Google Play Store intent is a less secure way of obtaining install referrer information. It will continue to exist in parallel with the new Google Play Referrer API temporarily, but it is set to be deprecated in future.

#### <a id="qs-android-referrer-gpr-api"></a>Google Play Referrer API

In order to support this, add the following line to your app's `build.gradle` file:

```gradle
implementation 'com.android.installreferrer:installreferrer:1.1.2'
```

`installreferrer` library is part of Google Maven repository, so in order to be able to build your app, you need to add Google Maven repository to your app's `build.gradle` file if you haven't added it already:

```gradle
allprojects {
    repositories {
        google()
        jcenter()
    }
}
```

Also, make sure that you have paid attention to the [Proguard settings](#qs-android-proguard) chapter and that you have added all the rules mentioned in it, especially the one needed for this feature:

```
-keep public class com.android.installreferrer.** { *; }
```

#### <a id="qs-android-referrer-gps-intent"></a>Google Play Store intent

The Google Play Store `INSTALL_REFERRER` intent should be captured with a broadcast receiver. The AdTrace install referrer broadcast receiver is added to your app by default. For more information, you can check our native [Android SDK README][broadcast-receiver]. You can see this in the `AndroidManifest.xml` file which is part of our React Native plugin:

```xml
<receiver android:name="io.adtrace.sdk.AdTraceReferrerReceiver" 
          android:exported="true" >
    <intent-filter>
        <action android:name="com.android.vending.INSTALL_REFERRER" />
    </intent-filter>
</receiver>
```

Please bear in mind that, if you are using your own broadcast receiver which handles the `INSTALL_REFERRER` intent, you don't need to add the AdTrace broadcast receiver to your manifest file. You can remove it, but inside your own receiver add the call to the AdTrace broadcast receiver as described in our [Android guide][broadcast-receiver-custom].

### <a id="qs-ios-frameworks"></a>iOS frameworks

Select your project in the Project Navigator. In the left hand side of the main view, select your target. In the tab `Build Phases`, expand the group `Link Binary with Libraries`. On the bottom of that section click on the `+` button. Select the `AdSupport.framework` and click the `Add` button. Unless you are using `tvOS`, repeat the same steps to add the `iAd.framework` and `CoreTelephony.framework`. Change the `Status` of both frameworks to `Optional`. AdTrace SDK uses these frameworks with following purpose:

* `iAd.framework` - in case you are running iAd campaigns
* `AdSupport.framework` - for reading iOS Advertising Id (IDFA)
* `CoreTelephony.framework` - for reading MCC and MNC information

If you are not running any iAd campaigns, you can feel free to remove the `iAd.framework` dependency.

### <a id="qs-sdk-integrate"></a>Integrate the SDK into your app

You should use the following import statement on top of your `.js` file

```javascript
import { AdTrace, AdTraceEvent, AdTraceConfig } from 'react-native-adtrace';
```

In your `App.js`  file, add the following code to initialize the AdTrace SDK:

```javascript
constructor(props) {
    super(props);
    const adtraceConfig = new AdTraceConfig("{YourAppToken}", AdTraceConfig.EnvironmentSandbox);
    AdTrace.create(adtraceConfig);
}

componentWillUnmount() {
  AdTrace.componentWillUnmount();
}
```

Replace `{YourAppToken}` with your app token. You can find this in your AdTrace panel.

Depending on whether you build your app for testing or for production, you must set the environment with one of these values:

```
AdTraceConfig.EnvironmentSandbox
AdTraceConfig.EnvironmentProduction
```

**Important**: This value should be set to `AdTraceConfig.EnvironmentSandbox` if and only if you or someone else is testing your app. Make sure to set the environment to `AdTraceConfig.EnvironmentProduction` just before you publish the app. Set it back to `AdTraceConfig.EnvironmentSandbox` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. It is very important that you keep this value meaningful at all times!

### <a id="qs-sdk-signature"></a>SDK signature

If the SDK signature has already been enabled on your account and you have access to App Secrets in your AdTrace panel, please use the method below to integrate the SDK signature into your app.

An App Secret is set by passing all secret parameters (`secretId`, `info1`, `info2`, `info3`, `info4`) to `setAppSecret` method of `AdTraceConfig` instance:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setAppSecret(secretId, info1, info2, info3, info4);

AdTrace.create(adtraceConfig);
```

### <a id="qs-sdk-logging"></a>AdTrace logging

You can increase or decrease the amount of logs you see in tests by calling `setLogLevel` on your `AdTraceConfig` instance with one of the following parameters:

```js
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelVerbose);   // enable all logging
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelDebug);     // enable more logging
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelInfo);      // the default
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelWarn);      // disable info logging
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelError);     // disable warnings as well
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelAssert);    // disable errors as well
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelSuppress);  // disable all logging
```

## Deep linking

### <a id="dl-overview"></a>Deep linking overview

If you are using the AdTrace tracker URL with an option to deep link into your app from the URL, there is the possibility to get info about the deep link URL and its content. Hitting the URL can happen when the user has your app already installed (standard deep linking scenario) or if they don't have the app on their device (deferred deep linking scenario).

### <a id="dl-standard"></a>Standard deep linking scenario

To support deep linking in Android, the app's `AndroidManifest.xml` file will need to be modified. Please refer to this [page of our Android SDK][android-sdk-deeplink] for the needed modifications to `AndroidManifest.xml`.

To support deep linking in iOS 8 or earlier, the app's `Info.plist` file will need to be modified. Please refer to this [page of our iOS SDK][ios-sdk-deeplink-early] for the needed modifications to `Info.plist`.

To support deep linking in iOS 9 or later, your app would have to handle Universal Links. Please refer to this [page of our iOS SDK][ios-sdk-deeplink-late] for the needed modifications.

After that, refer to this page of the [React Native offical docs][rn-linking] for instructions on how to support both platforms and obtain deep link URL in your JavaScript code.

### <a id="dl-deferred"></a>Deferred deep linking scenario

While deferred deep linking is not supported out of the box on Android and iOS, our AdTrace SDK makes it possible.

In order to get info about the URL content in a deferred deep linking scenario, you should set a callback method on the `AdTraceConfig` object which will receive one parameter where the content of the URL will be delivered. You should set this method on the config object by calling the method `setDeeplinkCallbackListener`:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setDeferredDeeplinkCallbackListener(function(deeplink) {
    console.log("Deferred deep link URL content: " + deeplink);
});

AdTrace.create(adtraceConfig);
```

In the deferred deep linking scenario, there is one additional setting which can be set on the `AdTraceConfig` object. Once the AdTrace SDK gets the deferred deep link info, we are offering you the possibility to choose whether our SDK should open this URL or not. You can choose to set this option by calling the `setShouldLaunchDeeplink` method on the config object:


```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setShouldLaunchDeeplink(true);
// or adtraceConfig.setShouldLaunchDeeplink(false);

adtraceConfig.setDeeplinkCallbackListener(function(deeplink) {
    console.log("Deferred deep link URL content: " + deeplink);
});

AdTrace.create(adtraceConfig);
```

If nothing is set, **the AdTrace SDK will always try to launch the URL by default**.

### <a id="dl-reattribution"></a>Reattribution via deep links

If you are using this feature, in order for your user to be properly reattributed, you need to make one additional call to the AdTrace SDK in your app. Once you have received deep link content information in your app, add a call to `appWillOpenUrl` method of the `AdTrace` instance. By making this call, the AdTrace SDK will try to find if there is any new attribution info inside of the deep link and if any, it will be sent to the AdTrace backend. If your user should be reattributed due to a click on the AdTrace tracker URL with deep link content in it, you will see the [attribution callback](#af-attribution-callback) in your app being triggered with new attribution info for this user.

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
    AdTrace.appWillOpenUrl(event.url);
}
```

## Event tracking

### <a id="et-track-event"></a>Track event

You can use AdTrace to track all kinds of events. Let's say you want to track every tap on a button. Simply create a new event token in your [panel]. Let's say that event token is `abc123`. You can add the following line in your button’s click handler method to track the click:

```js
var adtraceEvent = new AdTraceEvent("abc123");
AdTrace.trackEvent(adtraceEvent);
```

### <a id="et-track-revenue"></a>Track revenue

If your users can generate revenue by tapping on advertisements or making In-App Purchases, then you can track those revenues with events. Let's say a tap is worth €0.01. You could track the revenue event like this:

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setRevenue(0.01, "EUR");

AdTrace.trackEvent(adtraceEvent);
```

When you set a currency token, AdTrace will automatically convert the incoming revenues into a reporting revenue of your choice.

### <a id="et-track-deduplicate"></a>Revenue deduplication

You can also add an optional transaction ID to avoid tracking duplicate revenues. The last ten transaction IDs are remembered, and revenue events with duplicate transaction IDs are skipped. This is especially useful for In-App Purchase tracking. You can see an example below.

If you want to track in-app purchases, please make sure to call the `trackEvent` only if the transaction is finished and an item is purchased. That way you can avoid tracking revenue that is not actually being generated.

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setRevenue(0.01, "EUR");
adtraceEvent.setTransactionId("{YourTransactionId}");

AdTrace.trackEvent(adtraceEvent);
```

**Note**: Transaction ID is the iOS term, unique identifier for successfully finished Android In-App-Purchases is named **Order ID**.

## Custom parameters

### <a id="cp-overview"></a>Custom parameters overview

In addition to the data points the AdTrace SDK collects by default, you can use the AdTrace SDK to track and add as many custom values as you need (user IDs, product IDs, etc.) to the event or session. Custom parameters are only available as raw data and will  **not**  appear in your AdTrace panel.

Use callback parameters for the values you collect for your own internal use, and partner parameters for those you share with external partners. If a value (e.g. product ID) is tracked both for internal use and external partner use, we recommend using both callback and partner parameters.

### <a id="cp-event"></a>Event parameters

### <a id="cp-event-callback"></a>Event callback parameters

If you register a callback URL for events in your [panel], we will send a GET request to that URL whenever the event is tracked. You can also put key-value pairs in an object and pass it to the `trackEvent` method. We will then append these parameters to your callback URL.

For example, suppose you have registered the URL `http://www.adtrace.io/callback` for your event with event token `abc123` and execute the following lines:

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.addCallbackParameter("key", "value");
adtraceEvent.addCallbackParameter("foo", "bar");

AdTrace.trackEvent(adtraceEvent);
```

In that case we would track the event and send a request to:

```
http://www.adtrace.io/callback?key=value&foo=bar
```

### <a id="cp-event-partner"></a>Event partner parameters

Once your parameters are activated in the panel, you can send them to your network partners.

This works the same way as callback parameters; add them by calling the  `addPartnerParameter`  method on your  `AdTraceEvent`  instance.

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.addPartnerParameter("key", "value");
adtraceEvent.addPartnerParameter("foo", "bar");

AdTrace.trackEvent(adtraceEvent);
```

### <a id="cp-event-identifier"></a>Event callback identifier

You can add custom string identifiers to each event you want to track. We report this identifier in your event callbacks, letting you know which event was successfully tracked. Set the identifier by calling the `setCallbackId` method on your `AdTraceEvent` instance:

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setCallbackId("Your-Custom-Id");

AdTrace.trackEvent(adtraceEvent);
```

### <a id="cp-event-value"></a>Event value

You can also add custom string value to event. You can set this value by calling the `setEventValue` method on your `AdTraceEvent` instance:

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setEventValue("Your-Value");

AdTrace.trackEvent(adtraceEvent);
```

### <a id="cp-session"></a>Session parameters

Session parameters are saved locally and sent with every AdTrace SDK  **event and session**. Whenever you add these parameters, we save them (so you don't need to add them again). Adding the same parameter twice will have no effect.

It's possible to send session parameters before the AdTrace SDK has launched. Using the  [SDK delay](#cp-delay-start), you can therefore retrieve additional values (for instance, an authentication token from the app's server), so that all information can be sent at once with the SDK's initialization.

### <a id="cp-session-callback"></a>Session callback parameters

You can save event callback parameters to be sent with every AdTrace SDK session.

The session callback parameters' interface is similar to the one for event callback parameters. Instead of adding the key and its value to an event, add them via a call to the  `addSessionCallbackParameter`  method of the  `AdTrace`  instance:

```js
AdTrace.addSessionCallbackParameter("foo", "bar");
```

Session callback parameters merge with event callback parameters, sending all of the information as one, but event callback parameters take precedence over session callback parameters. If you add an event callback parameter with the same key as a session callback parameter, we will show the event value.

You can remove a specific session callback parameter by passing the desired key to the  `removeSessionCallbackParameter`  method of the  `AdTrace`  instance.

```js
AdTrace.removeSessionCallbackParameter("foo");
```

To remove all keys and their corresponding values from the session callback parameters, you can reset them with the  `resetSessionCallbackParameters`  method of the  `AdTrace`  instance.

```js
AdTrace.resetSessionCallbackParameters();
```

### <a id="cp-session-partner"></a>Session partner parameters

In the same way that  [session callback parameters](#cp-session-callback)  are sent with every event or session that triggers our SDK, there are also session partner parameters.

These are transmitted to network partners for all of the integrations activated in your  [panel].

The session partner parameters interface is similar to the event partner parameters interface, however instead of adding the key and its value to an event, add it by calling the  `addSessionPartnerParameter`  method of the  `AdTrace`  instance.

```js
AdTrace.addSessionPartnerParameter("foo", "bar");
```

Session partner parameters merge with event partner parameters. However, event partner parameters take precedence over session partner parameters. If you add an event partner parameter with the same key as a session partner parameter, we will show the event value.

To remove a specific session partner parameter, pass the desired key to the  `removeSessionPartnerParameter`  method of the  `AdTrace`  instance.

```js
AdTrace.removeSessionPartnerParameter("foo");
```

To remove all keys and their corresponding values from the session partner parameters, reset it with the  `resetSessionPartnerParameters`  method of the  `AdTrace`  instance.

```js
AdTrace.resetSessionPartnerParameters();
```

### <a id="cp-delay-start"></a>Delay start

Delaying the start of the AdTrace SDK allows your app some time to obtain session parameters, such as unique identifiers, to be sent on install.

Set the initial delay time in seconds with the `setDelayStart` field of the `AdTraceConfig` instance:

```js
adtraceConfig.setDelayStart(5.5);
```

In this case this will make the AdTrace SDK not send the initial install session and any event created for 5.5 seconds. After this time is expired or if you call `sendFirstPackages()` of the `AdTrace` instance in the meanwhile, every session parameter will be added to the delayed install session and events and the AdTrace SDK will resume as usual.

**The maximum delay start time of the AdTrace SDK is 10 seconds**.

## Additional features

Once you integrate the AdTrace SDK into your project, you can take advantage of the following features:

### <a id="af-push-token"></a>Push token

Push tokens are used for Audience Builder and client callbacks; they are also required for uninstall and reinstall tracking.

To send us a push notification token, call the  `setDeviceToken`  method on the  `AdTrace`  instance when you obtain your app's push notification token (or whenever its value changes):

```js
AdTrace.setPushToken("YourPushNotificationToken");
```

### <a id="af-attribution-callback"></a>Attribution callback

You can register a callback to be notified of tracker attribution changes. Due to the different sources considered for attribution, this information can not be provided synchronously.

With the `AdTraceConfig` instance, before starting the SDK, add the anonymous listener:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

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

AdTrace.create(adtraceConfig);
```

Within the listener function you have access to the `attribution` parameters. Here is a quick summary of its properties:

- `trackerToken`    the tracker token of the current attribution.
- `trackerName`     the tracker name of the current attribution.
- `network`         the network grouping level of the current attribution.
- `campaign`        the campaign grouping level of the current attribution.
- `adgroup`         the ad group grouping level of the current attribution.
- `creative`        the creative grouping level of the current attribution.
- `clickLabel`      the click label of the current attribution.
- `adid`            the AdTrace device identifier.

### <a id="af-session-event-callbacks"></a>Session and event callbacks

You can register a callback to be notified of successful and failed tracked events and/or sessions.

Follow the same steps as for attribution callback to implement the following callback function for successfully tracked events:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

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

AdTrace.create(adtraceConfig);
```

The following callback function for failed tracked events:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

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

AdTrace.create(adtraceConfig);
```

For successfully tracked sessions:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setSessionTrackingSucceededCallbackListener(function(sessionSuccess) {
    // Printing all session success properties.
    console.log("Session tracking succeeded!");
    console.log(sessionSuccess.message);
    console.log(sessionSuccess.timestamp);
    console.log(sessionSuccess.adid);
    console.log(sessionSuccess.jsonResponse);
});

AdTrace.create(adtraceConfig);
```

And for failed tracked sessions:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setSessionTrackingFailedCallbackListener(function(sessionFailure) {
    // Printing all session failure properties.
    console.log("Session tracking failed!");
    console.log(sessionSuccess.message);
    console.log(sessionSuccess.timestamp);
    console.log(sessionSuccess.adid);
    console.log(sessionSuccess.willRetry);
    console.log(sessionSuccess.jsonResponse);
});

AdTrace.create(adtraceConfig);
```

The callback functions will be called after the SDK tries to send a package to the server. Within the callback you have access to a response data object specifically for the callback. Here is a quick summary of the session response data properties:

- `var message` the message from the server or the error logged by the SDK.
- `var timestamp` timestamp from the server.
- `var adid` a unique device identifier provided by AdTrace.
- `var jsonResponse` the JSON object with the response from the server.

Both event response data objects contain:

- `var eventToken` the event token, if the package tracked was an event.
- `var callbackId` the custom defined callback ID set on event object.

And both event and session failed objects also contain:

- `var willRetry` indicates there will be an attempt to resend the package at a later time.

### <a id="af-user-attribution"></a>User attribution

This callback, like an [attribution callback](#af-attribution-callback), is triggered whenever the attribution information changes. Access your user's current attribution information whenever you need it by calling the following method of the `AdTrace` instance:

```javascript
AdTrace.getAttribution((attribution) => {
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

**Note**: Information about a user's current attribution status is only available after an app installation has been tracked by the AdTrace backend and the attribution callback has been triggered. From that moment on, the AdTrace SDK has information about a user's attribution status and you can access it with this method. So, **it is not possible** to access a user's attribution value before the SDK has been initialized and an attribution callback has been triggered.

### <a id="af-send-installed-apps"></a>Send installed apps

To increase the accuracy and security in fraud detection, you can enable the sending of installed applications on user's device as follows:

adtraceConfig.setEnableSendInstalledApps(true);

**Note**: This option is  **disabled**  by default.

### <a id="af-di"></a>Device IDs

The AdTrace SDK lets you receive device identifiers.

### <a id="af-di-idfa"></a>iOS advertising identifier

To obtain the IDFA, call the function  `getIdfa`  of the  `AdTrace`  instance:

```javascript
AdTrace.getIdfa((idfa) => {
    console.log("IDFA = " + idfa);
});
```

### <a id="af-di-gps-adid"></a>Google Play Services advertising identifier

Certain services (such as Google Analytics) require you to coordinate Device and Client IDs in order to prevent duplicate reporting.

To obtain the device Google Advertising identifier, it's necessary to pass a callback function to  `AdTrace.getGoogleAdId`  that will receive the Google Advertising ID in it's argument, like this:

```javascript
AdTrace.getGoogleAdId((googleAdId) => {
    console.log("Google Ad Id = " + googleAdId);
});
```

### <a id="af-di-fire-idfa"></a>Amazon advertising identifier

If you need to get the Amazon advertising ID, call the  `getAmazonAdId`  method on  `AdTrace`  instance:

```javascript
AdTrace.getAmazonAdId((amazonAdId) => {
    console.log("Amazon Ad Id = " + amazonAdId);
});
```

### <a id="af-di-adid"></a>AdTrace device identifier

For each device with your app installed on it, our backend generates a unique **AdTrace device identifier** (known as an **adid**). In order to obtain this identifier, call the following method on `AdTrace` instance:

```javascript
AdTrace.getAdid((adid) => {
    console.log("Adid = " + adid);
});
```

**Note**: Information about the **adid** is only available after our backend tracks the app instal. **It is not possible** to access the **adid** value before the SDK has been initialized and the installation of your app has been successfully tracked.

### <a id="af-pre-installed-trackers"></a>Pre-installed trackers

If you want to use the AdTrace SDK to recognize users whose devices came with your app pre-installed, follow these steps:

1. Create a new tracker in your [panel].
2. Open your app delegate and add set the default tracker of your `AdTraceConfig` instance:

    ```js
    var adtraceConfig = new AdTraceConfig(appToken, environment);

    adtraceConfig.setDefaultTracker("{TrackerToken}");

    AdTrace.create(adtraceConfig);
    ```

    Replace  `{TrackerToken}`  with the tracker token you created in step 2. E.g.  `{abc123}`
  Although the panel displays a tracker URL (including `http://app.adtrace.io/`), in your source code you should only enter the six or seven-character token and not the entire URL.

3. Build and run your app. You should see a line like the following in the app's log output:

    ```
    Default tracker: 'abc123'
    ```

### <a id="af-offline-mode"></a>Offline mode

You can put the AdTrace SDK in offline mode to suspend transmission to our servers (while retaining tracked data to be sent later). While in offline mode, all information is saved in a file. Please be careful not to trigger too many events while in offline mode.

You can activate offline mode by calling the method `setOfflineMode` of the `AdTrace` instance with the parameter `true`.

```js
AdTrace.setOfflineMode(true);
```

Conversely, you can deactivate offline mode by calling `setOfflineMode` with `false`. When the AdTrace SDK is put back in online mode, all saved information is send to our servers with the correct time information.

Unlike disabling tracking, **this setting is not remembered** between sessions. This means that the SDK is in online mode whenever it is started, even if the app was terminated in offline mode.



### <a id="af-disable-tracking"></a>Disable tracking

You can disable the AdTrace SDK from tracking by invoking the method `setEnabled` of the `AdTrace` instance with the enabled parameter as `false`. This setting is **remembered between sessions**, but it can only be activated after the first session.

```js
AdTrace.setEnabled(false);
```

You can verify if the AdTrace SDK is currently active with the method `isEnabled` of the `AdTrace` instance. It is always possible to activate the AdTrace SDK by invoking `setEnabled` with the parameter set to `true`.

### <a id="af-event-buffering"></a>Event buffering

The default behaviour of the AdTrace SDK is to pause sending network requests while the app is in the background. You can change this in your `AdTraceConfig` instance:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setEventBufferingEnabled(true);

AdTrace.create(adtraceConfig);
```

### <a id="af-background-tracking"></a>Background tracking

The default behaviour of the AdTrace SDK is to **pause sending HTTP requests while the app is in the background**. You can change this in your `AdTraceConfig` instance by calling `setSendInBackground` method:

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setSendInBackground(true);

AdTrace.create(adtraceConfig);
```

If nothing is set, sending in background is **disabled by default**.

### <a id="af-track-additional-ids"></a>Track additional device identifiers

If you are distributing your Android app **outside of the Google Play Store** and would like to track additional device identifiers (IMEI and MEID), you need to explicitly instruct the AdTrace SDK to do so. You can do that by calling the `setReadMobileEquipmentIdentity` method of the `AdTraceConfig` instance. **The AdTrace SDK does not collect these identifiers by default**.

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setReadMobileEquipmentIdentity(true);

AdTrace.create(adtraceConfig);
```

You will also need to add the `READ_PHONE_STATE` permission to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

### <a id="gdpr-forget-me"></a>GDPR right to be forgotten

In accordance with article 17 of the EU's General Data Protection Regulation (GDPR), you can notify AdTrace when a user has exercised their right to be forgotten. Calling the following method will instruct the AdTrace SDK to communicate the user's choice to be forgotten to the AdTrace backend:

```js
AdTrace.gdprForgetMe();
```

Upon receiving this information, AdTrace will erase the user's data and the AdTrace SDK will stop tracking the user. No requests from this device will be sent to AdTrace in the future.

[panel]:    http://panel.adtrace.io
[adtrace.io]:   http://adtrace.io

[example-app]:  ./example

[npm-repo]:     https://www.npmjs.com/package/react-native-adtrace

[rn-linking]:           https://facebook.github.io/react-native/docs/linking.html
[google-ad-id]:         https://support.google.com/googleplay/android-developer/answer/6048248?hl=en
[enable-ulinks]:        https://github.com/adtrace/adtrace_sdk_ios#deeplinking-setup-new
[broadcast-receiver]:   https://github.com/adtrace/adtrace_sdk_android#gps-intent

[google-launch-modes]:        http://developer.android.com/guide/topics/manifest/activity-element.html#lmode
[google-play-services]:       http://developer.android.com/google/play-services/index.html
[android-sdk-deeplink]:       https://github.com/adtrace/adtrace_sdk_android#deeplinking-standard
[google-play-services]:       http://developer.android.com/google/play-services/setup.html
[ios-sdk-deeplink-late]:      https://github.com/adtrace/adtrace_sdk_io#-deep-linking-on-ios-9-and-later
[ios-sdk-deeplink-early]:     https://github.com/adtrace/adtrace_sdk_ios#-deep-linking-on-ios-8-and-earlier
[broadcast-receiver-custom]:  https://github.com/adtrace/adtrace_sdk_android/blob/master/doc/english/multiple-receivers.md
