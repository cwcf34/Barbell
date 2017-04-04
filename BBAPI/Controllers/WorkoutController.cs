using System;
using System.Web.Http;

namespace BBAPI.Controllers
{
	public class WorkoutController : ApiController
	{
		//use singleton
		readonly RedisDB redisCache = RedisDB._instance;

		//create new Workout
		[HttpPost]
		public IHttpActionResult PostWorkout(string email, [FromBody]string data)
		{
			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (string.IsNullOrWhiteSpace(data) || string.Equals("{}", data) || !data.Contains("routineId:") || !data.Contains("exercise:") || !data.Contains("sets:") || !data.Contains("reps:") || !data.Contains("weight:") || !data.Contains("dayIndex:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{routineId:4329432,exercise:squat,sets:5,reps:5,weight:420,dayIndex:3}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//parse email and body data for routine
			char[] delimiterChars = { '{', '}', ',', ':' };
			string[] postParams = data.Split(delimiterChars);

			var routineId = postParams[2];
			var exName = postParams[4];
			var exerciseValue = postParams[6]+ ":" +postParams[8] + ":" + postParams[10];
			var dayIndex = postParams[12];

			//user:d123 @me.com:routineId:0
			//key for a workout is defined by the routine, and week and day number
			var workoutKey = "user:" + email + ":" + routineId + ":" + dayIndex;


			/*
			 * (7*numWeeks) number of workouts for a routine
			 * so the app can function even with 7
			 * workouts for a week, all populated with ids 
			 */
			redisCache.createWorkoutDataHash(workoutKey, exName, exerciseValue);

			return Ok("exercise:" + exName + " exercise Value: " + exerciseValue);
		}

		//get all routine Workouts
		[HttpGet]
		public IHttpActionResult GetAllWorkouts(string email, int id)
		{
			//get all workout hashes for specific routine
			//var key = "user:" + email + ":" + id;


			return Ok(redisCache.getAllWorkoutHashData(email, id));
		}


		//get Workout for specific weekday
		[HttpGet]
		public IHttpActionResult GetWorkout(string email, int id, int dayIndex)
		{
			//get the dayIndex workout hash for specific routine
			var key = "user:" + email + ":" + id + ":" + dayIndex;

			return Ok(redisCache.getWorkoutHashData(key));
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
