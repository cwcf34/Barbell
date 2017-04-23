
using BBAPI.Models;
using System.Web.Http;
using System.Collections.Generic;

namespace BBAPI.Controllers
{
	public class UserController : ApiController
	{
		/*
		User[] users = {
			new User {Email = "dlopez@me.com", Name = "me", Age = 22},
			new User {Email = "d@me.com", Name = "you", Age = 57},
			new User {Email = "dl@me.com", Name = "us", Age = 100}
		};

		*/
		//use singleton
		readonly RedisDB redisCache = RedisDB._instance;

		/// <summary>
		/// Gets all users.
		/// </summary>
		/// <returns>The all users.</returns>

		//[HttpGet]
		//public IEnumerable<User> GetAllUsers()
		//{
		//	return users;
		//}

		/// <summary>
		/// Gets the user.
		/// </summary>
		/// <returns>The user.</returns>
		/// <param name="email">Email.</param>

		[HttpGet]
        [Authorize]
        public IHttpActionResult GetUser(string email)
		{
			//search for user hash w key in cache
			var returnString = redisCache.getUserHashData(email);
			if (returnString != null)
			{
				return Ok(returnString);
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
        [Authorize]
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


			var currUser = new User();

			if (returnedUser != null)
			{
				currUser = returnedUser;
			}
			else
			{
				return Ok(returnedUser);
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postName))
			{
				postName = currUser.Name;
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postAge))
			{
				postAge = currUser.Age.ToString();
			}
			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postWeight))
			{
				postWeight = currUser.Weight.ToString();
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postSquat))
			{
				postSquat = currUser.Squat.ToString();
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postBench))
			{
				postBench = currUser.Bench.ToString();
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postDeadlift))
			{
				postDeadlift = currUser.Deadlift.ToString();
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postSnatch))
			{
				postSnatch = currUser.Snatch.ToString();
			}

			//if null, user keeps curr name
			if (string.IsNullOrWhiteSpace(postCleanjerk))
			{
				postCleanjerk = currUser.CleanAndJerk.ToString();
			}

			//if null, user keeps curr workouts
			if (string.IsNullOrWhiteSpace(postWorkouts))
			{
				postWorkouts = currUser.WorkoutsCompleted.ToString();
			}

			//if null, user keeps curr password
			if (string.IsNullOrWhiteSpace(postPassword))
			{
				postPassword = currUser.Password;
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
