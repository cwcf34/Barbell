using System;
using System.Web;
using System.Text;
using System.Net.Mail;
using StackExchange.Redis;
// to hash and salt pword: 
using System.Security.Cryptography;

namespace BBAPI.Controllers
{
    class RedisDB 
    {
		private static string pWordPath = System.Web.Configuration.WebConfigurationManager.AppSettings["bbAPI_Auth"];
		private static string windowsVMCache = string.Format("{0}:{1},password={2}", "localhost",6379, pWordPath);

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

		/// <summary>
		/// Creates the user hash.
		/// </summary>
		/// <param name="key">Key.</param>
		/// <param name="name">Name.</param>
		/// <param name="email">Email.</param>
		/// <param name="password">Password.</param>

        public static void createUserHash(string key, string name, string email, string password)
        {
			//no need to check email here, check in controller
			var saltedPassword = createSecurePass(password);

			cache.HashSet(key, new HashEntry[] { new HashEntry("name", name), new HashEntry("email", email), new HashEntry("password", saltedPassword) });
        }


		/// <summary>
		/// Updates the user hash.
		/// </summary>
		/// <param name="key">Key.</param>
		/// <param name="name">Name.</param>
		/// <param name="email">Email.</param>
		/// <param name="password">Password.</param>
        public static void updateUserHash(string key, string name, string email, string password)
		{
			cache.HashSet(key, new HashEntry[] { new HashEntry("name", name), new HashEntry("email", email), new HashEntry("password", password) });
		}
        
		/// <summary>
		/// Gets the user data.
		/// </summary>
		/// <returns>The user data.</returns>
		/// <param name="email">Email.</param>

        public static string getUserData(string email)
        {
			int emailVerifyResponse = emailVerify(email);

			switch (emailVerifyResponse)
			{
				case 1: //means no key exists
					return "User not found.";
				
				case -1: //empty email
					return "Email field empty.";
				
				case -2: //incorrect format
					return "Email not formatted correctly.";
				
				case -3: //means key exists
					var key = "user:" + email;
					var data = new HashEntry[] {};
					data = cache.HashGetAll(key);
					string getResponse = String.Empty;
					for (int i = 0; i < data.Length; i++)
					{
						getResponse = getResponse + data[i] + ",";
					}
					return getResponse;
				
				case -4:
				default:
					return "try/catch error";
			}
        }


        public static void createRoutineHash(string key, int id, string name, string numweek, string isPublic, string creator)
        {
			cache.HashSet(key, new HashEntry[] { new HashEntry("id", id), new HashEntry("name", name), new HashEntry("isPublic", isPublic), new HashEntry("creator", creator) });
        }


        public static void deleteKey(string key)
        {
            cache.KeyDelete(key);
        }


        //close connection needed

        //check email validation
		/// <summary>
		/// verify the email.
		/// </summary>
		/// <returns>The verify code.</returns>
		/// <param name="email">Email.</param>

        public static int emailVerify(string email)
        {
			var key = "user:" + email;
			 
            //check if fields are empty
			if(String.IsNullOrWhiteSpace(email))
            {
                //send error message
                return -1;
            }

			try
			{
				var mail = new MailAddress(email);

				if (mail.Host.Contains("."))
				{
					//check if unique emailaddress
					if (cache.KeyExists(key))
					{
						//email taken
						//send error code for email taken
						return -3;
					}
					else
					{
						return 1;
					}
				}
				else
				{
					return -2;
				}
			}
			catch
			{
				return -4;
			}
        }

		/// <summary>
		/// Does the key exist.
		/// </summary>
		/// <returns>If the key exist</returns>
		/// <param name="key">Key</param>

		public static int doesKeyExist(string key)
		{
			//check if unique routineID
			if (cache.KeyExists(key))
			{
				//routineID taken
				//send error code to  
				return -1;
			}
			else
			{
				return 1;
			}
		}


		/// <summary>
		/// Creates the secure pass.
		/// </summary>
		/// <returns>The secure pass.</returns>
		/// <param name="pword">Pword.</param>

		public static string createSecurePass(string pword)
		{
			SHA512 sha512Hash = SHA512.Create();
			string salt = Guid.NewGuid().ToString();
			string saltedPassword = pword + salt;

			return GetSha512Hash(sha512Hash, saltedPassword);
		}

        //Compute a hash using the Sha512 algorithm
		/// <summary>
		/// Gets the sha512 hash.
		/// </summary>
		/// <returns>The sha512 hash.</returns>
		/// <param name="sha512Hash">Sha512 hash.</param>
		/// <param name="input">Input.</param>

        public static string GetSha512Hash(SHA512 sha512Hash, string input)
        {

            // Convert the input string to a byte array and compute the hash.
            byte[] data = sha512Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

            // Create a new Stringbuilder to collect the bytes
            // and create a string.
            StringBuilder sBuilder = new StringBuilder();

            // Loop through each byte of the hashed data
            // and format each one as a hexadecimal string.
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }

            // Return the hexadecimal string.
            return sBuilder.ToString();
        }
    }
}
