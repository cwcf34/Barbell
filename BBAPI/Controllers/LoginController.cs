using System;
using System.Web.Http;
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


			var userHash = SHA512.Create(plainPassword);

			var saltedPass = redisCache.createSecurePass(userHash,plainPassword);
			var redisPass = redisCache.validateUserPass("user:"+email);



			return Ok("You posted this to me: " + postParams[0] + "\n" + postParams[1] + "\n" + postParams[2] + " \n 0 " + saltedPass + " \n 1 " + redisPass);
			/*
			if (saltedPass == redisPass)
			{
				return Ok("Incorrect Password");
			}
			*/
		}
	}
}
