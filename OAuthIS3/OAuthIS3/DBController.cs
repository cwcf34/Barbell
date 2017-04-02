using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Configuration;

namespace OAuthIS3
{
    public class DBController
    {
        private static string pWordPath = WebConfigurationManager.AppSettings["bbAPI_Auth"];
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
            if (cache.KeyExists("user:" + email))
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