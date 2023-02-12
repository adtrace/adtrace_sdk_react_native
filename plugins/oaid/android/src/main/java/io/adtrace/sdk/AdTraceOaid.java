package io.adtrace.oaid.nativemodule;

import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.*;
import io.adtrace.sdk.oaid.*;

public class AdTraceOaid extends ReactContextBaseJavaModule {
    public AdTraceOaid(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "AdTraceOaid";
    }

    @Override
    public void initialize() {
    }

    @ReactMethod
    public void readOaid() {
        io.adtrace.sdk.oaid.AdTraceOaid.readOaid(getReactApplicationContext());
    }

    @ReactMethod
    public void doNotReadOaid() {
        io.adtrace.sdk.oaid.AdTraceOaid.doNotReadOaid();
    }
}
