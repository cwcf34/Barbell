using System;
using System.Net.Mail;
using StackExchange.Redis;
using BBAPI.Models;

namespace BBAPI.Controllers
{
    class RedisDB 
    {
		public static readonly RedisDB _instance = new RedisDB();

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

		private readonly static IDatabase cache = Connection.GetDatabase();

		/// <summary>
		/// Creates the user hash.
		/// </summary>
		/// <param name="key">Key.</param>
		/// <param name="name">Name.</param>
		/// <param name="email">Email.</param>
		/// <param name="password">Password.</param>

        public void createUserHash(string key, string name, string email, string password)
        {
			//no need to check email here, check in controller
			var securePassword = AuthController.ComputeHash(password, "SHA512", null);

			cache.HashSet(key, new HashEntry[] { new HashEntry("name", name), new HashEntry("email", email), new HashEntry("password", securePassword), new HashEntry("age", 0), new HashEntry("weight", 0), new HashEntry("squat", 0), new HashEntry("bench", 0), new HashEntry("deadlift", 0), new HashEntry("snatch", 0), new HashEntry("cleanjerk", 0), new HashEntry("workoutsCompleted", 0) });
        }

		public void createRoutineHash(string key, int id, string name, string numweek, string isPublic, string creator)
		{
			//creates hash data for routine
			cache.HashSet(key, new HashEntry[] { new HashEntry("id", id), new HashEntry("name", name), new HashEntry("weeks", numweek), new HashEntry("isPublic", isPublic), new HashEntry("creator", creator) });
		}

		public void createWorkoutDataHash(string key, string exercise, string exerciseValue)
		{
			//routineid Week1 Day1 HASH
			//user:d123@me.com:routineId:0
			// - squat : set:reps:weight
			// - bench : set:reps:weight

			cache.HashSet(key, new HashEntry[] { new HashEntry(exercise, exerciseValue) });
		}

		/// <summary>
		/// Updates the user hash.
		/// </summary>
		/// <param name="key">Key.</param>
		/// <param name="name">Name.</param>
		/// <param name="email">Email.</param>
		/// <param name="password">Password.</param>
        public void updateUserHash(string key, string name, string password, string age, string weight, string bench, string squat, string deadlift, string snatch, string cleanjerk)
		{
			cache.HashSet(key, new HashEntry[] { new HashEntry("name", name), new HashEntry("age", age), new HashEntry("weight", weight), new HashEntry("bench", bench), new HashEntry("squat", squat), new HashEntry("deadlift", deadlift), new HashEntry("snatch", snatch), new HashEntry("cleanjerk", cleanjerk)  });
		}

		public void addRoutineToUserList(string key, int routineId)
		{
			//push routine id onto list
			cache.ListLeftPush(key, routineId);
		}

		public string validateUserPass(string key)
		{
			return cache.HashGet(key, "password");
		}

		//close connection needed

		public Routine[] getUserRoutines(string email)
		{
			//get user routine list
			RedisValue[] data = cache.ListRange("user:" + email + ":routines", 0, -1);

			var routineList = new Routine[data.Length];


			for (var i = 0; i < data.Length; i++)
			{
				var id = int.Parse(data[i]);
				Routine newRoutine = getRoutineHash(email, id);
				routineList.SetValue(newRoutine, i);
			}

			return routineList;
		}

		public Routine getRoutineHash(string email, int routineId)
		{
			var data = new HashEntry[] { };

			var key = "user:" + email + ":" + routineId;

			data = cache.HashGetAll(key);

			var searchedRoutine = new Routine {Name = data[1].Value, Id = data[0].Value, numWeeks = data[2].Value, isPublic = data[3].Value};

			return searchedRoutine;
				
		}

		/// <summary>
		/// Gets the user data.
		/// </summary>
		/// <returns>The user data.</returns>
		/// <param name="email">Email.</param>

		public string getUserHashData(string email)
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
					var data = new HashEntry[] { };
					data = cache.HashGetAll(key);
					string getResponse = string.Empty;

					for (int i = 0; i < data.Length; i++)
					{
						if (i == data.Length - 1)
						{
							getResponse = getResponse + data[i];
						}
						else
						{
							getResponse = getResponse + data[i] + ",";
						}
					}
					return getResponse;

				case -4:
				default:
					return "try/catch error";

			}
		}

		public HashEntry[] getWorkoutHashData(string key)
		{
			return cache.HashGetAll(key);
		}

        //check email validation
		/// <summary>
		/// verify the email.
		/// </summary>
		/// <returns>The verify code.</returns>
		/// <param name="email">Email.</param>

        public int emailVerify(string email)
        {
			var key = "user:" + email;
			 
            //check if fields are empty
			if(string.IsNullOrWhiteSpace(email))
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

		public int doesKeyExist(string key)
		{
			//check if key is in cache
			if (cache.KeyExists(key))
			{
				//key taken
				//send error code  
				return 1;
			}
			else
			{
				//key available 
				return 0;
			}
		}

		public void deleteKey(string key)
		{
			cache.KeyDelete(key);
		}


		/*
		public string[] createSecurePass(string pword)
		{
			SHA512 hash512 = SHA512.Create();
			string salt = Guid.NewGuid().ToString();
			string saltedPassword = pword + salt;

			var hashedPass = GetSha512Hash(hash512, saltedPassword);
			string[] returnArray = new string[2];

			returnArray.SetValue(hashedPass, 0);
			returnArray.SetValue(salt, 1);

			return returnArray;
		}

        public string GetSha512Hash(SHA512 sha512Hash, string input)
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
		*/
    }
}
