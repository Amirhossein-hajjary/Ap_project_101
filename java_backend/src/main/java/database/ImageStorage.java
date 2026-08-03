package database;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Base64;

public class ImageStorage {
    private static final String IMAGES_FOLDER = "images/";

    public synchronized String saveImage(int imageId, String base64Data) throws IOException {
        byte[] bytes = Base64.getDecoder().decode(base64Data);
        String fileName = imageId + ".jpg";
        String fullPath = IMAGES_FOLDER + fileName;

        try (FileOutputStream fos = new FileOutputStream(fullPath)) {
            fos.write(bytes);
        }

        return fullPath;
    }

    public synchronized String loadImageAsBase64(String saveAddress) throws IOException {
        byte[] bytes = java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(saveAddress));
        return Base64.getEncoder().encodeToString(bytes);
    }
}