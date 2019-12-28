declare module "react-native-adtrace" {
    type Environment = "sandbox" | "production";

    enum LogLevel {
        Verbose,
        Debug,
        Info,
        Warn,
        Error,
        Assert,
        Suppress
    }

    interface AdTraceAttribution {
        trackerToken: string;
        trackerName: string;
        network: string;
        campaign: string;
        adgroup: string;
        creative: string;
        clickLabel: string;
        adid: string;
    }

    interface AdTraceEventTrackingSuccess {
        message: string;
        timestamp: string;
        adid: string;
        eventToken: string;
        callbackId: string;
        jsonResponse: string;
    }

    interface AdTraceEventTrackingFailure {
        message: string;
        timestamp: string;
        adid: string;
        eventToken: string;
        callbackId: string;
        willRetry: boolean;
        jsonResponse: string;
    }

    interface AdTraceSessionTrackingSuccess {
        message: string;
        timestamp: string;
        adid: string;
        jsonResponse: string;
    }

    interface AdTraceSessionTrackingFailure {
        message: string;
        timestamp: string;
        adid: string;
        willRetry: boolean;
        jsonResponse: string;
    }

    interface AdTraceUri {
        uri: string;
    }

    export class AdTraceConfig {
        constructor(appToken: string, environment: Environment) { }

        public setLogLevel(level: LogLevel): void { }

        public setEventBufferingEnabled(isEnabled: boolean): void { }

        public setProcessName(processName: string): void { }

        public setDefaultTracker(defaultTracked: string): void { }

        public setUserAgent(userAgent: string): void { }

        public setAppSecret(secretId: number, info1: number, info2: number, info3: number, info4: number): void { }

        public setDelayStart(delayStart: number): void { }

        public setSendInBackground(sendInBackground: boolean): void { }

        public setEnableInstalledApps(enableInstalledApps: boolean): void { }

        public setDeviceKnown(isDeviceKnown: boolean): void { }

        public setSdkPrefix(sdkPrefix: string): void { }

        public setShouldLaunchDeeplink(shouldLaunchDeeplink: boolean): void { }

        public setAttributionCallbackListener(callback: (attribution: AdTraceAttribution) => void): void { }

        public setEventTrackingSucceededCallbackListener(callback: (eventSuccess: AdTraceEventTrackingSuccess) => void): void { }

        public setEventTrackingFailedCallbackListener(callback: (eventFailed: AdTraceEventTrackingFailure) => void): void { }

        public setSessionTrackingSucceededCallbackListener(callback: (sessionSuccess: AdTraceSessionTrackingSuccess) => void): void { }

        public setSessionTrackingFailedCallbackListener(callback: (sessionFailed: AdTraceSessionTrackingFailure) => void): void { }

        public setDeferredDeeplinkCallbackListener(callback: (uri: AdTraceUri) => void): void { }

        static get LogLevelVerbose(): LogLevel {
            return LogLevel.Verbose;
        }

        static get LogLevelDebug(): LogLevel {
            return LogLevel.Debug;
        }

        static get LogLevelInfo(): LogLevel {
            return LogLevel.Info;
        }

        static get LogLevelWarn(): LogLevel {
            return LogLevel.Warn;
        }

        static get LogLevelError(): LogLevel {
            return LogLevel.Error;
        }

        static get LogLevelAssert(): LogLevel {
            return LogLevel.Assert;
        }

        static get LogLevelSuppress(): LogLevel {
            return LogLevel.Suppress;
        }

        static get EnvironmentSandbox(): Environment {
            return "sandbox";
        }

        static get EnvironmentProduction(): Environment {
            return "production";
        }
    }

    export class AdTraceEvent {
        constructor(eventToken: string) { }

        public setRevenue(revenue: number, currency: string): void { }

        public addCallbackParameter(key: string, value: string): void { }

        public addPartnerParameter(key: string, value: string): void { }

        public setEventValue(eventValue: string): void { }

        public setCallbackId(callbackId: string): void { }
    }

    export const AdTrace = {
        componentWillUnmount: (): void => { },
        create: (AdTraceConfig: AdTraceConfig): void => { },
        trackEvent: (AdTraceEvent: AdTraceEvent): void => { },
        setEnabled: (enabled: boolean): void => { },
        isEnabled: (callback: (enabled: boolean) => void): void => { },
        setOfflineMode: (enabled: boolean): void => { },
        setPushToken: (token: string): void => { },
        appWillOpenUrl: (url: string): void => { },
        sendFirstPackages: (): void => { },
        addSessionCallbackParameter: (key: string, value: string): void => { },
        addSessionPartnerParameter: (key: string, value: string): void => { },
        removeSessionCallbackParameter: (key: string): void => { },
        removeSessionPartnerParameter: (key: string): void => { },
        resetSessionCallbackParameters: (): void => { },
        resetSessionPartnerParameters: (): void => { },
        gdprForgetMe: (): void => { },
        getIdfa: (callback: (idfa: string) => void): void => { },
        getGoogleAdId: (callback: (adid: string) => void): void => { },
        getAdid: (callback: (adid: string) => void): void => { },
        getAttribution: (callback: (attribution: AdTraceAttribution) => void): void => { },
        getAmazonAdId: (callback: (adid: string) => void): void => { },
        getSdkVersion: (callback: (sdkVersion: string) => void): void => { },
        setReferrer: (referrer: string): void => { },
    };
}
