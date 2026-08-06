package admin;

import database.UserDatabase;
import models.User;

import java.util.ArrayList;
import java.util.Scanner;


public class AdminPanel {
    private final UserDatabase userDatabase = new UserDatabase();
    private final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        new AdminPanel().run();
    }

    public void run() {
        System.out.println("========================================");
        System.out.println("   پنل مدیریت کاربران (Admin Panel)");
        System.out.println("========================================");

        boolean running = true;
        while (running) {
            printMenu();
            String choice = scanner.nextLine().trim();

            switch (choice) {
                case "1":
                    listUsers();
                    break;
                case "2":
                    banUser();
                    break;
                case "3":
                    unbanUser();
                    break;
                case "4":
                    viewUserDetails();
                    break;
                case "0":
                    running = false;
                    System.out.println("خروج از پنل ادمین.");
                    break;
                default:
                    System.out.println("گزینه‌ی نامعتبر. دوباره تلاش کنید.\n");
            }
        }
    }

    private void printMenu() {
        System.out.println("\n1) نمایش لیست کاربران");
        System.out.println("2) بن کردن یک کاربر");
        System.out.println("3) رفع بن یک کاربر");
        System.out.println("4) مشاهده‌ی جزئیات یک کاربر (تعداد آلبوم/عکس)");
        System.out.println("0) خروج");
        System.out.print("انتخاب شما: ");
    }

    private void listUsers() {
        ArrayList<User> users = userDatabase.getAllUsers();
        if (users.isEmpty()) {
            System.out.println("هیچ کاربری در سیستم ثبت نشده است.");
            return;
        }

        System.out.printf("%-5s %-20s %-25s %-10s %-10s %-8s%n", "ID", "Username", "Email", "Albums", "Images", "Banned");
        System.out.println("-".repeat(85));
        for (User u : users) {
            System.out.printf("%-5d %-20s %-25s %-10d %-10d %-8s%n",
                    u.getId(),
                    u.getUserName(),
                    u.getEmail() == null ? "-" : u.getEmail(),
                    u.getAlbums().size(),
                    u.getImages().size(),
                    u.isBanned() ? "بله" : "خیر");
        }
    }

    private User promptForUser() {
        System.out.print("شناسه‌ی عددی (ID) یا نام کاربری را وارد کنید: ");
        String input = scanner.nextLine().trim();

        User user = null;
        try {
            int id = Integer.parseInt(input);
            user = userDatabase.findById(id);
        } catch (NumberFormatException e) {
            user = userDatabase.findByUsername(input);
        }

        if (user == null) {
            System.out.println("کاربری با این مشخصات پیدا نشد.");
        }
        return user;
    }

    private void banUser() {
        User user = promptForUser();
        if (user == null) return;

        if (user.isBanned()) {
            System.out.println("این کاربر از قبل بن شده است.");
            return;
        }

        boolean success = userDatabase.setUserBanned(user.getId(), true);
        System.out.println(success ? "کاربر '" + user.getUserName() + "' با موفقیت بن شد." : "خطا در بن کردن کاربر.");
    }

    private void unbanUser() {
        User user = promptForUser();
        if (user == null) return;

        if (!user.isBanned()) {
            System.out.println("این کاربر بن نبود.");
            return;
        }

        boolean success = userDatabase.setUserBanned(user.getId(), false);
        System.out.println(success ? "بن کاربر '" + user.getUserName() + "' برداشته شد." : "خطا در رفع بن کاربر.");
    }

    private void viewUserDetails() {
        User user = promptForUser();
        if (user == null) return;

        System.out.println("\n--- جزئیات کاربر ---");
        System.out.println("ID: " + user.getId());
        System.out.println("Username: " + user.getUserName());
        System.out.println("Email: " + (user.getEmail() == null ? "-" : user.getEmail()));
        System.out.println("Banned: " + (user.isBanned() ? "بله" : "خیر"));
        System.out.println("تعداد آلبوم‌ها: " + user.getAlbums().size());
        System.out.println("تعداد عکس‌ها: " + user.getImages().size());
    }
}