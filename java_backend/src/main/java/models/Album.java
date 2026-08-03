package models;

import java.time.LocalDateTime;
import java.util.ArrayList;

public class Album {
    private int id;
    private String name;
    private int ownerId;
    private ArrayList<Image> images = new ArrayList<>();
    private String date;

    public Album() {
    }

    public Album(String name) {
        this.name = name;
        this.date = LocalDateTime.now().toString();
    }

    public void addImage(Image image) {
        images.add(image);
    }

    public ArrayList<Image> getImages() {
        return images;
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

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public String getDate() {
        return date;
    }
}