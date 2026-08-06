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

    public Response changeUsername(int userId, JsonObject payload) {
        if (payload == null || !payload.has("newUsername")) {
            return Response.error(400, "فیلد newUsername الزامی است");
        }
        String newUsername = payload.get("newUsername").getAsString();
        int result = userDatabase.changeUsername(userId, newUsername);

        switch (result) {
            case 0: return Response.ok("نام کاربری تغییر کرد", null);
            case 1: return Response.error(404, "کاربر یافت نشد");
            case 2: return Response.error(401, "این نام کاربری قبلاً استفاده شده است");
            case 3: return Response.error(400, "فرمت نام کاربری نامعتبر است");
            default: return Response.error(500, "خطای ناشناخته");
        }
    }

    public Response changePassword(int userId, JsonObject payload) {
        if (payload == null || !payload.has("oldPassword") || !payload.has("newPassword")) {
            return Response.error(400, "فیلدهای oldPassword و newPassword الزامی است");
        }
        String oldPassword = payload.get("oldPassword").getAsString();
        String newPassword = payload.get("newPassword").getAsString();

        int result = userDatabase.changePassword(userId, oldPassword, newPassword);
        switch (result) {
            case 0:
                return Response.ok("رمز عبور با موفقیت تغییر کرد", null);
            case 2:
                return Response.error(401, "رمز عبور فعلی اشتباه است");
            case 3:
                return Response.error(400, "رمز عبور جدید نامعتبر است (حداقل ۸ کاراکتر، شامل حروف بزرگ، کوچک و عدد، بدون نام کاربری)");
            default:
                return Response.error(404, "کاربر یافت نشد");
        }
    }

    public Response deleteAccount(int userId) {
        boolean success = userDatabase.deleteAccount(userId);
        if (!success) return Response.error(404, "کاربر یافت نشد");
        return Response.ok("حساب کاربری حذف شد", null);
    }
}