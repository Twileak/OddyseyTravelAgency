@IsTest
public class GmailRegistrationHandlerTests {
    @IsTest
    public static void testCanCreateUser() {
        GoogleRegHandler handler = new GoogleRegHandler();
        Auth.UserData data = createUser('test@example.com','John','Adams');
        System.Assert(handler.canCreateUser(data),'Handler should be able to create this user');
    }

    @IsTest
    public static void testCanCreateUserNegative() {
        GoogleRegHandler handler = new GoogleRegHandler();
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
        System.Assert(!handler.canCreateUser(data),'Handler should not be able to create user with missing email');
    }

    @IsTest
    public static void testCreateInternalUser() {
        GoogleRegHandler handler = new GoogleRegHandler();
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        Test.startTest();
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        validate(theUser,data);
    }

    @IsTest
    public static void testCreateInternalUserNegative() {
        GoogleRegHandler handler = new GoogleRegHandler();
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
        Test.startTest();
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        System.Assert(theUser==null,'User should be null for negative case');
    }

    @IsTest
    public static void testUpdateUser() {
        GoogleRegHandler handler = new GoogleRegHandler();
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        User theUser = handler.createUser(null, data);
        insert theUser;
        Test.startTest();
        validate(theUser,data);
        data.firstName='Tom';
        handler.updateUser(theUser.id, null, data);
        User theUpdatedUser = [SELECT Id,firstName,Email,LastName
        from User
        Where Id = :theUser.id];
        validate(theUpdatedUser,data);
        Test.stopTest();
    }

    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser!=null,'User must not be null');
        System.AssertEquals(theUser.email,data.email,'Email address must be the same');
        System.AssertEquals(theUser.FirstName,data.FirstName,'First name must match');
        System.AssertEquals(theUser.LastName,data.LastName,'Last name must match');
    }


    private static Auth.UserData createUser(String email,String lastName, String firstName) {
        Map<String, String> attributeMap = new Map<String,String>();
        String identifier = lastName+System.currentTimeMillis();
        String locale = 'en_US';
        return new Auth.UserData( identifier,
                firstName,
                lastName,
                '',
                email,
                '',
                '',
                locale,
                '',
                '',
                attributeMap);
    }
}