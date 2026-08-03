package models;
import java.time.LocalDateTime;
public class Comment {
    private String title;
    private String context;
    private LocalDateTime date;
    private User user;
    public Comment(User user, String title, String context){
        this.user = user;
        this.title = title;
        this.context = context;
        this.date = LocalDateTime.now();
    }
    //----------------------------------Getters

    public String getTitle() {
        return title;
    }

    public String getContext() {
        return context;
    }
}