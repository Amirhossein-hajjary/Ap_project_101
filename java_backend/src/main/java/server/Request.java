package server;

import com.google.gson.JsonObject;

public class Request {
    private String method;
    private String username;
    private String route;
    private String requestId;
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

    public String getRequestId() {
        return requestId;
    }

    public JsonObject getPayload() {
        return payload;
    }
}