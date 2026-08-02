package models;
import java.util.*;
import java.util.regex.Pattern;

public class User {
    private String userName;
    private String password;
    private ArrayList<Album> albums = new ArrayList<>();
    private boolean banned = false;
    //----------------------initialization block
    {
        Album defualtAlbum = new Album("Photos");
        albums.add(defualtAlbum);
    }

    public User(String userName, String password) throws InvalidUserNameException, InvalidPasswordException {
        if (!isCorrectUserName(userName)) throw new InvalidUserNameException();
        this.userName = userName;
        if (!isCorrectPassword(password)) throw new InvalidPasswordException();
        this.password = password;
    }

    private boolean isCorrectPassword(String password) {
        final Pattern HAS_UPPERCASE  = Pattern.compile(".*[A-Z].*");
        final Pattern HAS_LOWERCASE  = Pattern.compile(".*[a-z].*");
        final Pattern HAS_DIGIT      = Pattern.compile(".*[0-9].*");

        if ( password == (null) || password.length()<8 || password.contains(this.userName) )return false;

        return HAS_UPPERCASE.matcher(password).matches()
                && HAS_LOWERCASE.matcher(password).matches()
                && HAS_DIGIT.matcher(password).matches();
    }
    private boolean isCorrectUserName(String userName){
        //Checking database for existing username
        return true;
    }

    public void addImageToDefaultAlbum(Image image){
        albums.getFirst().addImage(image);
    }
    public boolean isBanned(){
        return banned;
    }
    public void setUserName(String newName){
        this.userName = newName;
    }
    public void setPassword(String newPassword){
        this.password = newPassword;
    }
    public ArrayList<Album> getAlbums() {
        return albums;
    }


    public void setBanned(boolean banned) {
        this.banned = banned;
    }
    public void login() {//to Do}
    }

    public String getUserName() {
        return userName;
    }

    public String getPassword() {
        return password;
    }

    public void addAlbum(Album album){
        this.albums.add(album);
    }
}
