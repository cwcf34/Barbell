using System;
using System.Collections.Generic;
using System.Web.Http;
using BBAPI.Models;

namespace BBAPI.Controllers
{
	public class RoutineController : ApiController
	{
		//create a new Routine with mulitple workouts

		//create new Routine
		[HttpPost]
		public IHttpActionResult PostRoutine(string email, [FromBody]string data)
		{
			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data) || !data.Contains("name:") || !data.Contains("weeks:") || !data.Contains("isPublic:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:routineName, weeks:numberOfweeks, public:0/1: creator:email }\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//before any logic, make sure email is formatted and registered
			var emailVerfiyResponse = RedisDB.emailVerify(email);

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

			var id = getRandomId();

			//create routine key
			var key = "user:" + email + ":" + id;

			while (RedisDB.doesKeyExist(key) == 1)
			{
				id = getRandomId();

				//create new routine key
				key = "user:" + email + ":" + id;
			}


			var name = postParams[2];
			var weeks = postParams[4];
			var isPubilc = postParams[6];
			var creator = email;

			//get routine data
			RedisDB.createRoutineHash(key, id, name, weeks, isPubilc, creator);
			return Ok("New Routine Created");
					
		}

		private int getRandomId()
		{
			var randGen = new Random();
			var randGuid = Guid.NewGuid().GetHashCode();
			if (randGuid < 0)
			{
				randGuid = randGuid * -1;
			}
			return randGen.Next(randGuid);

		}
	}
}
