package models;

import java.util.*;
import java.util.regex.Pattern;

public class User {
    private int id;
    private String userName;
    private String password;
    private String email;
    private ArrayList<Album> albums = new ArrayList<>();
    private boolean banned = false;

    public User() {
    }

    public User(String userName, String password, String email) throws InvalidUserNameException, InvalidPasswordException {
        if (!isCorrectUserName(userName)) throw new InvalidUserNameException();
        this.userName = userName;
        if (!isCorrectPassword(password)) throw new InvalidPasswordException();
        this.password = password;
        this.email = email;

        Album defaultAlbum = new Album("Photos");
        this.albums.add(defaultAlbum);
    }

    private boolean isCorrectPassword(String password) {
        final Pattern HAS_UPPERCASE = Pattern.compile(".*[A-Z].*");
        final Pattern HAS_LOWERCASE = Pattern.compile(".*[a-z].*");
        final Pattern HAS_DIGIT = Pattern.compile(".*[0-9].*");

        if (password == null || password.length() < 8 || password.contains(this.userName)) return false;

        return HAS_UPPERCASE.matcher(password).matches()
                && HAS_LOWERCASE.matcher(password).matches()
                && HAS_DIGIT.matcher(password).matches();
    }

    private boolean isCorrectUserName(String userName) {
        return userName != null && userName.length() >= 3;
    }

    public void addImageToDefaultAlbum(Image image) {
        albums.get(0).addImage(image);
    }

    public boolean isBanned() {
        return banned;
    }

    public void setBanned(boolean banned) {
        this.banned = banned;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String newName) {
        this.userName = newName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String newPassword) {
        this.password = newPassword;
    }

    public String getEmail() {
        return email;
    }

    public ArrayList<Album> getAlbums() {
        return albums;
    }

    public void addAlbum(Album album) {
        this.albums.add(album);
    }
}