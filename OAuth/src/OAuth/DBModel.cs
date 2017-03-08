using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace OAuth
{
    public static class DBModel
    {
        private static string pWordPath = ""; //fix this
        private static string windowsVMCache = string.Format("{0}:{1},password={2}", "localhost", 6379, pWordPath);

        private static Lazy<ConnectionMultiplexer> lazyConnection = new Lazy<ConnectionMultiplexer>(() =>
        {
            return ConnectionMultiplexer.Connect(windowsVMCache);
        });

        public static ConnectionMultiplexer Connection
        {
            get
            {
                return lazyConnection.Value;
            }
        }

        private static IDatabase cache = Connection.GetDatabase();


        //Description: Finds user in the database
        //Input: email as a string
        //Output: if success, returns a new User with email and password fields set. If fail, return null
        public static User findUser(String email)
        {
            /*foreach (var user in Config.GetUsers())
            {
                if (user.Username.Equals(email))
                {
                    return new User {
                        Email = email,
                        Password = user.Password
                    };
                }
            }*/

            if(cache.KeyExists("user:" + email))
            {
                return new User
                {
                    Email = email,
                    Password = cache.HashGet("user:" + email, "password")
                };
            }

            return null;
        }
    }
}
