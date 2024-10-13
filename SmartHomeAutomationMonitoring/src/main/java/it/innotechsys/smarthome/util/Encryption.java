package it.innotechsys.smarthome.util;

import javax.crypto.*;
import javax.crypto.spec.SecretKeySpec;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class Encryption {

    private static Encryption instance = null;
    private final SecretKey SECRET_KEY = getSecretKey("InnovativeTelecommunication+2024");

    private Encryption() {}

    public static Encryption getInstance() {
        if(instance == null) {
            instance = new Encryption();
        }
        return instance;
    }

    public String encrypt(String plainText) {
        try {
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, SECRET_KEY);
            return Base64.getEncoder().encodeToString(cipher.doFinal(plainText.getBytes()));
        } catch (NoSuchAlgorithmException | NoSuchPaddingException | IllegalBlockSizeException | BadPaddingException | InvalidKeyException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String decrypt(String ciphertext) {
        try {
            Cipher decryptCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            decryptCipher.init(Cipher.DECRYPT_MODE, SECRET_KEY);
            return new String(decryptCipher.doFinal(Base64.getDecoder().decode(ciphertext)));
        } catch (NoSuchAlgorithmException | NoSuchPaddingException | IllegalBlockSizeException | BadPaddingException | InvalidKeyException e) {
            e.printStackTrace();
        }
        return null;
    }

    private SecretKey getSecretKey(@SuppressWarnings("SameParameterValue") String myKey) {
        byte[] decodeSecretKey = Base64.getDecoder().decode(myKey);
        return new SecretKeySpec(decodeSecretKey, 0, decodeSecretKey.length, "AES");
    }
}
