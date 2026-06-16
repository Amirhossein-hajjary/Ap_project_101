package models;
import java.time.LocalDateTime;
import java.util.ArrayList;

public class Image {
    //-------------------------------fields
    private String name;
    private double size;
    private LocalDateTime date;
    private String location;
    private String saveAddress;
    private String caption;
    private ArrayList<String> objects = new ArrayList<>();
    private ArrayList<String> tags = new ArrayList<>();
    private ArrayList<Album> albums = new ArrayList<>();
    private boolean liked = false;
    private ArrayList<Comment> comments = new ArrayList<>();
    private boolean commentable = true;
    //-------------------------------Constructors
    public Image(String name, String caption, ArrayList<String> tags, ArrayList<Album> albums){
        this.name = name;
        this.caption = caption;
        this.tags.addAll(tags);
        this.albums.addAll(albums);
        this.date = LocalDateTime.now();
    }
    public Image(String name, String caption, ArrayList<String> tags, ArrayList<Album> albums, ArrayList<String> objects){
        this.name = name;
        this.caption = caption;
        this.tags.addAll(tags);
        this.albums.addAll(albums);
        this.date = LocalDateTime.now();
        this.objects.addAll(objects);
    }
    //---------------------------------------Setters
    public void commentable(boolean stat){
        commentable = stat;
    }
    public void favorite(boolean stat){
        liked = stat;
    }
    //---------------------------------------Getters
    public boolean isLiked(){
        return liked;
    }
    public boolean isCommentable(){
        return commentable;
    }
    public ArrayList<Comment> getComments(){
        return comments;
    }
}