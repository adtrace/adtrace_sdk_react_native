declare module 'react-native-adtrace' {
  type Environment = 'sandbox' | 'production'
  type LogLevel = string
  type UrlStrategy = string

  interface AdTraceAttribution {
    trackerToken: string
    trackerName: string
    network: string
    campaign: string
    adgroup: string
    creative: string
    clickLabel: string
    adid: string
    costType: string
    costAmount: number
    costCurrency: string
  }

  interface AdTraceEventTrackingSuccess {
    message: string
    timestamp: string
    adid: string
    eventToken: string
    callbackId: string
    jsonResponse: string
  }

  interface AdTraceEventTrackingFailure {
    message: string
    timestamp: string
    adid: string
    eventToken: string
    callbackId: string
    willRetry: boolean
    jsonResponse: string
  }

  interface AdTraceSessionTrackingSuccess {
    message: string
    timestamp: string
    adid: string
    jsonResponse: string
  }

  interface AdTraceSessionTrackingFailure {
    message: string
    timestamp: string
    adid: string
    willRetry: boolean
    jsonResponse: string
  }

  interface AdTraceUri {
    uri: string
  }

  interface AdTraceConversionValue {
    conversionValue: number
  }

  interface AdTraceSkad4Data {
    fineValue: number
    coarseValue: string
    lockWindow: boolean
  }

  export class AdTraceConfig {
    constructor(appToken: string, environment: Environment)
    public setLogLevel(level: LogLevel): void
    public setEventBufferingEnabled(eventBufferingEnabled: boolean): void
    public setProcessName(processName: string): void
    public setDefaultTracker(defaultTracked: string): void
    public setExternalDeviceId(externalDeviceId: string): void
    public setUrlStrategy(urlStrategy: UrlStrategy): void
    public setUserAgent(userAgent: string): void
    public setAppSecret(
      secretId: number,
      info1: number,
      info2: number,
      info3: number,
      info4: number): void
    public setDelayStart(delayStart: number): void
    public setSendInBackground(sendInBackground: boolean): void
    public setDeviceKnown(isDeviceKnown: boolean): void
    public setNeedsCost(needsCost: boolean): void
    public setPreinstallTrackingEnabled(preinstallTrackingEnabled: boolean): void
    public setPreinstallFilePath(preinstallFilePath: string): void
    public setCoppaCompliantEnabled(coppaCompliantEnabled: boolean): void
    public setPlayStoreKidsAppEnabled(playStoreKidsAppEnabled: boolean): void
    public setAllowiAdInfoReading(allowiAdInfoReading: boolean): void
    public setAllowAdServicesInfoReading(allowAdServicesInfoReading: boolean): void
    public setAllowIdfaReading(allowIdfaReading: boolean): void
    public setSdkPrefix(sdkPrefix: string): void
    public setShouldLaunchDeeplink(shouldLaunchDeeplink: boolean): void
    public deactivateSKAdNetworkHandling(): void;
    public setLinkMeEnabled(linkMeEnabled: boolean): void;

    public setAttributionCallbackListener(
      callback: (attribution: AdTraceAttribution) => void
    ): void

    public setEventTrackingSucceededCallbackListener(
      callback: (eventSuccess: AdTraceEventTrackingSuccess) => void
    ): void

    public setEventTrackingFailedCallbackListener(
      callback: (eventFailed: AdTraceEventTrackingFailure) => void
    ): void

    public setSessionTrackingSucceededCallbackListener(
      callback: (sessionSuccess: AdTraceSessionTrackingSuccess) => void
    ): void

    public setSessionTrackingFailedCallbackListener(
      callback: (sessionFailed: AdTraceSessionTrackingFailure) => void
    ): void

    public setDeferredDeeplinkCallbackListener(
      callback: (uri: AdTraceUri) => void
    ): void

    public setConversionValueUpdatedCallbackListener(
      callback: (conversionValue: AdTraceConversionValue) => void
    ): void

    public setSkad4ConversionValueUpdatedCallbackListener(
      callback: (skad4Data: AdTraceSkad4Data) => void
    ): void

    static LogLevelVerbose: LogLevel
    static LogLevelDebug: LogLevel
    static LogLevelInfo: LogLevel
    static LogLevelWarn: LogLevel
    static LogLevelError: LogLevel
    static LogLevelAssert: LogLevel
    static LogLevelSuppress: LogLevel
    static EnvironmentSandbox: Environment
    static EnvironmentProduction: Environment
    static UrlStrategyChina: UrlStrategy
    static UrlStrategyIndia: UrlStrategy
    static DataResidencyEU: UrlStrategy
    static DataResidencyTR: UrlStrategy
    static DataResidencyUS: UrlStrategy
  }

  export class AdTraceEvent {
    constructor(eventToken: string)
    public setRevenue(revenue: number, currency: string): void
    public addCallbackParameter(key: string, value: string): void
    public addEventParameter(key: string, value: string): void
    public setTransactionId(transactionId: string): void
    public setCallbackId(callbackId: string): void
  }

  export class AdTraceAppStoreSubscription {
    constructor(price: string, currency: string, transactionId: string, receipt: string)
    public setTransactionDate(transactionDate: string): void
    public setSalesRegion(salesRegion: string): void
    public addCallbackParameter(key: string, value: string): void
    public addPartnerParameter(key: string, value: string): void
  }

  export class AdTracePlayStoreSubscription {
    constructor(
      price: string,
      currency: string,
      sku: string,
      orderId: string,
      signature: string,
      purchaseToken: string)
    public setPurchaseTime(purchaseTime: string): void
    public addCallbackParameter(key: string, value: string): void
    public addPartnerParameter(key: string, value: string): void
  }

  export class AdTraceThirdPartySharing {
    constructor(isEnabled: boolean)
    public addGranularOption(partnerName: string, key: string, value: string): void
    public addPartnerSharingSetting(partnerName: string, key: string, value: boolean): void
  }

  export class AdTraceAdRevenue {
    constructor(source: string)
    public setRevenue(revenue: number, currency: string): void
    public setAdImpressionsCount(adImpressionsCount: number): void
    public setAdRevenueNetwork(adRevenueNetwork: string): void
    public setAdRevenueUnit(adRevenueUnit: string): void
    public setAdRevenuePlacement(adRevenuePlacement: string): void
    public addCallbackParameter(key: string, value: string): void
    public addPartnerParameter(key: string, value: string): void
  }

  export const AdTrace: {
    componentWillUnmount: () => void
    create: (adtraceConfig: AdTraceConfig) => void
    trackEvent: (adtraceEvent: AdTraceEvent) => void
    setEnabled: (enabled: boolean) => void
    isEnabled: (callback: (enabled: boolean) => void) => void
    setOfflineMode: (enabled: boolean) => void
    setPushToken: (token: string) => void
    appWillOpenUrl: (url: string) => void
    sendFirstPackages: () => void
    trackAdRevenue: ((source: string, payload: string) => void) & ((source: AdTraceAdRevenue) => void)
    trackAppStoreSubscription: (subscription: AdTraceAppStoreSubscription) => void
    trackPlayStoreSubscription: (subscription: AdTracePlayStoreSubscription) => void
    addSessionCallbackParameter: (key: string, value: string) => void
    addSessionPartnerParameter: (key: string, value: string) => void
    removeSessionCallbackParameter: (key: string) => void
    removeSessionPartnerParameter: (key: string) => void
    resetSessionCallbackParameters: () => void
    resetSessionPartnerParameters: () => void
    gdprForgetMe: () => void
    disableThirdPartySharing: () => void
    getIdfa: (callback: (idfa: string) => void) => void
    getGoogleAdId: (callback: (adid: string) => void) => void
    getAdid: (callback: (adid: string) => void) => void
    getAttribution: (callback: (attribution: AdTraceAttribution) => void) => void
    // getAmazonAdId: (callback: (adid: string) => void) => void
    getSdkVersion: (callback: (sdkVersion: string) => void) => void
    setReferrer: (referrer: string) => void
    convertUniversalLink: (url: string, scheme: string, callback: (convertedUrl: string) => void) => void
    requestTrackingAuthorizationWithCompletionHandler: (handler: (status: number) => void) => void
    updateConversionValue: (conversionValue: number) => void
    updateConversionValueWithErrorCallback: (conversionValue: number, callback: (error: string) => void) => void
    updateConversionValueWithSkad4ErrorCallback: (conversionValue: number, coarseValue: string, lockWindow: boolean, callback: (error: string) => void) => void
    getAppTrackingAuthorizationStatus: (callback: (authorizationStatus: number) => void) => void
    trackThirdPartySharing: (adtraceThirdPartySharing: AdTraceThirdPartySharing) => void
    trackMeasurementConsent: (measurementConsent: boolean) => void
  }
}
