using System;
using System.Web.Http;

namespace BBAPI.Controllers
{
	public class WorkoutController : ApiController
	{
		//use singleton
		RedisDB redisCache = RedisDB._instance;

		//create new Workout
		[HttpPost]
		public IHttpActionResult PostWorkout(string email, [FromBody]string data)
		{
			return Ok();
		}

		//create new Workout
		[HttpGet]
		public IHttpActionResult GetWorkout(string email, [FromBody]string data)
		{
			return Ok();
		}

		//update old Workout
		[HttpPut]
		public IHttpActionResult PutWorkout(string email, [FromBody]string data)
		{
			return Ok();
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
