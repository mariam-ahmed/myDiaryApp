package com.diary.app.thesis.mobile_app;

import androidx.annotation.NonNull;

import java.math.BigInteger;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "phe_channel";
    private PHEService pheService = new PHEService();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "encrypt":
                            int value = call.argument("value");
                            BigInteger ciphertext = paillier.encrypt(BigInteger.valueOf(value));
                            result.success(ciphertext.toString());
                            break;
                        case "decrypt":
                            String decryptedText = pheService.decrypt(call.argument("ciphertext"));
                            result.success(decryptedText);
                            break;
                        case "addEncrypted":
                            String c1Str = call.argument("c1");
                            String c2Str = call.argument("c2");
                            BigInteger c1 = new BigInteger(c1Str);
                            BigInteger c2 = new BigInteger(c2Str);
                            BigInteger cSum = paillier.add(c1, c2);
                            result.success(cSum.toString());
                            break;
                        case "getPublicKey":
                            result.success(pheService.getPublicKey());
                            break;
                        case "getNSquare":
                            result.success(pheService.getNSquare());
                            break;
                        default:
                            result.notImplemented();
                    }
                });
    }
}
