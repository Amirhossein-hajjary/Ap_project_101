package models;

import java.time.LocalDateTime;
import java.util.ArrayList;

public class Album {
    private String name;
    private int albumId;
    private ArrayList<Image> images = new ArrayList<>();
    private LocalDateTime date;
    //----------------------------Constructors
    public Album(String name){
        this.name = name;
        this.date = LocalDateTime.now();
    }
    public void addImage(Image image){
        images.add(image);
    }
    public ArrayList<Image> getImages() {
        return images;
    }
}