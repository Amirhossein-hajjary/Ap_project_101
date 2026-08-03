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

    public synchronized ArrayList<User> getAllUsers() {
        return load().users;
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
            newUser.getAlbums().get(0).setId(data.nextAlbumId);
            newUser.getAlbums().get(0).setOwnerId(newUser.getId());
            data.nextAlbumId++;
        }

        data.users.add(newUser);
        save(data);
        return newUser;
    }

    public synchronized Album createAlbum(int ownerId, String albumName) {
        Wrapper data = load();
        User owner = null;
        for (User u : data.users) {
            if (u.getId() == ownerId) owner = u;
        }
        if (owner == null) return null;

        Album album = new Album(albumName);
        album.setId(data.nextAlbumId);
        data.nextAlbumId++;
        album.setOwnerId(ownerId);

        owner.addAlbum(album);
        save(data);
        return album;
    }

    public synchronized Image addImageToAlbum(int ownerId, int albumId, Image image) {
        Wrapper data = load();
        User owner = null;
        for (User u : data.users) {
            if (u.getId() == ownerId) owner = u;
        }
        if (owner == null) return null;

        Album targetAlbum = null;
        for (Album a : owner.getAlbums()) {
            if (a.getId() == albumId) targetAlbum = a;
        }
        if (targetAlbum == null) return null;

        image.setId(data.nextImageId);
        data.nextImageId++;
        image.setOwnerId(ownerId);
        image.setAlbumId(albumId);

        targetAlbum.addImage(image);
        save(data);
        return image;
    }

    public synchronized boolean updateUser(User updatedUser) {
        Wrapper data = load();
        for (int i = 0; i < data.users.size(); i++) {
            if (data.users.get(i).getId() == updatedUser.getId()) {
                data.users.set(i, updatedUser);
                save(data);
                return true;
            }
        }
        return false;
    }

    public synchronized boolean setImageSaveAddress(int ownerId, int imageId, String path) {
        Wrapper data = load();
        for (User u : data.users) {
            if (u.getId() == ownerId) {
                for (Album a : u.getAlbums()) {
                    for (Image img : a.getImages()) {
                        if (img.getId() == imageId) {
                            img.setSaveAddress(path);
                            save(data);
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    public synchronized Image findImageById(int ownerId, int imageId) {
        Wrapper data = load();
        for (User u : data.users) {
            if (u.getId() == ownerId) {
                for (Album a : u.getAlbums()) {
                    for (Image img : a.getImages()) {
                        if (img.getId() == imageId) {
                            return img;
                        }
                    }
                }
            }
        }
        return null;
    }
}