package models;

public class Admin {
    private String userName;
    private String passWord;
    private int adminId;
    //--------------------------constructor
    public Admin(String userName, String passWord, int adminId) {
        this.userName = userName;
        this.passWord = passWord;
        this.adminId = adminId;
    }
    //---------------------------getters and setters
    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassWord() {
        return passWord;
    }

    public void setPassWord(String passWord) {
        this.passWord = passWord;
    }

    public int getAdminId() {
        return adminId;
    }

    public void setAdminId(int adminId) {
        this.adminId = adminId;
    }
    //------------------------------admin methods
    public int albumCount(User user){
        int count = user.getAlbums().size();
        return count;
    }
    public int imagesCount(User user){
        int count = user.getAlbums().getFirst().getImages().size();
        return count;
    }
    public void banUser(User user){
        user.setBanned(true);
    }
}