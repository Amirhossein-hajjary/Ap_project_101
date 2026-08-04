package models;

import java.time.LocalDateTime;
import java.util.ArrayList;

public class Album {
    private int id;
    private String name;
    private int ownerId;
    private ArrayList<Integer> imageIds = new ArrayList<>();
    private String date;

    public Album() {
    }

    public Album(String name) {
        this.name = name;
        this.date = LocalDateTime.now().toString();
    }

    public void addImageId(int imageId) {
        if (!imageIds.contains(imageId)) imageIds.add(imageId);
    }

    public void removeImageId(int imageId) {
        imageIds.remove(Integer.valueOf(imageId));
    }

    public ArrayList<Integer> getImageIds() {
        return imageIds;
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

    public void setName(String name) {
        this.name = name;
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