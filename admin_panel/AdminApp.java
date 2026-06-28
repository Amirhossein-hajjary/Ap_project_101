import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;

public class AdminApp extends JFrame {
    private DefaultListModel<String> userListModel;
    private JList<String> userList;

    public AdminApp() {
        setTitle("Gallery App - Admin Panel");
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        // Mock Data
        userListModel = new DefaultListModel<>();
        userListModel.addElement("User1 - Photos: 12, Albums: 3 [Active]");
        userListModel.addElement("User2 - Photos: 45, Albums: 6 [Active]");
        userListModel.addElement("User3 - Photos: 0, Albums: 1 [Banned]");

        userList = new JList<>(userListModel);
        JScrollPane scrollPane = new JScrollPane(userList);

        JButton banButton = new JButton("Ban/Unban User");
        JButton refreshButton = new JButton("Refresh Data");
        
        banButton.addActionListener(e -> {
            int selected = userList.getSelectedIndex();
            if (selected != -1) {
                String val = userListModel.get(selected);
                if (val.contains("[Active]")) {
                    userListModel.set(selected, val.replace("[Active]", "[Banned]"));
                } else {
                    userListModel.set(selected, val.replace("[Banned]", "[Active]"));
                }
            }
        });

        JPanel panel = new JPanel(new BorderLayout());
        panel.add(new JLabel(" User Management System", SwingConstants.CENTER), BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel();
        buttonPanel.add(banButton);
        buttonPanel.add(refreshButton);
        panel.add(buttonPanel, BorderLayout.SOUTH);

        add(panel);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new AdminApp().setVisible(true);
        });
    }
}
