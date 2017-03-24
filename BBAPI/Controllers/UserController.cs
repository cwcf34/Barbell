
using BBAPI.Models;
using System.Web.Http;
using System.Collections.Generic;

namespace BBAPI.Controllers
{
	public class UserController : ApiController
	{
		User[] users = {
			new User {Email = "dlopez@me.com", Name = "me", Gender = "male", Age = 22},
			new User {Email = "d@me.com", Name = "you", Gender = "male", Age = 57},
			new User {Email = "dl@me.com", Name = "us", Gender = "male", Age = 100}
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
			return Ok(redisCache.getUserHashData(email));
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
			var key = "user:" + email;

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
				var resp2 = "\"{name:name password:pw, age:age, weight:wt, squat:0, bench:0, deadlift:0, snatch:0, cleanjerk:0}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			var currEmail = email;
			//parse email and body data
			char[] delimiterChars = { '{', '}', ',', ':', ' '};
			string[] postParams = data.Split(delimiterChars);

			//grab any other data that is to be changed
			var postName = postParams[2];
			var postPassword = postParams[4];
			var postAge = postParams[6];
			var postWeight = postParams[8];
			var postSquat = postParams[10];
			var postBench = postParams[12];
			var postDeadlift = postParams[14];
			var postSnatch = postParams[16];
			var postCleanjerk = postParams[18];


			if ( string.IsNullOrWhiteSpace(postName) && string.IsNullOrWhiteSpace(postPassword))
			{
				return Ok("All fields are null! Send Data.");
			}

			//grab old user Hash data
			var currData = redisCache.getUserHashData(currEmail);
			var currRedisData = currData.Split(delimiterChars);

			//before any logic, make sure email is formatted and exists
			var emailVerfiyResponse = redisCache.emailVerify(currEmail);

			if (emailVerfiyResponse != -3)
			{
				//send error code
				switch (emailVerfiyResponse)
				{
					case -1:
						return Ok("email is empty");

					case -2:
						return Ok("email is not vaild format");

					case 1:
						return Ok("email doesnt exist");

					case -4:
						return Ok("some try catch error");
				}
			}

			//check if post data is null


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

			redisCache.updateUserHash("user:" + currEmail, postName, postAge, postWeight, postWeight, postBench,postSquat, postDeadlift, postSnatch, postCleanjerk);

			//return Ok("Successfully Updated your profile");
			return Ok("true");
		}
	}
}
