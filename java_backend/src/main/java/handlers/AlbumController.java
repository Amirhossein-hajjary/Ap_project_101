package handlers;

import com.google.gson.JsonObject;
import database.ImageStorage;
import database.UserDatabase;
import models.Album;
import models.Image;
import models.User;
import server.Response;
import database.UserDatabase;
import database.ImageStorage;

import java.io.IOException;
import java.util.ArrayList;

public class AlbumController {
    private final UserDatabase userDatabase = new UserDatabase();
    private final ImageStorage imageStorage = new ImageStorage();

    public Response createAlbum(int userId, JsonObject payload) {
        if (payload == null || !payload.has("name")) {
            return Response.error(400, "Name is requierd");
        }

        String name = payload.get("name").getAsString();
        Album album = userDatabase.createAlbum(userId, name);

        if (album == null) {
            return Response.error(404, "کاربر یافت نشد");
        }

        return Response.ok("آلبوم با موفقیت ساخته شد", album);
    }

    public Response listAlbums(int userId) {
        User user = userDatabase.findById(userId);
        if (user == null) {
            return Response.error(404, "کاربر یافت نشد");
        }
        return Response.ok("لیست آلبوم‌ها", user.getAlbums());
    }

    public Response uploadImage(int userId, JsonObject payload) {
        if (payload == null || !payload.has("base64Data")) {
            return Response.error(400, "فیلد base64Data الزامی است");
        }

        User user = userDatabase.findById(userId);
        if (user == null) {
            return Response.error(404, "کاربر یافت نشد");
        }

        int albumId;
        if (payload.has("albumId") && !payload.get("albumId").isJsonNull()) {
            albumId = payload.get("albumId").getAsInt();
        } else {
            albumId = user.getAlbums().get(0).getId();
        }

        String caption = payload.has("caption") ? payload.get("caption").getAsString() : "";
        String name = payload.has("name") ? payload.get("name").getAsString() : "untitled";

        Image image = new Image(name, caption, new ArrayList<>());
        Image savedImage = userDatabase.addImageToAlbum(userId, albumId, image);

        if (savedImage == null) {
            return Response.error(404, "آلبوم مقصد یافت نشد");
        }

        try {
            String base64Data = payload.get("base64Data").getAsString();
            String path = imageStorage.saveImage(savedImage.getId(), base64Data);
            userDatabase.setImageSaveAddress(userId, savedImage.getId(), path);
            savedImage.setSaveAddress(path);
        } catch (IOException e) {
            return Response.error(500, "خطا در ذخیره‌سازی فایل تصویر");
        }

        return Response.ok("عکس با موفقیت آپلود شد", savedImage);
    }

    public Response getImage(int userId, JsonObject payload) {
        if (payload == null || !payload.has("imageId")) {
            return Response.error(400, "فیلد imageId الزامی است");
        }

        int imageId = payload.get("imageId").getAsInt();
        Image image = userDatabase.findImageById(userId, imageId);

        if (image == null) {
            return Response.error(404, "عکس یافت نشد");
        }

        if (image.getSaveAddress() == null) {
            return Response.error(500, "فایل این عکس روی سرور موجود نیست");
        }

        try {
            String base64 = imageStorage.loadImageAsBase64(image.getSaveAddress());
            JsonObject result = new JsonObject();
            result.addProperty("imageId", image.getId());
            result.addProperty("caption", image.getCaption());
            result.addProperty("base64Data", base64);
            return Response.ok("عکس با موفقیت دریافت شد", result);
        } catch (IOException e) {
            return Response.error(500, "خطا در خواندن فایل تصویر");
        }
    }
}