package com.diary.app.thesis.mobile_app;

import java.math.BigInteger;
import java.security.SecureRandom;

public class PHEService {
    private BigInteger n, nsquare, g, lambda, mu;
    private int bitLength = 1024; // Secure bit length

    public PHEService() {
        keyGeneration();
    }

    public BigInteger getPublicKey() {
        return n;
    }

    public BigInteger getNSquare() {
        return nsquare;
    }

    // Key generation for Paillier Homomorphic Encryption
    private void keyGeneration() {
        SecureRandom random = new SecureRandom();
        BigInteger p = BigInteger.probablePrime(bitLength / 2, random);
        BigInteger q = BigInteger.probablePrime(bitLength / 2, random);
        n = p.multiply(q);
        nsquare = n.multiply(n);
        g = n.add(BigInteger.ONE);
        lambda = p.subtract(BigInteger.ONE).multiply(q.subtract(BigInteger.ONE));
        mu = lambda.modInverse(n);
    }

    // Encrypt classification tag (homomorphic encryption)
    public String encrypt(String plaintext, BigInteger publicKey, BigInteger nsquare) {
        BigInteger m = new BigInteger(plaintext.getBytes());
        BigInteger r = new BigInteger(bitLength, new SecureRandom());
        BigInteger c = g.modPow(m, nsquare).multiply(r.modPow(n, nsquare)).mod(nsquare);
        return c.toString();
    }

    // Decrypt classification tag
    public String decrypt(String ciphertext) {
        BigInteger c = new BigInteger(ciphertext);
        BigInteger u = c.modPow(lambda, nsquare).subtract(BigInteger.ONE).divide(n);
        BigInteger m = u.multiply(mu).mod(n);
        return new String(m.toByteArray());
    }

    public BigInteger add(BigInteger c1, BigInteger c2) {
        return c1.multiply(c2).mod(nsquare);
    }
}
