package handlers;

import com.google.gson.JsonObject;
import database.UserDatabase;
import models.InvalidPasswordException;
import models.InvalidUserNameException;
import models.User;
import server.Response;

public class UserController {
    private final UserDatabase userDatabase = new UserDatabase();

    public Response signup(JsonObject payload) {
        if (payload == null || !payload.has("userName") || !payload.has("password")) {
            return Response.error(400, "UserName and Password is required");
        }

        String userName = payload.get("userName").getAsString();
        String password = payload.get("password").getAsString();
        String email = payload.has("email") ? payload.get("email").getAsString() : "";

        if (userDatabase.usernameExists(userName)) {
            return Response.error(401, "This username ahs already been taken");
        }

        try {
            User newUser = new User(userName, password, email);
            userDatabase.registerUser(newUser);
            return Response.ok("Successfuly signed up", newUser);
        } catch (InvalidUserNameException e) {
            return Response.error(400, "Invalid username format");
        } catch (InvalidPasswordException e) {
            return Response.error(400, "Invalid password");
        }
    }

    public Response login(JsonObject payload) {
        if (payload == null || !payload.has("userName") || !payload.has("password")) {
            return Response.error(400, "UserName and Password is required");
        }

        String userName = payload.get("userName").getAsString();
        String password = payload.get("password").getAsString();

        User user = userDatabase.findByUsername(userName);

        if (user == null) {
            return Response.error(401, "Username or password is incorrect");
        }

        if (!user.getPassword().equals(password)) {
            return Response.error(401, "Username or password is incorrect");
        }

        if (user.isBanned()) {
            return Response.error(403, "You can no longer access to this account");
        }

        return Response.ok("Welcome", user);
    }
}