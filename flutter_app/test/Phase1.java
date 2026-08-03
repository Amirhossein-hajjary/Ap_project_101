import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import org.junit.Before;
import org.junit.Test;

import models.User;

public class Phase1 {
    private User u1;
    private User u2;

    @Before
    public void first() {
        try {
            u1 = new User("ali","SalamPass3");
            u2 = new User("behnam", "DarbazeBia2");
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    @Test
    public void test1() {
        assertEquals(u2.getUserName(), "behnam");
        assertEquals(u2.getPassword(), "DarbazeBia2");
    }
}