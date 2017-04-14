using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Claims;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using System.Net;
using System.IO;

namespace APITest
{
    public static class Tests
    {
        private static string authServer = "http://bbapi.eastus.cloudapp.azure.com:63894";
        private static string apiServer = "http://bbapi.eastus.cloudapp.azure.com/api/";
        private static DateTime start;
        private static TimeSpan elapsed;
        private static Random random = new Random(); //for random string generator
        private static User generatedUser = new User("d123@me.com", "hello");
        private static Routine generatedRoutine;
        private static Workout generatedWorkout;
        private static Exercise generatedExercise;




        public async static Task<string> RunAllTests()
        {
            string regisOutput = RunRegistrationTest();
            string authOutput = await RunSecurityTest();
            string routineOutput = RunRoutineTests();
            string workoutOutput = RunWorkoutTests();
            string exerciseOutput = RunExerciseTests();

            return regisOutput + authOutput + routineOutput + workoutOutput + exerciseOutput;
        }

        /// <summary>
        /// Creates a user and registers that user
        /// </summary>
        /// <returns>String of output</returns>
        public static string RunRegistrationTest()
        {
            generatedUser.Email = RandomString(15) + "@gmail.com";
            generatedUser.Password = RandomString(20);
            string returnString = "Attempting to register user " + generatedUser.Email + "...";

            string resultString = HttpCall(apiServer + "user/" + generatedUser.Email + "/", "\"{name:Beavis Sinatra,password:" + generatedUser.Password + "}\"", "POST");
            resultString = resultString.Equals("\"true\"") ? "Success" : "Failure";
            returnString += "Output: " + resultString + "\n";

            return returnString + String.Format("Response time: {0:g}", elapsed) + " seconds\n";
            
        }

        /// <summary>
        /// Grabs a token from the auth server and tries handing it to the api
        /// </summary>
        /// <returns>A string of the output to show to the user</returns>
        public async static Task<string> RunSecurityTest()
        {
            string returnString = "testing authentication for user " + generatedUser.Email + "...";

            
            TokenResponse response = await GetTokenAsync();
            string timeElapsed = String.Format("Response time: {0:g}", elapsed) + " seconds\n";

            //Check access token
            if(response.AccessToken == null)
            {
                returnString += "Authentication failed\n";
                return returnString + timeElapsed;
            }else
            {
                returnString += "Success\n" + timeElapsed;
            }

            returnString += "Handing token to API...";

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", response.AccessToken);
                var result = await client.GetAsync(apiServer + "test/");

                if(result.Content.ReadAsStringAsync() == null)
                {
                    returnString += "Invalid token\n";
                }
                else
                {
                    returnString += "Success\n";
                }
            }

            return returnString;
        }


        /// <summary>
        ///  * Step 1: Post a routine
        ///  * Step 2: Get all routines and check them
        ///  * Step 3: Get routines by ID returned from the POST and check them
        /// </summary>
        /// <returns>String of the output</returns>
        public static string RunRoutineTests()
        {
            string returnString = "Running tests on the routine controller...\n"
                + "Creating multiple routines for " + generatedUser.Email + "...";

            //"{name:routineName,weeks:numberOfweeks,public:0/1,creator:email}";
            //Create a new routine
            Routine[] generatedRoutines = { new Routine(RandomString(6), "5", "1"), new Routine(RandomString(6), "5", "1") };

            //Generate the query string to POST this routine
            string queryString = "\"{name:" + generatedRoutines[0].Name + ",weeks:" + generatedRoutines[0].numWeeks + ",isPublic:" 
                + generatedRoutines[0].isPublic + ",creator:" + generatedUser.Email + "}\"";
            string queryString2 = "\"{name:" + generatedRoutines[1].Name + ",weeks:" + generatedRoutines[1].numWeeks + ",isPublic:"
                + generatedRoutines[1].isPublic + ",creator:" + generatedUser.Email + "}\"";


            //Send the call to the api
            string resultString = HttpCall(apiServer + "routine/" + generatedUser.Email + "/", queryString, "POST");
            string resultString2 = HttpCall(apiServer + "routine/" + generatedUser.Email + "/", queryString2, "POST");

            //Find out if we recieved a success of failure
            try
            {
                //Since the return should be a numerical ID, try to parse it. If it fails, we recieved an error code
                Int64.Parse(resultString);
                Int64.Parse(resultString2);

                generatedRoutines[0].Id = resultString;
                generatedRoutines[1].Id = resultString2;
                returnString += "Success\n";
            }
            catch
            {
                returnString += "Failure\n";
            }
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n"
                + "Getting all routines for this user from the API and comparing them...";

            //Get all the routines for this user now. It should be equal to the ones we just set
            resultString = HttpCall(apiServer + "routine/" + generatedUser.Email + "/", "", "GET");

            Routine[] returnedRoutines = JsonConvert.DeserializeObject<Routine[]>(resultString);

            //Compare
            if(generatedRoutines[0].Equals(returnedRoutines[1]) && generatedRoutines[1].Equals(returnedRoutines[0]))
            {
                returnString += "Success\n";
            }
            else
            {
                returnString += "Failure\n";
            }
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n";


            returnString += "Testing API call: GET routine...";
            //Testing get routine api call
            resultString = HttpCall(apiServer + "routine/" + generatedUser.Email + "/" + generatedRoutines[0].Id + "/", "", "GET");
            returnedRoutines[0] = JsonConvert.DeserializeObject<Routine>(resultString);
            resultString = HttpCall(apiServer + "routine/" + generatedUser.Email + "/" + generatedRoutines[1].Id + "/", "", "GET");
            returnedRoutines[1] = JsonConvert.DeserializeObject<Routine>(resultString);
            //Compare
            if (generatedRoutines[0].Equals(returnedRoutines[0]) && generatedRoutines[1].Equals(returnedRoutines[1]))
            {
                returnString += "Success\n";
            }
            else
            {
                returnString += "Failure\n";
            }
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n";

            //Set the generatedRoutine to one of these routines so it can be used for testing workouts
            generatedRoutine = generatedRoutines[0];
            return returnString;
        }

        /// <summary>
        ///     Step 1: Post a workout
        ///     Step 2: Get all workouts for a routine
        ///     Step 3: Get a specific workout for a routine
        /// </summary>
        /// <returns></returns>
        public static string RunWorkoutTests()
        {
            string returnString = "Running tests on the workout controller...\n"
                + "POSTing workouts to the API...";

            Random random = new Random();
            Workout[] generatedWorkouts = new Workout[2];
            generatedWorkouts[0] = new Workout(generatedRoutine.Id, RandomString(5), random.Next(1, 10).ToString(), 
                random.Next(1, 15).ToString(), random.Next(5, 500).ToString(), 
                random.Next(0, int.Parse(generatedRoutine.numWeeks) * 7 - 1).ToString());
            generatedWorkouts[1] = new Workout(generatedRoutine.Id, RandomString(5), random.Next(1, 10).ToString(),
                random.Next(1, 15).ToString(), random.Next(5, 500).ToString(),
                random.Next(0, int.Parse(generatedRoutine.numWeeks) * 7 - 1).ToString());
            

            //Create the query string
            //format: "{routineId:4329432,exercise:squat,sets:5,reps:5,weight:420,dayIndex:3}";
            string queryString = "\"{routineId:" + generatedWorkouts[0].routineId + ",exercise:" + generatedWorkouts[0].exercise
                + ",sets:" + generatedWorkouts[0].sets + ",reps:" + generatedWorkouts[0].reps + ",weight:" + generatedWorkouts[0].weight 
                + ",dayIndex:" + generatedWorkouts[0].dayIndex + "}\"";

            string queryString2 = "\"{routineId:" + generatedWorkouts[1].routineId + ",exercise:" + generatedWorkouts[1].exercise
                + ",sets:" + generatedWorkouts[1].sets + ",reps:" + generatedWorkouts[1].reps + ",weight:" + generatedWorkouts[1].weight
                + ",dayIndex:" + generatedWorkouts[1].dayIndex + "}\"";

            string resultString = HttpCall(apiServer + "workout/" + generatedUser.Email + "/", queryString, "POST");
            string resultString2 = HttpCall(apiServer + "workout/" + generatedUser.Email + "/", queryString2, "POST");

            returnString += (resultString.ToLower().Equals("true") && resultString2.ToLower().Equals("true")) ? "Success\n" : "Failure\n";
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n";

            //get all workouts
            returnString += "Getting all workouts for this routine...";
            resultString = HttpCall(apiServer + "workout/" + generatedUser.Email + "/" + generatedRoutine.Id + "/", "", "GET");
            Console.WriteLine(resultString);

            returnedWorkout[][] returnedWorkouts = JsonConvert.DeserializeObject<returnedWorkout[][]>(resultString);

            //Compare the returned workouts to the workouts we POSTed
            try
            {
                int dayIndex0 = int.Parse(generatedWorkouts[0].dayIndex);
                int dayIndex1 = int.Parse(generatedWorkouts[1].dayIndex);

                //If the 2 workouts are on different days in the routine
                if(dayIndex0 != dayIndex1)
                {
                    bool check0 = (generatedWorkouts[0].Equals(returnedWorkouts[dayIndex0][0]) || generatedWorkouts[0].Equals(returnedWorkouts[dayIndex1][0]));
                    bool check1 = (generatedWorkouts[1].Equals(returnedWorkouts[dayIndex0][0]) || generatedWorkouts[1].Equals(returnedWorkouts[dayIndex1][0]));
                    if (check0 && check1)
                    {
                        returnString += "Success\n";
                    }
                    else
                    {
                        returnString += "Failure\n";
                    }
                        
                }else //dayIndex0 == dayIndex1
                {
                    bool check0 = (generatedWorkouts[0].Equals(returnedWorkouts[dayIndex0][0]) || generatedWorkouts[0].Equals(returnedWorkouts[dayIndex0][1]));
                    bool check1 = (generatedWorkouts[1].Equals(returnedWorkouts[dayIndex0][0]) || generatedWorkouts[1].Equals(returnedWorkouts[dayIndex0][1]));
                    if(check0 && check1)
                    {
                        returnString += "Success\n";
                    }
                    else
                    {
                        returnString += "Failure\n";
                    }
                }
            }
            catch //In the case that int parse fails
            {
                returnString += "Failure\n";
            }
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n";

            //Grab an individual routine from the database and compare it
            returnString += "Getting an individual workout from the API...";

            resultString = HttpCall(apiServer + "workout/" + generatedUser.Email + "/" + generatedRoutine.Id + "/" + generatedWorkouts[0].dayIndex + "/", "", "GET");
            Console.WriteLine(resultString);
            returnedWorkout[] returnedWorkout = JsonConvert.DeserializeObject<returnedWorkout[]>(resultString);

            returnString += generatedWorkouts[0].Equals(returnedWorkout[0]) ? "Success\n" : "Failure\n";
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n";

            generatedWorkout = generatedWorkouts[0];
            return returnString;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private static string RunExerciseTests()
        {
            string returnString = "Running tests on the exercise controller...\n"
                + "POSTing an exercise to the API...";

            generatedExercise = new Exercise("5/02/93", generatedWorkout.exercise, generatedWorkout.sets, generatedWorkout.reps, generatedWorkout.weight);

            //"{date:date, exercise:exerciseName, sets:numOfSets, reps:numOfReps, weight:weightLifted}"
            string queryString = "\"{date:" + generatedExercise.date  + ",exercise:" + generatedExercise.exercise + ",sets:"
                + generatedExercise.sets + ",reps:" + generatedExercise.reps + ",weight:" + generatedExercise.weight +"}\"";

            string resultString = HttpCall(apiServer + "exercise/" + generatedUser.Email + "/", queryString, "PUT");
            Console.WriteLine(resultString);

            return returnString;

        }

        /// <summary>
        /// Helper function for RunSecurityTest that gets a token from the authorization server.
        /// </summary>
        /// <returns>TokenResponse object given by the response from the authorization server</returns>
        private static async Task<TokenResponse> GetTokenAsync()
        {
            using (var client = new HttpClient())
            {
                var basicAuth =
                    Convert.ToBase64String(
                        Encoding.UTF8.GetBytes("iOS:secret"));

                client.DefaultRequestHeaders.Authorization
                    = new AuthenticationHeaderValue("Basic", basicAuth);

                var rawResult = await client.PostAsync(authServer + "/connect/token",
                    new FormUrlEncodedContent(new[]
                    {
                        new KeyValuePair<string, string>(
                            "grant_type",
                            "password"),

                        new KeyValuePair<string, string>(
                            "scope",
                            "WebAPI offline_access"),

                        new KeyValuePair<string, string>(
                            "username",
                            generatedUser.Email),

                        new KeyValuePair<string, string>(
                            "password",
                            generatedUser.Password)
                    }));

                StartStopwatch();
                var data = await rawResult.Content.ReadAsStringAsync();
                StopStopwatch();

                return JsonConvert.DeserializeObject<TokenResponse>(data);
            }
        }


        private static string HttpCall(string url, string querystring, string httpMethod)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.ContentType = "application/json";
            request.Method = httpMethod;

            if (!httpMethod.Equals("GET"))
            {
                StreamWriter requestWriter = new StreamWriter(request.GetRequestStream());

                try
                {
                    requestWriter.Write(querystring);
                }
                catch
                {
                    throw;
                }
                finally
                {
                    requestWriter.Close();
                    requestWriter = null;
                }
            }


            StartStopwatch();
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            StopStopwatch();

            using (StreamReader sr = new StreamReader(response.GetResponseStream()))
            {
                return sr.ReadToEnd();
            }
        }


        private static string RandomString(int length)
        {
            const string chars = "abcdefghijklmnopqrstuvwxyz0123456789";
            return new string(Enumerable.Repeat(chars, length)
              .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        private static void StartStopwatch()
        {
            start = DateTime.Now;
        }

        private static void StopStopwatch()
        {
            elapsed = (DateTime.Now - start);
        }

    }


    public class TokenResponse
    {
        [JsonProperty("access_token")]
        public string AccessToken { get; set; }
        [JsonProperty("refresh_token")]
        public string RefreshToken { get; set; }
    }

    public class User
    {
        public string Email { get; set; }
        public string Password { get; set; }

        public User(string Email, string Password)
        {
            this.Email = Email;
            this.Password = Password;
        }
    }

    public class Routine
    {
        public string Name { get; set; }
        public string Id { get; set; }
        public string numWeeks { get; set; }
        public string isPublic { get; set; }

        public Routine(string Name, string numWeeks, string isPublic)
        {
            this.Name = Name;
            this.numWeeks = numWeeks;
            this.isPublic = isPublic;
        }

        public bool Equals(Routine r)
        {
            // If r is null return false:
            if (r == null)
            {
                return false;
            }

            // Return true if the fields match:
            if(Name == r.Name && Id == r.Id && numWeeks == r.numWeeks && isPublic == r.isPublic)
            {
                return true;
            }else
            {
                return false;
            }
        }
    }

    public class Workout
    {
        //"{routineId:4329432,exercise:squat,sets:5,reps:5,weight:420,dayIndex:3}";
        public string routineId;
        public string exercise; //this is the name of the exercise
        public string sets;
        public string reps;
        public string weight;
        public string dayIndex;

        public Workout(string routineId, string exercise, string sets, string reps, string weight, string dayIndex)
        {
            this.routineId = routineId;
            this.exercise = exercise;
            this.sets = sets;
            this.reps = reps;
            this.weight = weight;
            this.dayIndex = dayIndex;
        }

        public bool Equals(Workout w)
        {
            // If w is null return false:
            if (w == null)
            {
                return false;
            }

            // Return true if the fields match:
            if (routineId == w.routineId && exercise == w.exercise && sets == w.sets && reps == w.reps && weight == w.weight && dayIndex == w.dayIndex)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool Equals(returnedWorkout w)
        {
            if(!String.IsNullOrEmpty(w.Name) || !String.IsNullOrEmpty(w.Value) || !String.IsNullOrEmpty(w.Key))
            {
                string[] vals = w.Value.Split(':');
                if(vals.Length != 3)
                {
                    return false;
                }
                if(exercise.Equals(w.Name) && exercise.Equals(w.Key) && sets.Equals(vals[0]) && reps.Equals(vals[1]) && weight.Equals(vals[2]))
                {
                    return true;
                }
            }
            return false;
        }
    }

    public class returnedWorkout
    {
        public string Name;
        public string Value;
        public string Key;
    }

    //"{date:date, exercise:exerciseName, sets:numOfSets, reps:numOfReps, weight:weightLifted}"
    public class Exercise
    {
        public string date;
        public string exercise;
        public string sets;
        public string reps;
        public string weight;

        public Exercise(string date, string exercise, string sets, string reps, string weight)
        {
            this.date = date;
            this.exercise = exercise;
            this.sets = sets;
            this.reps = reps;
            this.weight = weight;
        }
    }
}
