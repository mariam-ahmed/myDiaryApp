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
    public String encrypt(String plaintext) {
        BigInteger m = new BigInteger(plaintext);
        System.out.println("Plaintext (m): " + m);

        BigInteger r = new BigInteger(bitLength, new SecureRandom());
        System.out.println("Random (r): " + r);

        BigInteger c = g.modPow(m, nsquare).multiply(r.modPow(n, nsquare)).mod(nsquare);
        System.out.println("Encrypted (c): " + c);

        return c.toString();
    }

    // Decrypt classification tag
    public String decrypt(String ciphertext) {
        BigInteger c = new BigInteger(ciphertext);
        System.out.println("Ciphertext (c): " + c);
        BigInteger u = c.modPow(lambda, nsquare).subtract(BigInteger.ONE).divide(n);
        System.out.println("Intermediate (u): " + u);
        BigInteger m = u.multiply(mu).mod(n);
        System.out.println("Decrypted (m): " + m);
        return m.toString();
    }

    public String add(String c1Str, String c2Str) {
        // Convert String inputs to BigInteger
        BigInteger c1 = new BigInteger(c1Str);
        BigInteger c2 = new BigInteger(c2Str);

        // Perform Paillier addition: c1 * c2 mod n²
        BigInteger result = c1.multiply(c2).mod(nsquare);

        // Return the result as a String
        return result.toString();
    }
}
