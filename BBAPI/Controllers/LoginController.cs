using System;
using System.Web.Http;
using System.Collections.Generic;
using System.Security.Cryptography;

namespace BBAPI.Controllers
{
	public class LoginController : ApiController
	{
		//use singleton
		RedisDB redisCache = RedisDB._instance;


		//login is a post request
		[HttpPost]
		public IHttpActionResult PostLogin(string email, [FromBody]string data)
		{
			//!!![FromBody]!!!
			//sets post body = data


			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data) || !data.Contains("password:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{password:pw}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//before any logic, make sure email is formatted and registered
			var emailVerfiyResponse = redisCache.emailVerify(email);

			//if email is registered  
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

			//parse email and body data for routine
			char[] delimiterChars = { '{', '}', ',', ':' };
			string[] postParams = data.Split(delimiterChars);

			var plainPassword = postParams[2];

			//var userData = redisCache.getUserData("user:" + email).Split(delimiterChars);
			var currUserData = redisCache.getUserData(email);

			var parsedData = currUserData.Split(delimiterChars);

			if (parsedData.Length > 1)
			{


				//get SALT from DB,
				var salt = parsedData[0];

				//add salt to pass
				var saltedPass = plainPassword + salt;

				//512HASH it with the saltedPass 
				var hashSaltPassword = redisCache.GetSha512Hash(SHA512.Create(), saltedPass);

				//compare to hashedpassword in DB
				if (hashSaltPassword == parsedData[1])
				{

				}

				return Ok("You posted this to me: " + postParams[0] + "\n" + postParams[1] + "\n" + postParams[2] + " \n 0 " + parsedData[0] + " \n 1 " + parsedData[1] + " \n 2 " + parsedData[2] + " \n 3 " + parsedData[3]);

			}
			else
			{
				return Ok(currUserData);
			}
		}
	}
}
