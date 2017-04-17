using System;
using System.Net.Mail;
using StackExchange.Redis;
using BBAPI.Models;
using System.Collections.Generic;

namespace BBAPI.Controllers
{
	class RedisDB
	{
		public static readonly RedisDB _instance = new RedisDB();

		private static string pWordPath = System.Web.Configuration.WebConfigurationManager.AppSettings["bbAPI_Auth"];
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



		private readonly static IDatabase cache = Connection.GetDatabase();
		private readonly static IServer cacheServer = Connection.GetServer("localhost", 6379);

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
		/// <param name="password">Password.</param>
		public void updateUserHash(string key, string name, string password, string age, string weight, string bench, string squat, string deadlift, string snatch, string cleanjerk, string workouts)
		{
			cache.HashSet(key, new HashEntry[] { new HashEntry("name", name), new HashEntry("password", password), new HashEntry("age", age), new HashEntry("weight", weight), new HashEntry("bench", bench), new HashEntry("squat", squat), new HashEntry("deadlift", deadlift), new HashEntry("snatch", snatch), new HashEntry("cleanjerk", cleanjerk), new HashEntry("workoutsCompleted", workouts) });
		}

		public void addRoutineToUserList(string key, int routineId)
		{
			//push routine id onto list
			cache.ListLeftPush(key, routineId);
		}

		/// <summary>
		/// Add a completed exercise to the hash for that user's exercise.
		/// </summary>
		/// <param name="key"></param>
		/// <param name="date"></param>
		/// <param name="exerciseData"></param>
		/// <returns>True if the operation succeeded, else false</returns>
		public bool addExercise(string key, string date, string exerciseData)
		{

			if (key.Length > 0 && date.Length > 0 && exerciseData.Length > 0)
			{
				try
				{
					//Add a field to the hash for that exercise with the key as the current date and the data as the data from the completed exercise
					cache.HashSet(key, new HashEntry[] { new HashEntry(date, exerciseData) });
				}
				catch
				{
					//An exception occured
					return false;
				}
				//Success
				return true;
			}

			//parameter checking failed
			return false;
		}

		/// <summary>
		/// Grabs all the exercise data from the key given
		/// </summary>
		/// <param name="key">The key for the hash of exercise data</param>
		/// <returns>Array of the data for that exercise or null</returns>
		public ExerciseData[] getExercise(string key)
		{
			//Call the database to get the data to parse
			List<HashEntry> unparsedData = new List<HashEntry>(cache.HashGetAll(key));
			List<ExerciseData> data = new List<ExerciseData>();

			DateTime newDate;
			try
			{
				//Parse the data returned
				foreach (HashEntry entry in unparsedData)
				{
					//Parse the date
					string[] stringDate = entry.Name.ToString().Split('/');
					newDate = new DateTime(int.Parse(stringDate[2]), int.Parse(stringDate[0]), int.Parse(stringDate[1]));

					//Parse the data and set it to a new ExerciseData object
					string[] stringData = entry.Value.ToString().Split(':');

					//Add the new data to the array
					data.Add(new ExerciseData(newDate, int.Parse(stringData[0]), int.Parse(stringData[1]), int.Parse(stringData[2])));
				}
			}
			catch
			{
				return null;
			}

			//Return an array of ExerciseData objects
			return data.ToArray();
		}

		public string validateUserPass(string key)
		{
			return cache.HashGet(key, "password");
		}

		//close connection needed

		public List<Routine> searchForRoutine(string name) {

			var data = cacheServer.Keys(0, "user:[A-Za-z@.]*:[^:][^:][^:][^:][^:]");

			var returnData = new List<Routine>();

			foreach (var key in data)
			{
				var routineData = cache.HashGetAll(key);
				if (routineData != null)
				{
					foreach (var field in routineData)
					{
						if (field.Name.ToString().Equals("name") && (field.Value.ToString().Contains(name.ToLower()) || field.Value.ToString().Contains(name.ToUpper())))
						{
							if (routineData[3].Value.ToString().Equals("1")) {
								returnData.Add(new Routine { Name = routineData[1].Value, Id = routineData[0].Value, numWeeks = routineData[2].Value, isPublic = routineData[3].Value });
							}
						}
					}

				}
			}

			return returnData;

		}

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

			var searchedRoutine = new Routine { Name = data[1].Value, Id = data[0].Value, numWeeks = data[2].Value, isPublic = data[3].Value };

			return searchedRoutine;

		}

		/// <summary>
		/// Gets the user data.
		/// </summary>
		/// <returns>The user data.</returns>
		/// <param name="email">Email.</param>

		public HashEntry[] getUserHashData(string email)
		{
			//check if email is verifyed in Redis
			int emailVerifyResponse = emailVerify(email);

			switch (emailVerifyResponse)
			{
				case 1: //no email exists
					return new HashEntry[] { new HashEntry("error", "User not found.") };

				case -1: //empty field email
					return new HashEntry[] { new HashEntry("error", "Email field empty.") };

				case -2: //incorrect email format
					return new HashEntry[] { new HashEntry("error", "Email not formatted correctly.") };

				case -3: //YAY email exists

					//create key for Redis call
					var key = "user:" + email;

					//new empty Hash to pass data
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
					return new HashEntry[] { new HashEntry("data", getResponse) };

				case -4:
				default:
					return new HashEntry[] { new HashEntry("error", "Try/Catch Error on Email Verification") };
			}
		}

		public HashEntry[] getWorkoutHashData(string key)
		{
			return cache.HashGetAll(key);
		}

		public List<HashEntry[]> getAllWorkoutHashData(string email, int id)
		{
			var routine = getRoutineHash(email, id);

			int weeks = int.Parse(routine.numWeeks);
			int days = (weeks * 7);

			var newData = new List<HashEntry[]>();

			for (var i = 0; i < days; i++)
			{
				var key = "user:" + email + ":" + id + ":" + i;
				var workoutData = getWorkoutHashData(key);
				newData.Add(workoutData);
			}

			return newData;

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
			if (string.IsNullOrWhiteSpace(email))
			{
				//send error message
				return -1;
			}

			try
			{
				var mail = new MailAddress(email);

				if (mail.Host.Contains(".") && mail.Host.Contains("@"))
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

		public bool deleteKey(string key)
		{
			return cache.KeyDelete(key);
		}

		public long deleteRoutineItem(string key, int routineId)
		{
			return cache.ListRemove(key, routineId, 0);
		}
	}
}