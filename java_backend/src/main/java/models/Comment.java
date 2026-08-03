package models;

import java.time.LocalDateTime;

public class Comment {
    private String title;
    private String context;
    private String date;
    private int userId;

    public Comment() {
    }

    public Comment(int userId, String title, String context) {
        this.userId = userId;
        this.title = title;
        this.context = context;
        this.date = LocalDateTime.now().toString();
    }

    public String getTitle() {
        return title;
    }

    public String getContext() {
        return context;
    }

    public String getDate() {
        return date;
    }

    public int getUserId() {
        return userId;
    }
}