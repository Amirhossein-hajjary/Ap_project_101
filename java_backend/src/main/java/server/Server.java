package server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    private static final int PORT = 5000;

    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("سرور روی پورت " + PORT + " در حال اجراست...");

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("کاربر جدید متصل شد: " + clientSocket.getInetAddress());

                Thread thread = new Thread(new ClientHandler(clientSocket));
                thread.start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}