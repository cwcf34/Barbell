using System;
using BBAPI.Models;
using System.Web.Http;
using System.Collections.Generic;
using System.Security.Cryptography;


namespace BBAPI.Controllers
{
	public class UserController : ApiController
	{
		User[] users = new User[]{
			new User {Email = "dlopez@me.com", Name = "me", Gender = "male", Age = 22},
			new User {Email = "d@me.com", Name = "you", Gender = "male", Age = 57},
			new User {Email = "dl@me.com", Name = "us", Gender = "male", Age = 100}
		};

		//use singleton
		RedisDB redisCache = RedisDB._instance;

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
			return Ok(redisCache.getUserData(email));
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
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data) || !data.Contains("name:") || !data.Contains("password:"))
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
			}

			//email is now verified as avail in cache
			//create key
			var key = "user:" + email;

			//parse email and body data
			char[] delimiterChars = { '{', '}', ',', ':' };
			string[] postParams = data.Split(delimiterChars);

			//if name or password fields are empty
			if (String.IsNullOrWhiteSpace(postParams[2]) || String.IsNullOrWhiteSpace(postParams[4]))
			{
				string postError = "user=" + postParams[2] + "pss=" + postParams[3];
				return Ok(postError);
			}

			//create hash for new user
			//store hash in Redis
			//send to RedisDB
			redisCache.createUserHash(key, postParams[2], email, postParams[4]);

			var returnString = "user:" + postParams[2] + "pss:" + postParams[4];

			//user registered 200 OK HTTP response
			return Ok(returnString);

			//store relation "hash" in SQLite
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
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data) || !data.Contains("name:") || !data.Contains("email:") || !data.Contains("password:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:name, email:email, password:pw}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			var currEmail = email;
			//parse email and body data
			char[] delimiterChars = { '{', '}', ',', ':', ' '};
			string[] postParams = data.Split(delimiterChars);

			//get new email
			var newEmail = postParams[4];
			//grab any other data that is to be changed
			var postName = postParams[2];
			var postPassword = postParams[6];

			string[] passAndSalt = new string[2];


			if (String.IsNullOrWhiteSpace(newEmail) && String.IsNullOrWhiteSpace(postName) && String.IsNullOrWhiteSpace(postPassword))
			{
				return Ok("All fields are null! Send Data.");
			}

			//grab old user Hash data
			var currData = redisCache.getUserData(currEmail);
			//var currRedisData = currData.Split(delimiterChars);

			//if sending Put request and email field has data
			//user wants to change email address
			//old user hash is deleted in the process / new hash key is created
			if (!(String.IsNullOrWhiteSpace(newEmail)))
			{
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


				//before any logic, make sure New Email is formatted and unique
				var newEmailVerfiyResponse = redisCache.emailVerify(newEmail);

				if (newEmailVerfiyResponse != 1)
				{
					//send error code
					switch (newEmailVerfiyResponse)
					{
						case -1:
							return Ok("New email is empty.");

						case -2:
							return Ok("New email is not vaild format.");

						case -3:
							return Ok("New email is already registered.");

						case -4:
							return Ok("Some New try catch error");
					}
				}

				//user is registerd and now allowed to change currEmail to a new unique Email

				//if null, user keeps curr name
				if (String.IsNullOrWhiteSpace(postName))
				{
					/*
					for (int i = 0; i < currRedisData.Length; i++)
					{
						if (currRedisData[i] == "name")
						{
							//grab curr name
							postName = currRedisData[i + 2];
						}
					}
					*/

					  
				}

				//if null, user keeps curr password
				if (String.IsNullOrWhiteSpace(postPassword))
				{	
					/*
					for (int i = 0; i < currRedisData.Length; i++)
					{
						if (currRedisData[i] == "password")
						{
							//grab curr password
							postPassword = currRedisData[i+2];
						}
					}
					*/
				}
				else
				{
					passAndSalt = redisCache.createSecurePass(postPassword);
				}

				//delete old key w old data
				redisCache.deleteKey("user:" + currEmail);

				//create new key, and update hash
				redisCache.updateUserHash("user:" + newEmail, postName, newEmail, passAndSalt[0]);

				return Ok("Successfully updated your profile with new email!");
			}
			else 
			{
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
				if (String.IsNullOrWhiteSpace(postName))
				{
					/*
					for (int i = 0; i < currRedisData.Length; i++)
					{
						if (currRedisData[i] == "name")
						{
							//grab curr name
							postName = currRedisData[i + 2];
						}
					}
					*/
				}

				//if null, user keeps curr password
				if (String.IsNullOrWhiteSpace(postPassword))
				{
					/*
					for (int i = 0; i < currRedisData.Length; i++)
					{
						if (currRedisData[i] == "password")
						{
							//grab curr password
							postPassword = currRedisData[i + 2];
						}
					}
					*/
				}
				else
				{
					
					passAndSalt = redisCache.createSecurePass(postPassword);
				}

				redisCache.updateUserHash("user:" + currEmail, postName, currEmail, passAndSalt[0]);

				return Ok("Successfully Updated your profile");
			}
		}


	}
}
