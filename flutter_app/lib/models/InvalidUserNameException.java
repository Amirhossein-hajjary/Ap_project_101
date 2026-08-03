package models;

public class InvalidUserNameException extends Exception{
    public InvalidUserNameException() {
        super("Invalid username provided");
    }
    public InvalidUserNameException(String message) {
        super(message);
    }
}