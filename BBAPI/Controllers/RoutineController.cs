﻿using System;
using System.Web.Http;
using System.Collections.Generic;


namespace BBAPI.Controllers
{
	public class RoutineController : ApiController
	{
		//use singleton
		RedisDB redisCache = RedisDB._instance;

		//create a new Routine with mulitple workouts

		//create new Routine
		[HttpPost]
		public IHttpActionResult PostRoutine(string email, [FromBody]string data)
		{
			//check if body is empty, white space or null
			// or appropriate JSON fields are not in post body
			if (String.IsNullOrWhiteSpace(data) || String.Equals("{}", data) || !data.Contains("name:") || !data.Contains("weeks:") || !data.Contains("isPublic:") || !data.Contains("creator:"))
			{
				var resp = "Data is null. Please send formatted data: ";
				var resp2 = "\"{name:routineName,weeks:numberOfweeks,public:0/1,creator:email}\"";
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

			var routineId = getRandomId();

			//create routine key
			var key = "user:" + email + ":" + routineId;

			//while key is taken, generate new key
			while (redisCache.doesKeyExist(key) == 1)
			{
				routineId = getRandomId();

				//create new routine key
				key = "user:" + email + ":" + routineId;
			}


			var routineName = postParams[2];
			var routineWeeks = postParams[4];
			var isPubilc = postParams[6];
			var routineCreator = postParams[8];

			//create routine hash and routine data list
			redisCache.createRoutineHash(key, routineId, routineName, routineWeeks, isPubilc, routineCreator);

			/* 
			 * create list to hold workouts
			 *  - key: user:hello@me.com:routineId:routineData
			 *  - value: list that holds workout ids in list
			 * 
			 * for new routines created, create an empty list
			 * 
			 * then add routine to user Routines list
			 * - key: user:hello@me.com:routines
			 * - value: list that holds routine ids in list
			 */
			key = key + ":routineData";

			//get unique id for workout\\
			var workoutId = getRandomId();

			//create routineData list to hold workout days
			redisCache.createRoutineDataList(key, workoutId);

			/*
			 * create (7*numWeeks) number of blank workouts
			 * so the app can function even with 7 empty
			 * workouts for a week, all populated with ids 
			 */

			createEmptyWorkouts(routineId, Int16.Parse(routineWeeks), email);
		

			//now add routine to users routine list
			redisCache.addRoutineToUserList("user:" + email + ":routines", routineId);
			          
			return Ok("Created " + routineName + " successfully!");
					
		}

		public void createEmptyWorkouts(int routineId, int weeks, string email)
		{
			int[] idList = { };

			var routineKey = "user:" + email + ":" + routineId + ":routineData";
			//create ids and empty lists for 7*weeks
			var count = 7 * weeks;

			for (var i = 0; i < count; i++)
			{
				idList.SetValue(i, i);
			}

			//id is based on day count
			redisCache.addWorkoutToRoutineDataList(routineKey, idList);


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
