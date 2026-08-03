package handlers;

import database.UserDatabase;
import models.Album;
import models.Image;
import models.User;
import server.Response;

import java.util.ArrayList;

public class GalleryController {
    private final UserDatabase userDatabase = new UserDatabase();

    public Response listAllImages(int userId) {
        User user = userDatabase.findById(userId);
        if (user == null) {
            return Response.error(404, "کاربر یافت نشد");
        }

        ArrayList<Image> allImages = new ArrayList<>();
        for (Album album : user.getAlbums()) {
            allImages.addAll(album.getImages());
        }

        return Response.ok("لیست کل عکس‌ها", allImages);
    }
}