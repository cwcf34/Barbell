using System;
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
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:name, email:email, password:pw}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}
			else if (data.Contains("email:"))
			{
				//before any logic, make sure email is formatted and exists
				var emailVerfiyResponse = RedisDB.emailVerify(email);

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

				//parse email and body data
				char[] delimiterChars = { '{', '}', ',', ':' };
				string[] postParams = data.Split(delimiterChars);

				int numParams = postParams.Length;
				int count = 0;

				//create hash for new user
				//store hash in Redis
				//send to RedisDB
				//RedisDB.createUserHash(key, postParams[2], postParams[4], postParams[6]);

				int emailParamNum = 0;

				var returnString = "";
				//var fullReturn = "allParams:" + numParams + "Param0: " + postParams[0] + "name: " + postParams[2] + "email: " + postParams[4] + "password: " + postParams[6];

				for (count = 0; count < numParams; count++)
				{
					returnString = returnString + "postParam[" + count + "]: " + postParams[count];
					if (postParams[count] == "email")
					{
						emailParamNum = count + 1;
					}
				}

				//before any logic, make sure email is formatted and unique
				var newEmailVerfiyResponse = RedisDB.emailVerify(postParams[emailParamNum]);

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

				//user is registerd and now allowed to change field to  new unique Email
				//grab old user Hash data 

				//create new key for new User hash w/ remaining data



				return Ok("you put" + returnString + "and email response was unique");
			}
			else
			{
				return Ok("some else if error");
			}
		}
	}
}
