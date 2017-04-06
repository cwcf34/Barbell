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
            return regisOutput + authOutput;
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

            string resultString = HttpPOST(apiServer + "user/" + generatedUser.Email + "/", "\"{name:Beavis Sinatra,password:" + generatedUser.Password + "}\"");
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

        private static string HttpPOST(string url, string querystring)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.ContentType = "application/json";
            request.Method = "POST";
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
        public User(string email, string password)
        {
            Email = email;
            Password = password;
        }
    }
}
