package com.example.hatokuse;

import java.io.*;
import java.net.*;
import java.util.Scanner;

public class Client {
    private static final String LEADER_HOST = "127.0.0.1";
    private static final int LEADER_PORT = 8080; // Leader'ın Client portu

    public static void main(String[] args) {
        // Eğer komut satırından argüman geldiyse (Otomasyon Modu)
        if (args.length > 0) {
            handleSingleCommand(args);
        } else {
            // Argüman yoksa (İnteraktif Mod)
            runInteractiveMode();
        }
    }

    // OTOMASYON İÇİN: Tek komut çalıştır ve çık
    private static void handleSingleCommand(String[] args) {
        // Gelen argümanları birleştir (Örn: "SET", "1", "Mesaj" -> "SET 1 Mesaj")
        String command = String.join(" ", args);
        sendCommand(command);
    }

    // KULLANICI İÇİN: Menü aç ve bekle
    private static void runInteractiveMode() {
        System.out.println("HaToKuSe İstemci Başlatıldı");
        System.out.println("Komutlar:");
        System.out.println("  SET <message_id> <message> - Mesaj kaydet");
        System.out.println("  GET <message_id> - Mesaj getir");
        System.out.println("  EXIT - Çıkış");

        try (Scanner scanner = new Scanner(System.in)) {
            while (true) {
                System.out.print("\n> ");
                String command = scanner.nextLine();

                if (command.equalsIgnoreCase("EXIT")) {
                    System.out.println("Çıkış yapılıyor...");
                    break;
                }

                sendCommand(command);
            }
        }
    }

    // ORTAK FONKSİYON: Lider'e mesajı iletir
    private static void sendCommand(String command) {
        try (Socket socket = new Socket(LEADER_HOST, LEADER_PORT);
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {

            // Komutu Lider'e gönder
            out.println(command);

            // Cevabı al ve yazdır
            String response = in.readLine();
            System.out.println("Yanıt: " + response);

        } catch (IOException e) {
            System.err.println("Hata: Lider sunucuya bağlanılamadı (" + e.getMessage() + ")");
        }
    }
}