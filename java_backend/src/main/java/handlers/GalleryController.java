package handlers;

import database.UserDatabase;
import models.User;
import server.Response;

public class GalleryController {
    private final UserDatabase userDatabase = new UserDatabase();

    public Response listAllImages(int userId) {
        User user = userDatabase.findById(userId);
        if (user == null) {
            return Response.error(404, "کاربر یافت نشد");
        }
        return Response.ok("لیست کل عکس‌ها", user.getImages());
    }
}