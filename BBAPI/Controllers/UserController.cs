using System;
using System.Net;
using System.Linq;
using System.Collections.Generic;
using System.Web.Http;
using BBAPI.Models;

namespace BBAPI.Controllers
{
	public class UserController : ApiController
	{
		User[] users = new User[]{
			new User {Email = "dlopez@me.com", Name = "me", Gender = "male", Age = 22},
			new User {Email = "d@me.com", Name = "you", Gender = "male", Age = 57},
			new User {Email = "dl@me.com", Name = "us", Gender = "male", Age = 100}
		};

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
			return Ok(RedisDB.getUserData(email));
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
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}",data) || !data.Contains("name:") || !data.Contains("password:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:name, password:pw}\""; 
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//before any logic, make sure email is formatted and unique
			var emailVerfiyResponse = RedisDB.emailVerify(email);

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
			char[] delimiterChars = {'{', '}', ',', ':'};
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
			RedisDB.createUserHash(key, postParams[2], email, postParams[4]);

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
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data) || !data.Contains("id:") || !data.Contains("name:") || !data.Contains("weight:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{id:name, name:pw, weight:weight}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}


			//before any logic, make sure email is formatted and unique
			var emailVerfiyResponse = RedisDB.emailVerify(email);

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

			//parse email and body data
			char[] delimiterChars = { '{', '}', ',', ':' };
			string[] postParams = data.Split(delimiterChars);

			//email is now verified as avail in cache
			//create key
			var key = "user:" + email + postParams[4];

			//create hash for new user
			//store hash in Redis
			//send to RedisDB
			RedisDB.workoutHash(key, postParams[2], postParams[4], postParams[6]);

			var returnString = "user:" + postParams[2] + "pss:" + postParams[4];

			return Ok("you put" + returnString);
		}
	}
}
