<div dir="rtl" align='right'>فارسی | <a href="../../README.md">English</a></div>


<p align="center"><a href="https://adtrace.io" target="_blank" rel="noopener noreferrer"><img width="100" src="http://adtrace.io/fa/wp-content/uploads/2019/02/logo.png" alt="Adtrace logo"></a></p>

<p align="center">
  <a href='https://www.npmjs.com/package/react-native-adtrace'><img src='https://img.shields.io/npm/v/react-native-adtrace.svg'></a>
  <a href='https://opensource.org/licenses/MIT'><img src='https://img.shields.io/badge/License-MIT-green.svg'></a>
</p>

## <div dir="rtl" align='right'>خلاصه</div>

<div dir="rtl" align='right'>
SDK ریکت نیتیو ادتریس. شما برای اطلاعات بیشتر میتوانید به <a href="adtrace.io">adtrace.io</a>  مراجعه کنید.
</div>

## <div dir="rtl" align='right'>فهرست محتوا</div>

### <div dir="rtl" align='right'>پیاده سازی فوری</div>

<div dir="rtl" align='right'>
<ul>
  <li><a href="#qs-example-app">برنامه نمونه</a></li>
  <li><a href="#qs-getting-started">شروع پیاده سازی</a></li>
	  <ul>
	    <li><a href="#qs-sdk-get">دریافت SDK</a></li>
	    <li><a href="#qs-adtrace-project-settings">تنظیمات پیاده سازی</a></li>
	    <ul>
		    <li><a href="#qs-android-permissions">مجوزهای اندروید</a></li>
		    <li><a href="#qs-android-gps">سرویس های گوگل پلی</a></li>
		    <li><a href="#qs-android-proguard">تنظیمات Proguard</a></li>
		    <li><a href="#qs-android-referrer">تنظیمات Install referrer</a></li>
			    <ul>
			            <li><a href="#qs-android-referrer-gpr-api">Google Play Referrer API</a></li>
			            <li><a href="#qs-android-referrer-gps-intent">Google Play Store intent</a></li>
			    </ul>
			<li><a href="#qs-ios-frameworks">فریم ورک های  iOS</a></li>
	    </ul>
    </ul>
  <li><a href="#qs-integ-sdk">پیاده سازی SDK داخل برنامه</a></li>
  <ul>
      <li><a href="#qs-sdk-signature">امضا SDK</a></li>                 
      <li><a href="#qs-adtrace-logging">لاگ ادتریس</a></li>
  </ul>
  </ul>
</div>

### <div dir="rtl" align='right'>لینک دهی عمیق</div>

<div dir="rtl" align='right'>
<ul>
  <li><a href="#dl-overview">نمای کلی لینک دهی عمیق</a></li>                  
  <li><a href="#dl-standard">سناریو لینک دهی عمیق استاندار</a></li>
  <li><a href="#dl-deferred">سناریو لینک دهی عمیق به تعویق افتاده</a></li>
  <li><a href="#dl-reattribution">اتریبیوت مجدد از طریق لینک عمیق</a></li>
</ul>
</div>

### <div dir="rtl" align='right'>ردیابی رویداد</div>

<div dir="rtl" align='right'>
<ul>
  <li><a href="#et-track-event">ردیابی رویداد معمولی</a></li>                 
  <li><a href="#et-track-revenue">ردیابی رویداد درآمدی</a></li>
  <li><a href="#et-revenue-deduplication">جلوگیری از تکرار رویداد درآمدی</a></li>
</ul>
</div>

### <div dir="rtl" align='right'>پارامترهای سفارشی</div>

<div dir="rtl" align='right'>
<ul>
  <li><a href="#cp-overview">نمای کلی پارامترهای سفارشی</a></li>
  <li><a href="#cp-ep">پارامترهای رویداد</a>
    <ul>
      <li><a href="#cp-ep-callback">پارامترهای callback رویداد</a></li>                 
      <li><a href="#cp-ep-partner">پارامترهای partner رویداد</a></li>
      <li><a href="#cp-ep-id">شناسه callback رویداد</a></li>
      <li><a href="#cp-ep-value">مقدار رویداد</a></li>
    </ul>
  </li>                 
  <li><a href="#cp-sp" >پارامترهای نشست</a>
    <ul>
      <li><a href="#cp-sp-callback">پارامترهای callback نشست</a></li>                 
      <li><a href="#cp-sp-partner">پارامترهای partner نشست</a></li>
      <li><a href="#cp-sp-delay-start">شروع با تاخیر</a></li>
    </ul>
  </li>
</ul>
</div>

### <div dir="rtl" align='right'>ویژگی های بیشتر</div>

<div dir="rtl" align='right'>
<ul>
  <li><a href="#af-push-token">توکن push (ردیابی تعداد حذف برنامه)</a></li> 
  <li><a href="#af-attribution-callback">callback اتریبیوشن</a></li>
  <li><a href="#af-session-event-callbacks">callback های رویداد و نشست</a></li>
  <li><a href="#af-user-attribution">اتریبیوشن کاربر</a></li>                 
  <li><a href="#af-send-installed-apps">ارسال برنامه های نصب شده دستگاه</a></li>                  
  <li><a href="#af-di">شناسه های دستگاه</a>
    <ul>
      <li><a href="#af-di-idfa">شناسه تبلیغات iOS</a></li>
      <li><a href="#af-di-gps-adid">شناسه تبلیغات سرویس های گوگل پلی</a></li>                 
      <li><a href="#af-di-amz-adid">شناسه تبلیغات آمازون</a></li>
      <li><a href="#af-di-adid">شناسه دستگاه ادتریس</a></li>
    </ul>
  </li>                 
  <li><a href="#af-pre-installed-trackers">ردیابی قبل از نصب</a></li>                 
  <li><a href="#af-offline-mode">حالت آفلاین</a></li>                 
  <li><a href="#af-disable-tracking">غیرفعال کردن ردیابی</a></li>                 
  <li><a href="#af-event-buffering">بافرکردن رویدادها</a></li>                  
  <li><a href="#af-background-tracking">ردیابی در پس زمینه</a></li>                 
  <li><a href="#af-track-additional-ids">ردیابی شناسه های دیگر دستگاه</a></li>                  
  <li><a href="#af-gdpr-forget-me">GPDR</a></li>                  
</ul>
</div>

## <div dir="rtl" align='right'>پیاده سازی فوری</div>

### <div id="qs-example-app" dir="rtl" align='right'>برنامه نمونه</div>

<div dir="rtl" align='right'>
درون <a href="/example">پوشه <code>نمونه</code></a> یک برنامه ریکت نیتیو نمونه وجود دارد که میتوانید بررسی کنید SDK ادتریس چگونه پیاده سازی شده است.
</div>

### <div id="qs-getting-started" dir="rtl" align='right'>شروع پیاده سازی</div>

<div dir="rtl" align='right'>
در این بخش به صورت قدم به قدم مراحل پیاده سازی SDK ادتریس را درون پروژه ریکت نیتیو توضیح خواهیم داد. برای توسعه برنامه خود از هر نوع ادیتور متن یا  IDE برای ریکت نیتیو میتوانید استفاده کنید.
</div>

### <div id="qs-sdk-get" dir="rtl" align='right'>دریافت SDK</div>

<div dir="rtl" align='right'>
ابتدا کتابخانه را از طریق <code>npm</code> یا <code>yarn</code> دریافت کنید:
</div>
<br/>
 
```
$ npm install react-native-adtrace --save
```

<br/>
<div dir="rtl" align='right'>
بعد از دریافت، نیاز به نصب نیازمندی های مورد نظرمیباشید. برای این کار از توابع دستوری <code>react-native</code> استفاده میکنیم:
</div>
<br/>

```
$ react-native link react-native-adtrace
```

<br/>
<div dir="rtl" align='right'>
یا اگر شما برای <strong>iOS</strong> از CocoaPods استفاده میکنید، خط زیر را درون <code>Podfile</code> خود قرار داده و دستور <code>pod install</code> را اجرا نمایید.
</div>
<br/>

```
pod 'react-native-adtrace', :path => '../node_modules/react-native-adtrace'
```

<br/>
<div dir="rtl" align='right'>
برای <strong>iOS</strong> نیاز به تنظیمات دیگری نیست.
</div>
<br/>
<div dir="rtl" align='right'>
برای <strong>اندروید</strong> شما نیاز دارید که بررسی کنید موارد زیر به پروژه شما اضافه شده است یا خیر.
</div>
<br/>
<div dir="rtl" align='right'>
<ul>
	<li>درون کلاس <code>MainApplication.java</code> که در مسیر <code>./android/app/src/main/java/[your app]/MainApplication.java</code> قرار دارد بروید.</li>
	<li>داخل متد <code>()getpackages</code> به صورت پیشفرض باید به صورت زیر باشد:</li>
</ul>
</div>
<br/>

```js
@Override
protected List<ReactPackage> getPackages() {
  @SuppressWarnings("UnnecessaryLocalVariable")
  List<ReactPackage> packages = new PackageList(this).getPackages();
  return packages;
}
```

<br/>
<div dir="rtl" align='right'>
<ul>
	<li>
	بعد از افزودن SDK ادتریس از طریق <code>npm</code> یا <code>yarn</code> و وارد نمودن دستور <code>react-native link</code> پکیج ادتریس باید به صورت زیر وارد شده باشد:
	</li>
</ul>
</div>
<br/>

```js
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

<br/>
<div dir="rtl" align='right'>
<ul>
<li>در صورتی خط  <code>()new AdTracePackage</code> باید به صورت دستی به صورت بالا وارد نمایید در ضمن فراموش نکنید که درون فایل <code>MainApplication.java</code> خط به صورت زیر پکیج را ایمپورت کنید:</li>
</ul>
</div>
<br/>

```js
import com.adtrace.nativemodule.AdTracePackage;
```

### <div id="qs-adtrace-project-settings" dir="rtl" align='right'>تنظیمات پیاده سازی</div>

<div dir="rtl" align='right'>
هنگامی که SDK ادتریس را به برنامه خود اضافه کردید، مواردی دیگر لازم است تا ادتریس به درستی کار کند که در زیر به این موارد میپردازیم.
</div>

### <div id="qs-android-permissions" dir="rtl" align='right'>مجوزهای اندروید</div>

<div dir="rtl" align='right'>
در ادامه دسترسی های زیر را در فایل <code>AndroidManifest.xml</code> خود اضافه کنید:
</div>
<br/>

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

<br/>
<div dir="rtl" align='right'>
مجوز <code>INTERNET</code> برای ارسال داده های ادتریس استفاده میشود. مجوز <code>ACCESS_WIFI_STATE</code> برای استورهایی به جز گوگل پلی استفاده میشود و اگر برنامه شما فقط درون گوگل پلی بخواهد بکار برده شود، به این مجوز نیازی ندارید.
</div>

### <div id="qs-android-gps" dir="rtl" align='right'>سرویس های گوگل پلی</div>

<div dir="rtl" align='right'>
از تاریخ 1 آگوست 2014، برنامه های داخل گوگل پلی بایستی از <a href="https://support.google.com/googleplay/android-developer/answer/6048248?hl=en">شناسه تبلیغاتی گوگل</a> برای شناسایی یکتابودن دستگاه استفاده کنند. برای فعالسازی امکان استفاده از این شناسه خط زیر را به <code>dependencies</code> فایل <code>build.gradle</code> خود اضافه کنید:
</div>
<br/>

```gradle
implementation 'com.google.android.gms:play-services-ads-identifier:17.0.0'
```

<br/>
<div dir="rtl" align='right'>
<strong>نکته: </strong> SDK ادتریس محصور به استفاده از ورژن خاصی از <code>play-services-analytics</code> گوگل پلی نیست. بنابراین استفاده از آخرین نسخه این کتابخانه برای ادتریس مشکلی ایجاد نمیکند.
</div>
<br/>

<div dir="rtl" align='right'>
برای مشاهده اینکه سرویس گوگل پلی به درستی اضافه شده است، ادتریس را در حالت <code>sandbox</code> و لاگ را در سطح <code>verbose</code> قرار دهید. اگر بعد از ارسال تعدادی رویداد یا نشست، پارامتر <code>gps_adid</code> را مشاهده نمودید، پیاده سازی این بخش به درستی انجام شده است.
</div>

### <div id="qs-android-proguard" dir="rtl" align='right'>تنظیمات Proguard</div>

<div dir="rtl" align='right'>
اگر از Progaurd استفاده میکنید، دستورهای زیر را در فایل Progaurd خود اضافه کنید:
</div>
<br/>

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

### <div id="qs-android-referrer" dir="rtl" align='right'>تنظیمات Install referrer</div>

<div dir="rtl" align='right'>
برای آنکه به درستی نصب یک برنامه به سورس خودش اتریبیوت شود، ادتریس به اطلاعاتی درمورد <strong>install referrer</strong> نیاز دارد. این مورد با استفاده از <strong>Google Play Referrer API</strong> یا توسط <strong>Google Play Store intent</strong> بواسطه یک broadcast receiver دریافت میشود.
</div>
<br/>
<div dir="rtl" align='right'>
<strong>نکته مهم:</strong> Google Play Referrer API جدیدا راه حلی قابل اعتمادتر و با امنیت بیشتر برای جلو گیری از تقلب click injection  توسط گوگل  جدیدا معرفی شده است. <strong>به صورت اکید</strong> توصیه میشود که از این مورد در برنامه های خود استفاده کنید. Google Play Store intent امنیت کمتری در این مورد دارد و در آینده deprecate خواهد شد.
</div>

#### <div id="qs-android-referrer-gpr-api" dir="rtl" align='right'>Google Play Referrer API</div>

<div dir="rtl" align='right'>
به منظور استفاده از این کتابخانه خط زیر را در قسمت <code>build.gradle</code> برنامه خود اضافه کنید:
</div>
<br/>

```gradle
implementation 'com.android.installreferrer:installreferrer:1.1.2'
```

<br/>
<div dir="rtl" align='right'>
همچنین مطمئن شوید که درصورت داشتن Progaurd، بخش <a href="qs-proguard-settings">تنظیمات Progaurd</a> به صورت کامل اضافه شده است، مخصوصا دستور زیر:
</div>
<br/>

```
-keep public class com.android.installreferrer.** { *; }
```

#### <div id="qs-android-referrer-gps-intent" dir="rtl" align='right'>Google Play Store intent</div>

<div dir="rtl" align='right'>
گوگل طی <a href="https://android-developers.googleblog.com/2019/11/still-using-installbroadcast-switch-to.html">بیانیه ای</a> اعلام کرد که از 1 مارچ 2020 دیگر اطلاعات <code>INSTALL_REFERRER</code> را به صورت broadcast ارسال نمیکند، برای همین به رویکرد <a href="#qs-ir-gpr-api">Google Play Referrer API</a> مراجعه کنید.
</div>
<br/>
<div dir="rtl" align='right'>
شما بایستی اطلاعات <code>INSTALL_REFERRER</code> گوگل پلی را توسط یک broadcast receiver دریافت کنید. اگر از <strong>broadcast receiver خود</strong> استفاده نمیکنید، تگ <code>receiver</code> را داخل تگ <code>application</code> درون فایل <code>AndroidManifest.xml</code> خود اضافه کنید:
</div>
<br/>

```xml
<receiver
    android:name="io.adtrace.sdk.AdTraceReferrerReceiver"
    android:permission="android.permission.INSTALL_PACKAGES"
    android:exported="true" >
    <intent-filter>
        <action android:name="com.android.vending.INSTALL_REFERRER" />
    </intent-filter>
</receiver>
```

<br/>
<div dir="rtl" align='right'>
اگر قبلا از یک broadcast receiver برای دریافت اطلاعات <code>INSTALL_REFERRER</code> استفاده میکرده اید، از <a href="https://github.com/adtrace/adtrace_sdk_android/blob/master/doc/english/multiple-receivers.md">این دستورالعمل</a>  برای اضافه نمودن broadcast receiver ادتریس استفاده کنید.
</div>

### <div id="qs-ios-frameworks" dir="rtl" align='right'>فریم ورک های  iOS</div>

<div dir="rtl" align='right'>
داخل قسمت Project Navigator، در قسمت چپ ویو اصلی، هدف خود را انتخاب کنید. در تب <code>Build Phases</code>، گروه <code>Link Binary with Libraries</code> را باز کنید. در قسمت انتهایی دکمه <code>+</code> را کلیک کنید. قسمت <code>AdSupport.framework</code> را انتخاب کنید و گزینه <code>Add</code> را کلیک کنید. اگر در صورتی که برای <code>tvOS</code> استفاده نمیکنید، مراحل بالا را برای <code>iAd.framework</code> و <code>CoreTelephony.framework</code> را اضافه نمایید. مقدار <code>Status</code> هر دو فریم ورک را به <code>Optional</code> تغییر دهید. SDK ادتریس این فریم ورک ها را برای اهداف زیر استفاده میکند:
</div>
<br/>
<div dir="rtl" align='right'>
<ul>
	<li><code>iAd.framework</code> برای هنگامی که  کمپین iAd اجرا میکنید.</li>
	<li><code>AdSupport.framework</code> برای خواندن شناسه تبلیغاتی iOS یا همان IDFA</li>
	<li><code>CoreTelephony.framework</code> برای خواندن اطلاعات MNC و MCC</li>
</ul>
</div>
<br/>
<div dir="rtl" align='right'>
اگر شما مایل به اجرای کمپین iAd نیستید، میتوانید <code>iAd.framework</code> را پاک کنید.
</div>

### <div id="qs-integ-sdk" dir="rtl" align='right'>پیاده سازی SDK داخل برنامه</div>

<div dir="rtl" align='right'>
ابتدا در بالای فایل <code>.js</code> خود به صورت زیر ادتریس را ایمپورت کنید:
</div>
<br/>

```js
import { AdTrace, AdTraceEvent, AdTraceConfig } from 'react-native-adtrace';
```

<br/>
<div dir="rtl" align='right'>
برای راه اندازی SDK داخل فایل <code>App.js</code> خطهای زیر را وارد نمایید:
</div>
<br/>

```js
constructor(props) {
    super(props);
    const adtraceConfig = new AdTraceConfig("{YourAppToken}", AdTraceConfig.EnvironmentSandbox);
    AdTrace.create(adtraceConfig);
}

componentWillUnmount() {
  AdTrace.componentWillUnmount();
}
```

<br/>
<div dir="rtl" align='right'>
مقدار <code>{YourAppToken}</code> را با توکن اپ خود جایگزین نمایید. این مقدار را درون پنل ادتریس خود میتوانید مشاهده کنید.
</div>
<br/>
<div dir="rtl" align='right'>
وابسته به نوع خروجی اپ شما که درحالت تست یا تجاری میباشد، بایستی مقدار environment را یکی از مقادیر ریز انتخاب نمایید:
</div>
<br/>

```js
AdTraceConfig.EnvironmentSandbox
AdTraceConfig.EnvironmentProduction
```

<br/>
<div dir="rtl" align='right'>
<strong>نکته:</strong> این مقدار تنها در زمان تست برنامه شما بایستی مقدار <code> AdTraceConfig.EnvironmentSandbox</code> قرار بگیرد. این پارامتر را به <code>AdTraceConfig.EnvironmentProduction</code> قبل از انتشار برنامه خود تغییر دهید.
</div>
<br/>
<div dir="rtl" align='right'>
ادتریس enviroment را برای تفکیک ترافیک داده واقعی و آزمایشی بکار میبرد.
</div>

### <div id="qs-sdk-signature" dir="rtl" align='right'>امضا SDK</div>

<div dir="rtl" align='right'>
اگر امضا SDK فعال شده است، از متد زیر برای پیاده سازی استفاده کنید:
</div>
<br/>
<div dir="rtl" align='right'>
یک App Secret توسط متد <code>setAppSecret</code> داخل <code>AdTraceConfig</code> فراخوانی میشود:
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setAppSecret(secretId, info1, info2, info3, info4);

AdTrace.create(adtraceConfig);
```

### <div id="qs-adtrace-logging" dir="rtl" align='right'>لاگ ادتریس</div>

<div dir="rtl" align='right'>
شما میتوانید در حین تست لاگ ادتریس را از طریق <code>setLogLevel</code> که در <code>AdTraceConfig</code> قرار دارد کنترل کنید:
</div>
<br/>

```js
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelVerbose);   // enable all logging
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelDebug);     // enable more logging
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelInfo);      // the default
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelWarn);      // disable info logging
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelError);     // disable warnings as well
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelAssert);    // disable errors as well
adtraceConfig.setLogLevel(AdTraceConfig.LogLevelSuppress);  // disable all logging
```

## <div dir="rtl" align='right'>لینک دهی عمیق</div>

### <div id="dl-overview" dir="rtl" align='right'>نمای کلی لینک دهی عمیق</div>

<div dir="rtl" align='right'>
اگر از url ادتریس با تنظیمات deep link برای ترک کردن استفاده میکنید، امکان دریافت اطلاعات و محتوا دیپ لینک از طریق ادتریس فراهم میباشد. با کلیک کردن لینک کاربر ممکن است که قبلا برنامه را داشته باشد(سناریو لینک دهی عمیق استاندارد) یا اگر برنامه را نصب نداشته باشد(سناریو لینک دهی عمیق به تعویق افتاده) به کار برده شود. 
</div>

### <div id="dl-standard" dir="rtl" align='right'>سناریو لینک دهی عمیق استاندار</div>

<div dir="rtl" align='right'>
برای پشتیبانی لینک دهی عمیق درون پلتفرم اندروید،  فایل <code>AndroidManifest.xml</code> بایستی تغییر پیدا کند. برای اطلاعات بیشتر مربوط به تغییر <code>AndroidManifest.xml</code> به قسمت <a href="https://github.com/adtrace/adtrace_sdk_android/blob/master/doc/persian/README-PER.md#dl-overview">SDK اندروید</a> مراجعه کنید.
</div>
<br/>
<div dir="rtl" align='right'>
برای پشتیبانی لینک دهی عمیق برای پلتفرم iOS و نسخه 8 به قبل، فایل <code>Info.plist</code> بایستی تغییر پیدا کند. برای اطلاعات بیشتر مربوط به این تغییر به قسمت <a href="https://github.com/adtrace/adtrace_sdk_ios#deep-linking-on-ios-8-and-earlier">SDK iOS</a> مراجعه کنید.
</div>
<br/>
<div dir="rtl" align='right'>
برای پشتیبانی لینک دهی عمیق برای پلتفرم iOS و نسخه 9 به بعد، برنامه شما بایستی از لینک های Universal پشتیبانی کند. برای اطلاعات بیشتر مربوط به قسمت <a href="https://github.com/adtrace/adtrace_sdk_ios#deep-linking-on-ios-9-and-later">SDK iOS</a> مراجعه کنید.
</div>
<br/>
<div dir="rtl" align='right'>
بعد از آن، به <a href="https://facebook.github.io/react-native/docs/linking.html">داکیومنت اصلی ریکت نیتیو</a> برای اجرای لینک دهی عمیق در زبان جاوااسکریپت مراجعه کنید.
</div>

### <div id="dl-deferred" dir="rtl" align='right'>سناریو لینک دهی عمیق به تعویق افتاده</div>

<div dir="rtl" align='right'>
درحالیکه لینک دهی عمیق به تعویق افتاده به خودی خود در پلتفرم های اندروید و  iOS قابل پشتیبانی نیست، با استفاده از SDK ادتریس شما قابلیت پیاده سازی این سناریو را خواهید داشت.
</div>
<br/>
<div dir="rtl" align='right'>
برای آنکه در این سناریو اطلاعات محتوای آدرس را بدست آورید نیاز به ایجاد یک متد به صورت callback در <code>AdTraceConfig</code> دارید که اطلاعات URL به دست شما خواهد رسید. شما از طریق متد <code>setDeeplinkCallbackListener</code> میتوانید متد خودتان را فراخوانی کنید:
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setDeferredDeeplinkCallbackListener(function(deeplink) {
    console.log("Deferred deep link URL content: " + deeplink);
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
در این سناریو به تعویق افتاده، یک مورد اضافی بایستی به تنظیمات اضافه شود. هنگامی که SDK ادتریس اطاعات دیپ لینک را دریافت کرد، شما امکان این را دارید که SDK، با استفاده از این اطلاعات باز شود یا خیر که از طریق  متد <code>setOpenDeferredDeeplink</code> قابل استفاده است:
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setShouldLaunchDeeplink(true);
// or adtraceConfig.setShouldLaunchDeeplink(false);

adtraceConfig.setDeeplinkCallbackListener(function(deeplink) {
    console.log("Deferred deep link URL content: " + deeplink);
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
توجه فرمایید که اگر کالبکی تنظیم نشود، <strong>SDK ادتدریس در حالت پیشفرض تلاش میکند تا URL را اجرا کند</strong>.
</div>

### <div id="dl-reattribution" dir="rtl" align='right'>اتریبیوت مجدد از طریق لینک عمیق</div>

<div dir="rtl" align='right'>
اگر شما از این ویژگی استفاده میکنید، برای اینکه کاربر به درستی مجددا اتریبیوت شود، نیاز دارید یک دستور اضافی به برنامه خود اضافه کنید.
</div>
<br/>
<div dir="rtl" align='right'>
هنگامی که اطلاعات دیپ لینک را دریافت میکنید، متد <code>AdTrace.appWillOpenUrl(Uri, Context)</code>  را فراخوانی کنید. از طریق این SDK تلاش میکند تا ببیند اطلاعات جدیدی درون دیپ لینک برای اتریبیوت کردن قرار دارد یا خیر. اگر وجود داشت، این اطلاعات به سرور ارسال میشود.  اگر کاربر از طریق کلیک بر ترکر ادتریس مجددا اتریبیوت شود، میتوانید از قسمت <a href="#af-attribution-callback">اتریبیوشن کالبک</a> اطلاعات جدید را برای این کاربر دریافت کنید.
</div>
<br/>
<div dir="rtl" align='right'>
فراخوانی متد <code>AdTrace.appWillOpenUrl(Uri, Context)</code> بایستی مثل زیر باشد:
</div>
<br/>

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

## <div dir="rtl" align='right'>ردیابی رویداد</div>

### <div id="et-track-event" dir="rtl" align='right'>ردیابی رویداد معمولی</div>

<div dir="rtl" align='right'>
شما برای یک رویداد میتوانید از انواع رویدادها درون برنامه خود استفاده کنید. فرض کنید که میخواهید لمس یک دکمه را رصد کنید. بایستی ابتدا یک رویداد درون پنل خود ایجاد کنید. اگر فرض کنیم که توکن رویداد شما <code>abc123</code> باشد، سپس در متد <code>onClick</code> دکمه مربوطه کد زیر را برای ردیابی لمس دکمه اضافه کنید:
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");
AdTrace.trackEvent(adtraceEvent);
```

### <div id="et-track-revenue" dir="rtl" align='right'>ردیابی رویداد درآمدی</div>

<div dir="rtl" align='right'>
اگر کاربران شما از طریق کلیک بر روی تبلیغات یا پرداخت درون برنامه ای، رویدادی میتوانند ایجاد کنند، شما میتوانید آن درآمد را از طریق رویدادی مشخص رصد کنید. اگر فرض کنیم که یک ضربه به ارزش یک سنت از واحد یورو باشد، کد شما برای ردیابی این رویداد به صورت زیر میابشد:
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setRevenue(0.01, "EUR");

AdTrace.trackEvent(adtraceEvent);
```

<br/>
<div dir="rtl" align='right'>
این ویژگی میتواند با پارامترهای callback نیز ترکیب شود.
</div>
<br/>
<div dir="rtl" align='right'>
هنگامی که واحد پول را تنظیم کردید، ادتریس به صورت خودکار درآمدهای ورودی را به صورت خودکار به انتخاب شما تبدیل میکند.
</div>

### <div id="et-revenue-deduplication" dir="rtl" align='right'>جلوگیری از تکرار رویداد درآمدی</div>

<div dir="rtl" align='right'>
شما میتوانید یک شناسه خرید مخصوص برای جلوگیری از تکرار رویداد درآمدی استفاده کنید. 10 شناسه آخر ذخیره میشود و درآمدهای رویدادهایی که شناسه خرید تکراری دارند درنظر گرفته نمیشوند. این برای موارد خریددرون برنامه ای بسیار کاربرد دارد. به مثال زیر توجه کنید.
</div>
<br/>
<div dir="rtl" align='right'>
اگر میخواهید پرداخت درون برنامه ای ها را رصد کنید، فراخوانی متد <code>trackEvent</code> را زمانی انجام دهید که خرید انجام شده است و محصول خریداری شده است. بدین صورت شما از تکرار رویداد درآمدی جلوگیری کرده اید.
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setRevenue(0.01, "EUR");
adtraceEvent.setTransactionId("{YourTransactionId}");

AdTrace.trackEvent(adtraceEvent);
```

<br/>
<div dir="rtl" align='right'>
<strong>نکته</strong>: شناسه خرید یا همان <code>TransactionId</code> یک واژه در حوزه iOS میباشد. این شناسه یکتا در خرید درون حوزه اندروید به اسم <strong>Order ID</strong> شناخته میشود.
</div>

## <div dir="rtl" align='right'>پارامترهای سفارشی</div>

### <div id="cp-overview" dir="rtl" align='right'>نمای کلی پارامترهای سفارشی</div>

<div dir="rtl" align='right'>
علاوه بر داده هایی که SDK ادتریس به صورت خودکار جمع آوری میکند، شما از ادتریس میتوانید مقدارهای سفارشی زیادی را با توجه به نیاز خود (شناسه کاربر، شناسه محصول و ...) به رویداد یا نشست خود اضافه کنید. پارامترهای سفارشی تنها به صورت خام و export شده قابل دسترسی میباشد و در پنل ادتریس قابل نمایش <strong>نمیباشد</strong>.</div> 
<br/>
<div dir="rtl" align='right'>
شما از <strong>پارامترهای callback</strong> برای استفاده داخلی خود بکار میبرید و از <strong>پارامترهای partner</strong> برای به اشتراک گذاری به شریکان خارج از برنامه استفاده میکنید. اگر یک مقدار (مثل شناسه محصول) برای خود و شریکان خارجی استفاده میشود، ما پیشنهاد میکنیم که از هر دو پارامتر partner و callback استفاده کنید.
</div>

### <div id="cp-ep" dir="rtl" align='right'>پارامترهای رویداد</div>

### <div id="cp-ep-callback" dir="rtl" align='right'>پارامترهای callback رویداد</div>

<div dir="rtl" align='right'>
شما میتوانید یک آدرس callback برای رویداد خود داخل پنل اضافه کنید. ادرتیس یک درخواست GET به آن آدرسی که اضافه نموده اید، ارسال خواهد کرد. همچنین پارامترهای callback برای آن رویداد را از طریق متد <code>addCallbackParameter</code> برای آن رویداد قبل از ترک آن استفاده کنید. ما این پارامترها را به آخر آدرس callback شما اضافه خواهیم کرد.
</div>
<br/>
<div dir="rtl" align='right'>
به عنوان مثال اگر شما آدرس <code>http://www.example.com/callback</code> را به رویداد خود اضافه نموده اید، ردیابی رویداد به صورت زیر خواهد بود:
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.addCallbackParameter("key", "value");
adtraceEvent.addCallbackParameter("foo", "bar");

AdTrace.trackEvent(adtraceEvent)
```

<br/>
<div dir="rtl" align='right'>
در اینصورت ما رویداد شما را رصد خواهیم کرد و یک درخواست به صورت زیر ارسال خواهیم کرد:
</div>
<br/>

```
http://www.example.com/callback?key=value&foo=bar
```

### <div id="cp-ep-partner" dir="rtl" align='right'>پارامترهای partner رویداد</div>

<div dir="rtl" align='right'>
شما همچنین پارامترهایی را برای شریکان خود تنظیم کنید که درون پنل ادتریس فعالسازی میشود.
</div>
<br/>
<div dir="rtl" align='right'>
این پارامترها به صورت callback که در بالا مشاهده میکنید استفاده میشود، فقط از طریق متد <code>addPartnerParameter</code> درون یک شی از <code>AdTraceEvent</code> فراخوانی میشود.
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.addPartnerParameter("key", "value");
adtraceEvent.addPartnerParameter("foo", "bar");

AdTrace.trackEvent(adtraceEvent);
```

### <div id="cp-ep-id" dir="rtl" align='right'>شناسه callback رویداد</div>

<div dir="rtl" align='right'>
شما همچنین میتوانید یک شناسه به صورت رشته برای هریک از رویدادهایی که رصد کردید اضافه کنید. این شناسه بعدا در callback موفق یا رد شدن آن رویداد به دست شما خواهد رسید که متوجه شوید این ردیابی به صورت موفق انجام شده است یا خیر. این مقدار از طریق متد <code>setCallbackId</code> درون شی  از <code>AdTraceEvent</code> قابل تنظیم است.
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setCallbackId("Your-Custom-Id");

AdTrace.trackEvent(adtraceEvent);
```

### <div id="cp-ep-value" dir="rtl" align='right'>مقدار رویداد</div>

<div dir="rtl" align='right'>
شما همچنین یک رشته دلخواه به رویداد خود میتوانید اضافه کنید. این مقدار از طریق <code>setEventValue</code> قابل استفاده است:
</div>
<br/>

```js
var adtraceEvent = new AdTraceEvent("abc123");

adtraceEvent.setEventValue("Your-Value");

AdTrace.trackEvent(adtraceEvent);
```

### <div id="cp-sp" dir="rtl" align='right'>پارامترهای نشست</div>

<div dir="rtl" align='right'>
پارامترهای نشست به صورت محلی ذخیره میشوند و به همراه هر <strong>رویداد</strong> یا <strong>نشست</strong> ادتریس ارسال خواهند شد. هنگامی که هرکدام از این پارامترها  اضافه شدند، ما آنها را ذخیره خواهیم کرد پس نیازی به اضافه مجدد آنها نیست. افزودن مجدد پارامترهای مشابه تاثیری نخواهد داشت.
</div>
<br/>
<div dir="rtl" align='right'>
این پارامترها میتوانند قبل از شروع SDK ادتریس تنظیم شوند. اگر میخواهید هنگام نصب آنها را ارسال کنید، ولی پارامترهای آن بعد از نصب دراختیار شما قرار میگیرد، برای اینکار میتوانید از <a href="#cp-sp-delay-start">تاخیر</a> در شروع اولیه استفاده کنید.
</div>

### <div id="cp-sp-callback" dir="rtl" align='right'>پارامترهای callback نشست</div>

<div dir="rtl" align='right'>
شما میتوانید هرپارامتر callback ای که برای <a href="#cp-ep-callback">رویدادها</a> ارسال شده را در هر رویداد یا نشست ادتریس ذخیره کنید.
</div>
<br/>
<div dir="rtl" align='right'>
این پارامترهای callback نشست مشابه رویداد میباشد. برخلاف اضافه کردن key و value به یک رویداد، آنها را از طریق متد <code>AdTrace.addSessionCallbackParameter(String key, String value)</code> استفاده کنید:
</div>
<br/>

```js
AdTrace.addSessionCallbackParameter("foo", "bar");
```

<br/>
<div dir="rtl" align='right'>
پارامترهای callback نشست با پارامترهای callback به یک رویداد افزوده اید ادغام خواهد شد. پارامترهای رویداد بر نشست تقدم و برتری دارند، بدین معنی که اگر شما پارامتر callback یک ایونت را با یک key مشابه که به نشست افزوده شده است، این مقدار نسبت داده شده به این key از رویداد استفاده خواهد کرد.
</div>
<br/>
<div dir="rtl" align='right'>
این امکان فراهم هست که مقدار پارامترهای callback نشست از طریق key مورد نظربا متد <code>AdTrace.removeSessionCallbackParameter(String key)</code> حذف شود:
</div>
<br/>

```js
AdTrace.removeSessionCallbackParameter("foo");
```

<br/>
<div dir="rtl" align='right'>
اگر شما مایل هستید که تمام مقدایر پارامترهای callback نشست را پاک کنید، بایستی از متد <code>()AdTrace.resetSessionCallbackParameters</code> استفاده کنید:
</div>
<br/>

```js
AdTrace.resetSessionCallbackParameters();
```

### <div id="cp-sp-partner" dir="rtl" align='right'>پارامترهای partner نشست</div>

<div dir="rtl" align='right'>
به همین صورت پارامترهای partner مثل <a href="#cp-sp-callback">پارامترهای callback نشست</a> در هر رویداد یا نشست ارسال خواهند شد.
</div>
<br/>
<div dir="rtl" align='right'>
این مقادیر برای تمامی شریکان که در پنل خود فعالسازی کردید ارسال میشود.
</div>
<br/>
<div dir="rtl" align='right'>
پارامترهای partner نشست همچون رویداد میباشد. بایستی از متد <code>AdTrace.addSessionPartnerParameter(String key, String value)</code> استفاده شود:
</div>
<br/>

```js
AdTrace.addSessionPartnerParameter("foo", "bar");
```

<br/>
<div dir="rtl" align='right'>
پارامترهای partner نشست با پارامترهای partner به یک رویداد افزوده اید ادغام خواهد شد. پارامترهای رویداد بر نشست تقدم و برتری دارند، بدین معنی که اگر شما پارامتر partner یک ایونت را با یک key مشابه که به نشست افزوده شده است، این مقدار نسبت داده شده به این key از رویداد استفاده خواهد کرد.
</div>
<br/>
<div dir="rtl" align='right'>
این امکان فراهم هست که مقدار پارامترهای partner نشست از طریق key مورد نظربا متد <code>AdTrace.removeSessionPartnerParameter(String key)</code> حذف شود:
</div>
<br/>

```js
AdTrace.removeSessionPartnerParameter("foo");
```

<br/>
<div dir="rtl" align='right'>
اگر شما مایل هستید که تمام مقدایر پارامترهای partner نشست را پاک کنید، بایستی از متد <code>()AdTrace.resetSessionPartnerParameters</code> استفاده کنید:
</div>
<br/>

```js
AdTrace.resetSessionPartnerParameters();
```

### <div id="cp-sp-delay-start" dir="rtl" align='right'>شروع با تاخیر</div>

<div dir="rtl" align='right'>
شروع با تاخیر SDK ادتریس این امکان را به برنامه شما میدهد تا پارامترهای نشست شما در زمان نصب ارسال شوند.
</div>
<br/>
<div dir="rtl" align='right'>
  با استفاده از متد <code>setDelayStart</code> که ورودی آن عددی به ثانیه است، باعث تاخیر در شروع اولیه خواهد شد:
</div>
<br/>

```js
adtraceConfig.setDelayStart(5.5);
```

<br/>
<div dir="rtl" align='right'>
در این مثال SDK ادتریس مانع از ارسال نشست نصب اولیه و هر رویدادی با تاخیر 5.5 ثانیه خواهد شد. بعد از اتمام این زمان (یا فراخوانی متد <code>()AdTrace.sendFirstPackages</code> در طی این زمان) هر پارامتر نشستی با تاخیر آن زمان افزوده خواهد شد و بعد آن ادتریس به حالت عادی به کار خود ادامه میدهد.
</div>
<br/>
<div dir="rtl" align='right'>
<strong>بیشترین زمان ممکن برای تاخیر در شروع SDK ادتریس 10 ثانیه خواهد بود.</strong>
</div>

## <div dir="rtl" align='right'>ویژگی های بیشتر</div>

<div dir="rtl" align='right'>
هنگامی که شما SDK ادتریس را پیاده سازی کردید، میتوانید از ویژگی های زیر بهره ببرید:
</div>

### <div id="af-push-token" dir="rtl" align='right'>توکن push (ردیابی تعداد حذف برنامه)</div>

<div dir="rtl" align='right'>
توکن پوش برای برقراری ارتباط با کاربران استفاده میشود، همچنین برای ردیابی تعداد حذف یا نصب مجدد برنامه از این توکن استفاده میشود.
</div>
<br/>
<div dir="rtl" align='right'>
برای ارسال توکن پوش نوتیفیکشین خط زیر را در قسمتی که کد را دریافت کرده اید (یا هنگامی که مقدار آن تغییر میکند) اضافه نمایید:
</div>
<br/>

```js
AdTrace.setPushToken("YourPushNotificationToken");
```

### <div id="af-attribution-callback" dir="rtl" align='right'>callback اتریبیوشن</div>

<div dir="rtl" align='right'>
شما میتوانید یک listener هنگامی که اتریبیشون ترکر تغییر کند، داشته باشید. ما امکان فراهم سازی این اطلاعات را به صورت همزمان به دلیل تنوع منبع اتریبیوشن را نداریم.
</div>
<br/>
<div dir="rtl" align='right'>
برای callback اتریبیشون  قبل از شروع SDK موارد زیر را اضافه کنید:
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setAttributionCallbackListener(function(attribution) {
	//
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
این تابع بعد از دریافت آخرین اطلاعات اتریبیوشن صدا زده خواهد شد. با این تابع، به پارامتر <code>attribution</code> دسترسی پیدا خواهید کرد. موارد زیر یک خلاصه ای از امکانات گفته شده است:
</div>
<div dir="rtl" align='right'>
<ul>
<li><code>trackerToken</code> توکن ترکر از اتریبیوشن درحال حاضر است و جنس آن رشته میباشد.</li>
<li><code>trackerName</code> اسم ترکر از اتریبیوشن درحال حاضر است و جنس آن رشته میباشد.</li>
<li><code>network</code> لایه نتورک از اتریبیوشن درحال حاضر است و جنس آن رشته میباشد.</li>
<li><code>campain</code> لایه کمپین از اتریبیوشن درحال حاضر است و جنس آن رشته میباشد.</li>
<li><code>adgroup</code> لایه ادگروپ از اتریبیوشن درحال حاضر است و جنس آن رشته میباشد.</li>
<li><code>creative</code> لایه کریتیو از اتریبیوشن درحال حاضر است و جنس آن رشته میباشد.</li>
<li><code>adid</code> شناسه ادتریس است و جنس آن رشته میباشد.</li>
<ul>
</div>

### <div id="af-session-event-callbacks" dir="rtl" align='right'>callback های رویداد و نشست</div>

<div dir="rtl" align='right'>
این امکان فراهم است که یک listener هنگامی که رویداد یا نشستی ردیابی میشود، به اطلاع شما برساند. چهار نوع listener داریم: یکی برای ردیابی موفق بودن رویدادها، یکی برای ردیابی ناموفق بودن رویدادها، دیگری برای موفق بودن نشست و آخری نیز برای ناموفق بودن ردیابی نشست. برای درست کردن همچین listener هایی به صورت زیر عمل میکنیم:
</div>
<br/>

<div dir="rtl" align='right'>
ردیابی موفق رویدادها
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setEventTrackingSucceededCallbackListener(function(eventSuccess) {
	//
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
ردیابی ناموفق رویدادها
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setEventTrackingFailedCallbackListener(function(eventFailure) {
    //
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
ردیابی موفق نشست
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setSessionTrackingSucceededCallbackListener(function(sessionSuccess) {
    //
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
ردیابی ناموفق نشست
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setSessionTrackingFailedCallbackListener(function(sessionFailure) {
    //
});

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
listener ها هنگامی فراخوانده میشوند که SDK تلاش به ارسال داده سمت سرور کند. با این listener شما دسترسی به  داده های دریافتی دارید. موارد زیر یک خلاصه ای از داده های دریافتی هنگام نشست موفق میباشد:
</div>
<br/>
<div dir="rtl" align='right'>
<ul>
<li><code>var message</code> پیام از طرف سرور(یا ارور از طرف SDK)</li>
<li><code>var timestamp</code> زمان دریافتی از سرور</li>
<li><code>var adid</code> یک شناسه یکتا که از طریق ادتریس ساخته شده است</li>
<li><code>var jsonResponse</code> شی JSON دریافتی از سمت سرور</li>
</ul>
</div>
<br/>
<div dir="rtl" align='right'>
هر دو داده دریافتی رویداد شامل موارد زیر میباشد:
</div>
<br/>
<div dir="rtl" align='right'>
<ul>
<li><code>var eventToken</code> توکن مربوط به رویداد مورد نظر</li>
<li><code>var cakkbackId</code> <a href="#cp-ep-id">شناسه callback</a> که برای یک رویداد تنظیم میشود</li>
</ul>
</div>
<br/>
<div dir="rtl" align='right'>
و هر دو رویداد و نشست ناموفق شامل موارد زیر میشوند:
</div>
<br/>
<div dir="rtl" align='right'>
<ul>
<li><code>var willRetry</code> یک boolean ای  تلاش مجدد برای ارسال داده را نشان میدهد.</li>
</ul>
</div>

### <div id="af-user-attribution" dir="rtl" align='right'>اتریبیوشن کاربر</div>

<div dir="rtl" align='right'>
همانطور که در بخش <a href="#af-attribution-callback">callback اتریبیوشن</a> توضیح دادیم، این  callback هنگامی که اطلاعات اتریبیوشن عوض بشود، فعالسازی میشود. برای دسترسی به اطلاعات اتریبیوشن فعلی کاربر درهر زمانی که نیاز بود از طریق متد زیر قابل دسترس است:
</div>
<br/>

```js
AdTrace.getAttribution((attribution) => {
    //
});
```

<br/>
<div dir="rtl" align='right'>
<strong>نکته</strong>: اطلاعات اتریبیوشن فعلی تنها درصورتی دردسترس است که از سمت سرور نصب برنامه ردیابی شود و از طریق callback اتریبیوشن فعالسازی شود. <strong>امکان این نیست که</strong> قبل از اجرا اولیه SDK  و فعالسازی callback اتریبیوشن بتوان به داده های کاربر دسترسی پیدا کرد.
</div>

### <div id="af-send-installed-apps" dir="rtl" align='right'>ارسال برنامه های نصب شده دستگاه</div>

<div dir="rtl" align='right'>
برای افزایش دقت و امنیت در تشخیص تقلب برنامه ای، میتوانید برنامه های ئرون دستگاه کاربر را برای ارسال سمت سرور به صورت زیر فعالسازی کنید:
</div>
<br/>

```js
adtraceConfig.setEnableSendInstalledApps(true);
```

<br/>
<div dir="rtl" align='right'>
<strong>نکته</strong>: این ویژگی در حالت پیشفرض <strong>غیرفعال</strong> میباشد.
</div>

### <div id="af-di" dir="rtl" align='right'>شناسه های دستگاه</div>

<div dir="rtl" align='right'>
SDK ادتریس انواع شناسه ها رو به شما پیشنهاد میکند.
</div>

### <div id="af-di-idfa" dir="rtl" align='right'>شناسه تبلیغات iOS</div>

<div dir="rtl" align='right'>
برای دستیابی به شناسه iOS یا همان IDFA میتوانید به صورت زیر عمل کنید:
</div>
<br/>

```js
AdTrace.getIdfa((idfa) => {
	//
});
```

### <div id="af-di-gps-adid" dir="rtl" align='right'>شناسه تبلیغات سرویس های گوگل پلی</div>

<div dir="rtl" align='right'>
سرویس های مشخص (همچون Google Analytics) برای هماهنگی بین شناسه تبلیغات و شناسه کاربر به جهت ممانعت از گزارش تکراری به شما نیاز دارد.
</div>
<br/>

<div dir="rtl" align='right'>
برای دستیابی به شناسه تبلیغاتی گوگل لازم است تا یک تابع callback به متد <code>AdTrace.getGoogleAdId</code> که این شناسه را دریافت میکند به صورت زیر استفاده کنید:
</div>
<br/>

```js
AdTrace.getGoogleAdId((googleAdId) => {
	//
});
```


### <div id="af-di-amz-adid" dir="rtl" align='right'>شناسه تبلیغات آمازون</div>

<div dir="rtl" align='right'>
برای دستیابی به شناسه تبلیغاتی آمازون لازم است تا یک تابع callback به متد <code>AdTrace.getAmazonAdId</code> که این شناسه را دریافت میکند به صورت زیر استفاده کنید:
</div>
<br/>

```js
AdTrace.getAmazonAdId((amazonAdId) => {
    //
});
```

### <div id="af-di-adid" dir="rtl" align='right'>شناسه دستگاه ادتریس</div>

<div dir="rtl" align='right'>
برای هر دستگاهی که نصب میشود، سرور ادتریس یک <strong>شناسه یکتا</strong> (که به صورت <strong>adid</strong> نامیده ومشود) تولید میکند. برای دستیابی به این شناسه میتوانید به صورت زیر استفاده کنید:
</div>
<br/>

```js
AdTrace.getAdid((adid) => {
    //
});
```

<br/>
<div dir="rtl" align='right'>
<strong>نکته</strong>: اطلاعات مربوط به شناسه <strong>شناسه ادتریس</strong> تنها بعد از ردیابی نصب توسط سرور ادتریس قابل درسترس است. دسترسی به شناسه ادتریس قبل این ردیابی و یا قبل راه اندازی ادتریس <strong>امکان پذیر نیست</strong>.
</div>

### <div id="af-pre-installed-trackers" dir="rtl" align='right'>ردیابی قبل از نصب</div>

<div dir="rtl" align='right'>
اگر مایل به این هستید که SDK ادتریس تشخیص این را بدهد که کدام کاربرانی از طریق نصب از پیشن تعیین شده وارد برنامه شده اند مراحل زیر را انجام دهید:
</div>
<br/>
<div dir="rtl" align='right'>
<ul>
<li>یک ترکر جدید در پنل خود ایجاد نمایید.</li>
<li>در تنظیمات SDK ادتریس مثل زیر ترکر پیشفرض را اعمال کنید:</li>
</ul>
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setDefaultTracker("{TrackerToken}");

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
<ul>
<li>مقدار <code>{TrackerToken}</code> را با مقدار توکن ترکری که در مرحله اول دریافت کرده اید جاگزین کنید.</li>
<li>برنامه خود را بسازید. در قسمت خروجی لاگ خود همچین خطی را مشاهده خواهید کرد.</li>
</ul>
</div>
<br/>

  ```
  Default tracker: 'abc123'
  ```

### <div id="af-offline-mode" dir="rtl" align='right'>حالت آفلاین</div>

<div dir="rtl" align='right'>
برای مسدودسازی ارتباط SDK با سرورهای ادتریس میتوانید از حالت آفلاین SDK استفاده کنید(درحالیکه مجموعه داده ها بعدا برای رصد کردن ارسال میشود). در حالت آفلاین تمامی اطلاعات درون یک فایل ذخیره خواهد شد. توجه کنید که در این حالت رویدادهای زیادی را ایجاد نکنید.
</div>
<br/>
<div dir="rtl" align='right'>
برای فعالسازی حالت آفلاین متد <code>setOfflineMode</code> را با پارامتر <code>true</code> فعالسازی کنید.
</div>
<br/>

```js
AdTrace.setOfflineMode(true);
```

<br/>
<div dir="rtl" align='right'>
بر عکس حالت بالا با فراخوانی متد <code>setOfflineMode</code> به همراه متغیر <code>false</code> میتوانید این حالت آفلاین را غیرفعال کنید. هنگامی که SDK ادتریس به حالت آنلاین برگردد، تمامی اطلاعات ذخیر شده با زمان صحیح مربوط به خودش سمت سرور ارسال میشود.
</div>
<br/>
<div dir="rtl" align='right'>
برخلاف غیرفعال کردن ردیابی، این تنظیم بین نشست ها <strong>توصیه نمیشود</strong>. این بدین معنی است که SDK هرزمان که شروع شود در حالت آنلاین است، حتی اگر برنامه درحالت آفلاین خاتمه پیدا کند.
</div>

### <div id="af-disable-tracking" dir="rtl" align='right'>غیرفعال کردن ردیابی</div>

<div dir="rtl" align='right'>
شما میتوانید SDK ادتریس را برای رصدکردن هرگونی فعالیت برای این دستگاه غیر فعال کنید که این کار از طریق متد <code>setEnabled</code> با پارامتر <code>false</code> امکان پذیر است. <strong>این تنظیم بین نشست ها به خاطر سپرده میشود</strong>.
</div>
<br/>

```js
AdTrace.setEnabled(false);
```

<br/>
<div dir="rtl" align='right'>
شما برای اطلاع از فعال بودن ادتریس میتوانید از تابع <code>isEnabled</code> استفاده کنید. این امکان فراهم است که  SDK ادتریس را با متد <code>setEnabled</code> و پارامتر <code>true</code> فعالسازی کنید.
</div>

### <div id="af-event-buffering" dir="rtl" align='right'>بافرکردن رویدادها</div>

<div dir="rtl" align='right'>
اگر برنامه شما استفاده زیادی از رویدادها میکند، ممکن است بخواهید با یک حالت تاخیر و در یک مجموعه هر دقیقه ارسال کنید. میتوانید از طریق زیر بافرکردن رویدادها را فعالسازی کنید:
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setEventBufferingEnabled(true);

AdTrace.create(adtraceConfig);
```

### <div id="af-background-tracking" dir="rtl" align='right'>ردیابی در پس زمینه</div>

<div dir="rtl" align='right'>
رفتار پیشفرض SDK ادتریس هنگامی که برنامه در حالت پس زمینه قرار دارد، به صورت متوقف شده از ارسال داده ها میباشد. برای تغییر این مورد میتوانید به صورت زیر عمل کنید:
</div>
<br/>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setSendInBackground(true);

AdTrace.create(adtraceConfig);
```

### <div id="af-track-additional-ids" dir="rtl" align='right'>ردیابی شناسه های دیگر دستگاه</div>

<div dir="rtl" align='right'>
اگر برنامه اندروید شما <strong>خارج از پلی استور</strong> قرار است استفاده شود و میخواهید شناسه های دیگری را همچون (IMEI و MEID) ردیابی کنید، نیاز به یه سری موارد اضافی در SDK ادتریس میباشد. شما برای این کار میتوانید از متد <code>setReadMobileEquipmentIdentity</code> داخل <code>AdTraceconfig</code> استفاده کنید. <strong>ادتریس در حالت پیشفرض این شناسه ها را ردیابی نمیکند.</strong>
</div>

```js
var adtraceConfig = new AdTraceConfig(appToken, environment);

adtraceConfig.setReadMobileEquipmentIdentity(true);

AdTrace.create(adtraceConfig);
```

<br/>
<div dir="rtl" align='right'>
همچنین نیاز است که مجوز <code>READ_PHONE_STATE</code> داخل فایل <code>AndroidManifest.xml</code> اضافه کنید:
</div>
<br/>

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

### <div id="af-gdpr-forget-me" dir="rtl" align='right'>GPDR</div>

<div dir="rtl" align='right'>
بر طبق قانون GPDR شما این اعلان را به ادتریس میتوانید بکنید هنگامی که کاربر حق این را دارد که اطلاعاتش محفوظ بماند. از طریق متد زیر میتوانید این کار را انجام دهید:
</div>
<br/>

```js
AdTrace.gdprForgetMe();
```

<br/>
<div dir="rtl" align='right'>
طی دریافت این داده، ادتریس تمامی داده های کاربر را پاک خواهد کرد و ردیابی کاربر را متوقف خواهد کرد. هیچ درخواستی از این دستگاه به ادتریس در آینده ارسال نخواهد شد.
</div>
<br/>
<div dir="rtl" align='right'>
درنظر داشته باشید که حتی در زمان تست، این تصمیم بدون تغییر خواهد بود و قابل برگشت <strong>نیست</strong>.
</div>
