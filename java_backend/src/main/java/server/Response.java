package server;

public class Response {
    private int statusCode;
    private String message;
    private Object payload;

    public Response(int statusCode, String message, Object payload) {
        this.statusCode = statusCode;
        this.message = message;
        this.payload = payload;
    }

    public static Response ok(String message, Object payload) {
        return new Response(200, message, payload);
    }

    public static Response error(int statusCode, String message) {
        return new Response(statusCode, message, null);
    }
}