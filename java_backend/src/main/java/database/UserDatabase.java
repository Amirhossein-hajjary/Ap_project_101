package database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import models.Album;
import models.Image;
import models.User;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class UserDatabase {
    private static final String FILE_PATH = "Database/UsersDatabase.json";
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    private static class Wrapper {
        ArrayList<User> users = new ArrayList<>();
        int nextUserId = 1;
        int nextAlbumId = 1;
        int nextImageId = 1;
    }

    private synchronized Wrapper load() {
        try (FileReader reader = new FileReader(FILE_PATH)) {
            Wrapper data = gson.fromJson(reader, Wrapper.class);
            if (data == null) data = new Wrapper();
            return data;
        } catch (IOException e) {
            return new Wrapper();
        }
    }

    private synchronized void save(Wrapper data) {
        try (FileWriter writer = new FileWriter(FILE_PATH)) {
            gson.toJson(data, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public synchronized User findByUsername(String username) {
        for (User u : load().users) {
            if (u.getUserName().equals(username)) return u;
        }
        return null;
    }

    public synchronized User findById(int id) {
        for (User u : load().users) {
            if (u.getId() == id) return u;
        }
        return null;
    }

    public synchronized boolean usernameExists(String username) {
        return findByUsername(username) != null;
    }

    public synchronized User registerUser(User newUser) {
        Wrapper data = load();
        newUser.setId(data.nextUserId);
        data.nextUserId++;

        if (!newUser.getAlbums().isEmpty()) {
            Album defaultAlbum = newUser.getAlbums().get(0);
            defaultAlbum.setId(data.nextAlbumId);
            defaultAlbum.setOwnerId(newUser.getId());
            data.nextAlbumId++;
        }

        data.users.add(newUser);
        save(data);
        return newUser;
    }

    public synchronized Album createAlbum(int ownerId, String albumName) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return null;

        Album album = new Album(albumName);
        album.setId(data.nextAlbumId);
        data.nextAlbumId++;
        album.setOwnerId(ownerId);

        owner.addAlbum(album);
        save(data);
        return album;
    }

    public synchronized Image uploadImage(int ownerId, Image image, ArrayList<Integer> albumIds) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return null;

        image.setId(data.nextImageId);
        data.nextImageId++;
        image.setOwnerId(ownerId);

        for (int albumId : albumIds) {
            Album album = findAlbumInUser(owner, albumId);
            if (album != null) {
                image.addAlbumId(albumId);
                album.addImageId(image.getId());
            }
        }

        owner.addImage(image);
        save(data);
        return image;
    }

    public synchronized boolean setImageSaveAddress(int ownerId, int imageId, String path) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Image image = findImageInUser(owner, imageId);
        if (image == null) return false;

        image.setSaveAddress(path);
        save(data);
        return true;
    }

    public synchronized Image findImageById(int ownerId, int imageId) {
        User owner = findById(ownerId);
        if (owner == null) return null;
        return findImageInUser(owner, imageId);
    }

    public synchronized boolean addImageToAlbum(int ownerId, int imageId, int albumId) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Image image = findImageInUser(owner, imageId);
        Album album = findAlbumInUser(owner, albumId);
        if (image == null || album == null) return false;

        image.addAlbumId(albumId);
        album.addImageId(imageId);
        save(data);
        return true;
    }

    public synchronized boolean removeImageFromAlbum(int ownerId, int imageId, int albumId) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Image image = findImageInUser(owner, imageId);
        Album album = findAlbumInUser(owner, albumId);
        if (image == null || album == null) return false;

        image.removeAlbumId(albumId);
        album.removeImageId(imageId);
        save(data);
        return true;
    }

    private User findUserInWrapper(Wrapper data, int userId) {
        for (User u : data.users) {
            if (u.getId() == userId) return u;
        }
        return null;
    }

    private Album findAlbumInUser(User user, int albumId) {
        for (Album a : user.getAlbums()) {
            if (a.getId() == albumId) return a;
        }
        return null;
    }

    private Image findImageInUser(User user, int imageId) {
        for (Image img : user.getImages()) {
            if (img.getId() == imageId) return img;
        }
        return null;
    }
}