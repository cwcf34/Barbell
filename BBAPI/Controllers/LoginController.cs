using System.Web.Http;

namespace BBAPI.Controllers
{
	public class LoginController : ApiController
	{
		//use singleton
		readonly RedisDB redisCache = RedisDB._instance;


		//login is a post request
		[HttpPost]
		public IHttpActionResult PostLogin(string email, [FromBody]string data)
		{
			//!!![FromBody]!!!
			//sets post body = data


			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (string.IsNullOrWhiteSpace(data) || string.Equals("{}", data) || !data.Contains("password:"))
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
				/*
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
				*/
				return Ok("false");
			}

			//parse email and body data for routine
			char[] delimiterChars = { '{', '}', ',', ':' };
			string[] postParams = data.Split(delimiterChars);

			var plainPassword = postParams[2];

			//var userData = redisCache.getUserData("user:" + email).Split(delimiterChars);
			var currPass = redisCache.validateUserPass("user:" + email);

			//512HASH it with the saltedPass 
			var verifyedUser = AuthController.VerifyHash(plainPassword, "SHA512", currPass);

			if (verifyedUser == true)
			{
				return Ok("true");
			}
			else
			{
				return Ok("false");
			}
		}
	}
}
