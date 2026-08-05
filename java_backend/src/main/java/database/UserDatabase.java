package database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import models.Album;
import models.Comment;
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

    public synchronized ArrayList<User> getAllUsers() {
        return load().users;
    }

    public synchronized boolean setUserBanned(int userId, boolean banned) {
        Wrapper data = load();
        User user = findUserInWrapper(data, userId);
        if (user == null) return false;

        user.setBanned(banned);
        save(data);
        return true;
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

    public synchronized boolean deleteAlbum(int ownerId, int albumId) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Album album = findAlbumInUser(owner, albumId);
        if (album == null) return false;

        for (int imageId : new ArrayList<>(album.getImageIds())) {
            Image image = findImageInUser(owner, imageId);
            if (image != null) image.removeAlbumId(albumId);
        }

        owner.getAlbums().remove(album);
        save(data);
        return true;
    }

    public synchronized boolean renameAlbum(int ownerId, int albumId, String newName) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Album album = findAlbumInUser(owner, albumId);
        if (album == null) return false;

        album.setName(newName);
        save(data);
        return true;
    }

    public synchronized boolean deleteImage(int ownerId, int imageId) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Image image = findImageInUser(owner, imageId);
        if (image == null) return false;

        for (int albumId : new ArrayList<>(image.getAlbumIds())) {
            Album album = findAlbumInUser(owner, albumId);
            if (album != null) album.removeImageId(imageId);
        }

        owner.getImages().remove(image);
        save(data);
        return true;
    }

    public synchronized boolean setImageLiked(int ownerId, int imageId, boolean liked) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Image image = findImageInUser(owner, imageId);
        if (image == null) return false;

        image.setLiked(liked);
        save(data);
        return true;
    }

    public synchronized Image addComment(int ownerId, int imageId, int commenterId, String title, String context) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return null;

        Image image = findImageInUser(owner, imageId);
        if (image == null) return null;
        if (!image.isCommentable()) return null;

        Comment comment = new Comment(commenterId, title, context);
        image.getComments().add(comment);
        save(data);
        return image;
    }

    public synchronized boolean setImageCommentable(int ownerId, int imageId, boolean commentable) {
        Wrapper data = load();
        User owner = findUserInWrapper(data, ownerId);
        if (owner == null) return false;

        Image image = findImageInUser(owner, imageId);
        if (image == null) return false;

        image.setCommentable(commentable);
        save(data);
        return true;
    }

    public synchronized int changePassword(int userId, String oldPassword, String newPassword) {
        Wrapper data = load();
        User user = findUserInWrapper(data, userId);
        if (user == null) return 1;

        if (!user.getPassword().equals(oldPassword)) return 2;
        if (!isValidPassword(newPassword, user.getUserName())) return 3;

        user.setPassword(newPassword);
        save(data);
        return 0;
    }

    private boolean isValidPassword(String password, String userName) {
        if (password == null || password.length() < 8 || password.contains(userName)) return false;
        boolean hasUpper = password.chars().anyMatch(Character::isUpperCase);
        boolean hasLower = password.chars().anyMatch(Character::isLowerCase);
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        return hasUpper && hasLower && hasDigit;
    }

    public synchronized boolean deleteAccount(int userId) {
        Wrapper data = load();
        User user = findUserInWrapper(data, userId);
        if (user == null) return false;

        data.users.remove(user);
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