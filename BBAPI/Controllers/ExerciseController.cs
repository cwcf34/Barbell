﻿using System.Web.Http;
using BBAPI.Helpers;
using System.Security.Claims;

namespace BBAPI.Controllers
{
	public class ExerciseController : ApiController
	{
		//use singleton
		readonly RedisDB redisCache = RedisDB._instance;

		/// <summary>
		/// Gets exercises for a user when given their email and the name of the exercise
		/// </summary>
		/// <param name="email">The email for this user</param>
		/// <param name="exercise">Should contain the name of the exercise that is being requested</param>
		/// <returns>Array of ExerciseData objects or null</returns>
		[HttpGet]
		[Authorize]
		public IHttpActionResult GetExercise(string email, string exercise)
		{
            //code to get email:
            //string email = JwtHelper.getEmail(User as ClaimsPrincipal);


            var key = "user:" + email + ":" + exercise + "Data";

            //Get the response from the database
            if (redisCache.doesKeyExist(key) == 1)
            {
                return Ok(redisCache.getExercise(key));
            }

            return Ok("Data does not exist");
            
		}


		/// <summary>
		/// Inserts data about an exercise with data given about the exercise
		/// </summary>
		/// <param name="email">User's email</param>
		/// <param name="data">date, exercise, sets, reps, weight</param>
		/// <returns></returns>
		[HttpPut]
		public IHttpActionResult PutExercise(string email, [FromBody]string data)
		{
			if (string.IsNullOrWhiteSpace(data) || string.Equals("{}", data) || !data.Contains("date:") || !data.Contains("exercise:") || !data.Contains("sets:") || !data.Contains("reps:") || !data.Contains("weight"))
			{
				var resp = "Data is not formatted correctly. Please send formatted data: ";
				var resp2 = "\"{date:date, exercise:exerciseName, sets:numOfSets, reps:numOfReps, weight:weightLifted}\"";
				string emptyResponse = resp + resp2;
				return Ok(emptyResponse);
			}

			//Parse the data given
			char[] delimiterChars = { '{', '}', ',', ':', ' ' };
			string[] dataArr = data.Split(delimiterChars);

			//extract data from the data given
			string date = dataArr[2];
			string exerciseName = dataArr[4];
			string exerciseData = dataArr[6] + ":" + dataArr[8] + ":" + dataArr[10];

			string key = "user:" + email + ":" + exerciseName + "Data";

            if (redisCache.addExercise(key, date, exerciseData))
            {
                return Ok("true");
            }
            return Ok("false");
            
        }
    }
}