package server;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonSyntaxException;
import handlers.UserController;
import handlers.AlbumController;
import handlers.GalleryController;
import database.UserDatabase;

import java.io.*;
import java.net.Socket;

public class ClientHandler implements Runnable {
    private final Socket socket;
    private final Gson gson = new GsonBuilder().serializeNulls().create();
    private final UserController userController = new UserController();
    private final AlbumController albumController = new AlbumController();
    private final GalleryController galleryController = new GalleryController();
    private final UserDatabase userDatabase = new UserDatabase();

    public ClientHandler(Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        try (
                BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                PrintWriter out = new PrintWriter(socket.getOutputStream(), true)
        ) {
            String line;
            while ((line = in.readLine()) != null) {
                Response response = handleRequest(line);
                String jsonResponse = gson.toJson(response);
                out.println(jsonResponse);
            }
        } catch (IOException e) {
            System.out.println("ارتباط با کاربر قطع شد: " + e.getMessage());
        } finally {
            try {
                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private Response handleRequest(String rawJson) {
        Request request;
        try {
            request = gson.fromJson(rawJson, Request.class);
        } catch (JsonSyntaxException e) {
            return Response.error(400, "فرمت درخواست نامعتبر است");
        }

        if (request == null || request.getRoute() == null) {
            return Response.error(400, "فیلد route الزامی است");
        }

        String route = request.getRoute();

        if (route.equals("/ping")) {
            return Response.ok("pong", null);
        }

        if (route.equals("/user/signup/")) {
            return userController.signup(request.getPayload());
        }

        if (route.equals("/user/login/")) {
            return userController.login(request.getPayload());
        }

        if (route.startsWith("/album/") || route.startsWith("/gallery/")) {
            models.User user = userDatabase.findByUsername(request.getUsername());
            if (user == null) {
                return Response.error(401, "ابتدا باید وارد شوید");
            }
            int userId = user.getId();

            if (route.equals("/album/create/")) {
                return albumController.createAlbum(userId, request.getPayload());
            }
            if (route.equals("/album/list/")) {
                return albumController.listAlbums(userId);
            }
            if (route.equals("/album/upload/")) {
                return albumController.uploadImage(userId, request.getPayload());
            }
            if (route.equals("/album/getImage/")) {
                return albumController.getImage(userId, request.getPayload());
            }
            if (route.equals("/gallery/list/")) {
                return galleryController.listAllImages(userId);
            }
        }

        return Response.error(404, "مسیر یافت نشد: " + route);
    }
}