package server;

import com.google.gson.JsonObject;

public class Request {
    private String method;
    private String username;
    private String route;
    private JsonObject payload;

    public Request() {
    }

    public String getMethod() {
        return method;
    }

    public String getUsername() {
        return username;
    }

    public String getRoute() {
        return route;
    }

    public JsonObject getPayload() {
        return payload;
    }
}