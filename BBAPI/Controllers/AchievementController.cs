using System;
using System.Web.Http;
using StackExchange.Redis; 

namespace BBAPI.Controllers
{
	public class AchievementController : ApiController
	{
		//use singleton
		readonly RedisDB redisCache = RedisDB._instance;

		[HttpGet]
		[Authorize]
		public IHttpActionResult GetAchievements(string email)
		{
			var key = "user" + email + ":achievement:";

			var returnData = redisCache.getAchievements(key);

			return Ok(returnData);
		}

		[HttpPost]
		[Authorize]
		public IHttpActionResult PostAchievement(string email, [FromBody]string data)
		{
			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (string.IsNullOrWhiteSpace(data) || string.Equals("{}", data) || !data.Contains("date:") || !data.Contains("id:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{date:4/20/17,id:0}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//Parse the data given
			char[] delimiterChars = { '{', '}', ',', ':', ' ' };
			string[] dataArr = data.Split(delimiterChars);

			var date = dataArr[2];
			var id = dataArr[4];

			var key = "user:" + email + ":achievement:" + id;

			return Ok(redisCache.createAchievemntHash(key, date));
		}

	}
}
