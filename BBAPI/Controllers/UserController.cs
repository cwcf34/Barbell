﻿
using BBAPI.Models;
using System.Web.Http;
using System.Collections.Generic;

namespace BBAPI.Controllers
{
	public class UserController : ApiController
	{
		User[] users = {
			new User {Email = "dlopez@me.com", Name = "me", Age = 22},
			new User {Email = "d@me.com", Name = "you", Age = 57},
			new User {Email = "dl@me.com", Name = "us", Age = 100}
		};

		//use singleton
		readonly RedisDB redisCache = RedisDB._instance;

		/// <summary>
		/// Gets all users.
		/// </summary>
		/// <returns>The all users.</returns>

		[HttpGet]
		public IEnumerable<User> GetAllUsers()
		{
			return users;
		}

		/// <summary>
		/// Gets the user.
		/// </summary>
		/// <returns>The user.</returns>
		/// <param name="email">Email.</param>

		[HttpGet]
		public IHttpActionResult GetUser(string email)
		{
			//search for user hash w key in cache
			var returnString = redisCache.getUserHashData(email);
			if (returnString[0].Name == "data")
			{
				return Ok(returnString[0].Value.ToString());
			}
			else
			{
				return Ok(false);
			}
		}


		/// <summary>
		/// Posts the user.
		/// </summary>
		/// <returns>The user.</returns>
		/// <param name="email">Email.</param>
		/// <param name="data">Data.</param>

		[HttpPost]
		public IHttpActionResult PostUser(string email, [FromBody]string data)
		{
			//!!![FromBody]!!!
			//sets post body = data


			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (string.IsNullOrWhiteSpace(data) || string.Equals("{}", data) || !data.Contains("name:") || !data.Contains("password:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:name, password:pw}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//before any logic, make sure email is formatted and unique
			var emailVerfiyResponse = redisCache.emailVerify(email);

			if (emailVerfiyResponse != 1)
			{
				/*
				//send error code
				switch (emailVerfiyResponse)
				{
					case -1:
						return Ok("email is empty");

					case -2:
						return Ok("email is not vaild format");

					case -3:
						return Ok("email is already registered");

					case -4:
						return Ok("some try catch error");
				}
				*/
				Ok("false");
			}

			//email is now verified as avail in cache
			//create key
			var key = "user:" + email.ToLower();

			//parse email and body data
			char[] delimiterChars = { '{', '}', ',', ':', ' ' };
			string[] postParams = data.Split(delimiterChars);

			var postName = postParams[2] + " " + postParams[3];
			var postPass = postParams[5];

			//if name or password fields are empty
			if (string.IsNullOrWhiteSpace(postParams[2]) || string.IsNullOrWhiteSpace(postParams[5]))
			{
				string postError = "user=" + postParams[2] + " " + postParams[3] + "pss=" + postParams[5];
				return Ok(postError);
			}

			//create hash for new user
			//store hash in Redis
			//send to RedisDB
			redisCache.createUserHash(key, postName, email, postPass);

			//var returnString = "user:" + postParams[2] + "pss:" + postParams[4];

			/*
			//user registered 200 OK HTTP response
			return Ok(returnString);
			*/
			return Ok("true");
		}


		/// <summary>
		/// Puts the user.
		/// </summary>
		/// <returns>The user.</returns>
		/// <param name="email">Email.</param>
		/// <param name="data">Data.</param>
		[HttpPut]
		public IHttpActionResult PutUser(string email, [FromBody]string data)
		{

			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (string.IsNullOrWhiteSpace(data) || string.Equals("{}", data) || !data.Contains("name:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:name lklk,password:pw, age:age, weight:wt, squat:0, bench:0, deadlift:0, snatch:0, cleanjerk:0}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			var currEmail = email;
			//parse email and body data
			char[] delimiterChars = { '{', '}', ',', ':', ' '};
			string[] postParams = data.Split(delimiterChars);

			//grab any other data that is to be changed
			var postName = postParams[2] + " " + postParams[3];
			var postPassword = postParams[5];
			var postAge = postParams[7];
			var postWeight = postParams[9];
			var postSquat = postParams[11];
			var postBench = postParams[13];
			var postDeadlift = postParams[15];
			var postSnatch = postParams[17];
			var postCleanjerk = postParams[19];
			var postWorkouts = postParams[21];

			if ( string.IsNullOrWhiteSpace(postName) && string.IsNullOrWhiteSpace(postPassword))
			{
				return Ok("All fields are null! Send Data.");
			}

			//grab old user Hash data
			var returnedUser = redisCache.getUserHashData(currEmail);
			var currData = string.Empty;

			if (returnedUser[0].Name == "data")
			{
				currData = returnedUser[0].Value.ToString();
			}
			else
			{
				return Ok(returnedUser[0].Value.ToString());
			}

			var currRedisData = currData.Split(delimiterChars);

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postName))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "name")
					{
						//grab curr name
						postName = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postAge))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "age")
					{
						//grab curr name
						postAge = currRedisData[i + 2];
					}
				}
			}
			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postWeight))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "weight")
					{
						//grab curr name
						postWeight = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postSquat))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "squat")
					{
						//grab curr name
						postSquat = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postBench))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "bench")
					{
						//grab curr name
						postBench = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postDeadlift))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "deadlift")
					{
						//grab curr name
						postDeadlift = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postSnatch))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "snatch")
					{
						//grab curr name
						postSnatch = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postCleanjerk))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "cleanjerk")
					{
						//grab curr name
						postCleanjerk = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr workouts
			if (string.IsNullOrWhiteSpace(postWorkouts))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "workoutsCompleted")
					{
						//grab curr name
						postWorkouts = currRedisData[i + 2];
					}
				}
			}

			//if null, user keeps curr password
			if (string.IsNullOrWhiteSpace(postPassword))
			{
				for (int i = 0; i < currRedisData.Length; i++)
				{
					if (currRedisData[i] == "password")
					{
						//grab curr password
						postPassword = currRedisData[i + 2];
					}
				}
			}
			else
			{
				postPassword = AuthController.ComputeHash(postPassword, "SHA512", null);
			}

				redisCache.updateUserHash("user:" + currEmail, postName, postPassword, postAge, postWeight,postBench, postSquat, postDeadlift, postSnatch, postCleanjerk, postWorkouts);

			//return Ok("Successfully Updated your profile");
			return Ok("true");
		}
	}
}
