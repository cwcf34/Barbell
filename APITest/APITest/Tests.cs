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




        public async static Task<string> RunAllTests()
        {
            string regisOutput = RunRegistrationTest();
            string authOutput = await RunSecurityTest();
            string routineOutput = RunRoutineTests();

            return regisOutput + authOutput + routineOutput;
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
            Console.WriteLine(resultString);
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


        /*
         * Step 1: Post a routine
         * Step 2: Get all routines
         * Step 3: Get one routine in particular
         */
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
            Console.WriteLine(resultString);

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

            //Console.WriteLine(returnedRoutines);
            //+ "/" + generatedRoutine.Id
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
}
