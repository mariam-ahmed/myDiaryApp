package com.diary.app.thesis.mobile_app;

import android.content.Context;
import android.content.SharedPreferences;

import java.math.BigInteger;
import java.security.SecureRandom;

public class PHEService {
    private static BigInteger n, nsquare, g, lambda, mu;
    private static final int bitLength = 1024; // Secure bit length
    private static final String PREFS_NAME = "PHE_KEYS";

    private static Context context;

    public PHEService(Context context) {
        this.context = context;

    }

    void initKeys()
    {
        if (!keysExist(context)) {
            keyGeneration();
            saveKeys(context);
        } else {
            loadKeys(context);
        }
    }

    // Key generation for Paillier Homomorphic Encryption
    private static void keyGeneration() {
        System.out.println("Generating Key");
        SecureRandom random = new SecureRandom();
        BigInteger p = BigInteger.probablePrime(bitLength / 2, random);
        BigInteger q = BigInteger.probablePrime(bitLength / 2, random);
        n = p.multiply(q);
        System.out.println("n: "+n);
        nsquare = n.multiply(n);
        System.out.println("nsquare: "+nsquare);
        g = n.add(BigInteger.ONE);
        System.out.println("g: "+g);
        lambda = p.subtract(BigInteger.ONE).multiply(q.subtract(BigInteger.ONE));
        System.out.println("lambda: "+lambda);
        mu = lambda.modInverse(n);
        System.out.println("mu: "+mu);
    }

    private boolean keysExist(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        return prefs.contains("n") && prefs.contains("lambda");
    }

    private void saveKeys(Context context) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putString("n", n.toString());
        editor.putString("nsquare", nsquare.toString());
        editor.putString("g", g.toString());
        editor.putString("lambda", lambda.toString());
        editor.putString("mu", mu.toString());
        editor.apply();
    }

    private void loadKeys(Context context) {
        System.out.println("Loading Existing Keys");
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        n = new BigInteger(prefs.getString("n", ""));
        nsquare = new BigInteger(prefs.getString("nsquare", ""));
        g = new BigInteger(prefs.getString("g", ""));
        lambda = new BigInteger(prefs.getString("lambda", ""));
        mu = new BigInteger(prefs.getString("mu", ""));
    }

    public BigInteger getPublicKey() {
        return n;
    }

    public BigInteger getNSquare() {
        return nsquare;
    }

    // Encrypt value
    public String encrypt(String plaintext) {
        BigInteger m = new BigInteger(plaintext);
        BigInteger r = new BigInteger(bitLength, new SecureRandom());
        BigInteger c = g.modPow(m, nsquare).multiply(r.modPow(n, nsquare)).mod(nsquare);
        return c.toString();
    }

    // Decrypt value
    public String decrypt(String ciphertext) {
        BigInteger c = new BigInteger(ciphertext);
        BigInteger u = c.modPow(lambda, nsquare).subtract(BigInteger.ONE).divide(n);
        BigInteger m = u.multiply(mu).mod(n);
        return m.toString();
    }

    // Add encrypted values
    public String add(String c1Str, String c2Str) {
        BigInteger c1 = new BigInteger(c1Str);
        BigInteger c2 = new BigInteger(c2Str);
        return c1.multiply(c2).mod(nsquare).toString();
    }
}
