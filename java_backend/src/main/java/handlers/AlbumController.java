package handlers;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import database.ImageStorage;
import database.UserDatabase;
import models.Album;
import models.Image;
import models.User;
import server.Response;

import java.io.IOException;
import java.util.ArrayList;

public class AlbumController {
    private final UserDatabase userDatabase = new UserDatabase();
    private final ImageStorage imageStorage = new ImageStorage();

    public Response createAlbum(int userId, JsonObject payload) {
        if (payload == null || !payload.has("name")) {
            return Response.error(400, "فیلد name الزامی است");
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

        ArrayList<Integer> albumIds = new ArrayList<>();
        if (payload.has("albumIds") && payload.get("albumIds").isJsonArray()) {
            JsonArray arr = payload.getAsJsonArray("albumIds");
            for (JsonElement el : arr) {
                albumIds.add(el.getAsInt());
            }
        }
        if (albumIds.isEmpty()) {
            albumIds.add(user.getAlbums().get(0).getId());
        }

        String caption = payload.has("caption") ? payload.get("caption").getAsString() : "";
        String name = payload.has("name") ? payload.get("name").getAsString() : "untitled";

        ArrayList<String> tags = new ArrayList<>();
        if (payload.has("tags") && payload.get("tags").isJsonArray()) {
            for (JsonElement el : payload.getAsJsonArray("tags")) {
                tags.add(el.getAsString());
            }
        }

        Image image = new Image(name, caption, tags);
        Image savedImage = userDatabase.uploadImage(userId, image, albumIds);

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

    public Response addImageToAlbum(int userId, JsonObject payload) {
        if (payload == null || !payload.has("imageId") || !payload.has("albumId")) {
            return Response.error(400, "فیلدهای imageId و albumId الزامی است");
        }
        int imageId = payload.get("imageId").getAsInt();
        int albumId = payload.get("albumId").getAsInt();

        boolean success = userDatabase.addImageToAlbum(userId, imageId, albumId);
        if (!success) return Response.error(404, "عکس یا آلبوم یافت نشد");
        return Response.ok("عکس به آلبوم اضافه شد", null);
    }

    public Response removeImageFromAlbum(int userId, JsonObject payload) {
        if (payload == null || !payload.has("imageId") || !payload.has("albumId")) {
            return Response.error(400, "فیلدهای imageId و albumId الزامی است");
        }
        int imageId = payload.get("imageId").getAsInt();
        int albumId = payload.get("albumId").getAsInt();

        boolean success = userDatabase.removeImageFromAlbum(userId, imageId, albumId);
        if (!success) return Response.error(404, "عکس یا آلبوم یافت نشد");
        return Response.ok("عکس از آلبوم حذف شد", null);
    }

    public Response deleteAlbum(int userId, JsonObject payload) {
        if (payload == null || !payload.has("albumId")) {
            return Response.error(400, "فیلد albumId الزامی است");
        }
        int albumId = payload.get("albumId").getAsInt();
        boolean success = userDatabase.deleteAlbum(userId, albumId);
        if (!success) return Response.error(404, "آلبوم یافت نشد");
        return Response.ok("آلبوم حذف شد", null);
    }

    public Response renameAlbum(int userId, JsonObject payload) {
        if (payload == null || !payload.has("albumId") || !payload.has("newName")) {
            return Response.error(400, "فیلدهای albumId و newName الزامی است");
        }
        int albumId = payload.get("albumId").getAsInt();
        String newName = payload.get("newName").getAsString();
        boolean success = userDatabase.renameAlbum(userId, albumId, newName);
        if (!success) return Response.error(404, "آلبوم یافت نشد");
        return Response.ok("نام آلبوم تغییر کرد", null);
    }

    public Response deleteImage(int userId, JsonObject payload) {
        if (payload == null || !payload.has("imageId")) {
            return Response.error(400, "فیلد imageId الزامی است");
        }
        int imageId = payload.get("imageId").getAsInt();
        boolean success = userDatabase.deleteImage(userId, imageId);
        if (!success) return Response.error(404, "عکس یافت نشد");
        return Response.ok("عکس حذف شد", null);
    }

    public Response setLiked(int userId, JsonObject payload) {
        if (payload == null || !payload.has("imageId") || !payload.has("liked")) {
            return Response.error(400, "فیلدهای imageId و liked الزامی است");
        }
        int imageId = payload.get("imageId").getAsInt();
        boolean liked = payload.get("liked").getAsBoolean();
        boolean success = userDatabase.setImageLiked(userId, imageId, liked);
        if (!success) return Response.error(404, "عکس یافت نشد");
        return Response.ok("وضعیت پسندیدن تغییر کرد", null);
    }
}