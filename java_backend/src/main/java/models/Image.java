package models;

import java.time.LocalDateTime;
import java.util.ArrayList;

public class Image {
    private int id;
    private String name;
    private double size;
    private String date;
    private String location;
    private String saveAddress;
    private String caption;
    private int ownerId;
    private ArrayList<Integer> albumIds = new ArrayList<>();
    private ArrayList<String> tags = new ArrayList<>();
    private boolean liked = false;
    private ArrayList<Comment> comments = new ArrayList<>();
    private boolean commentable = true;

    public Image() {
    }

    public Image(String name, String caption, ArrayList<String> tags) {
        this.name = name;
        this.caption = caption;
        if (tags != null) this.tags.addAll(tags);
        this.date = LocalDateTime.now().toString();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public String getCaption() {
        return caption;
    }

    public String getSaveAddress() {
        return saveAddress;
    }

    public void setSaveAddress(String saveAddress) {
        this.saveAddress = saveAddress;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public ArrayList<Integer> getAlbumIds() {
        return albumIds;
    }

    public void addAlbumId(int albumId) {
        if (!albumIds.contains(albumId)) albumIds.add(albumId);
    }

    public void removeAlbumId(int albumId) {
        albumIds.remove(Integer.valueOf(albumId));
    }

    public ArrayList<String> getTags() {
        return tags;
    }

    public boolean isLiked() {
        return liked;
    }

    public void setLiked(boolean liked) {
        this.liked = liked;
    }

    public ArrayList<Comment> getComments() {
        return comments;
    }

    public boolean isCommentable() {
        return commentable;
    }

    public void setCommentable(boolean commentable) {
        this.commentable = commentable;
    }

    public String getDate() {
        return date;
    }
}