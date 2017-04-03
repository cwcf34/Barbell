using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Claims;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;

namespace APITest
{
    public static class Tests
    {
        private static string authServer = "http://bbapi.eastus.cloudapp.azure.com:63894";
        private static string apiServer = "http://bbapi.eastus.cloudapp.azure.com/api/";
        private static DateTime start;
        private static TimeSpan elapsed;



        public static string RunAllTests()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Grabs a token from the auth server and tries handing it to the api
        /// </summary>
        /// <returns>A string of the output to show to the user</returns>
        public async static Task<string> RunSecurityTest()
        {
            string returnString = "testing authentication for user d123@me.com...\n";

            
            TokenResponse response = await GetTokenAsync();
            returnString += String.Format("Response time: {0:g}", elapsed) + " seconds\n";


            returnString += "Access token: " + response.AccessToken + "\n";

            returnString += "Handing token to API...\n";

            //Not tested yet
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", response.AccessToken);
                var result = await client.GetAsync(apiServer + "test/");
                returnString += result.ToString();
            }

            return returnString;
        }

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
                            "d123@me.com"),

                        new KeyValuePair<string, string>(
                            "password",
                            "hello")
                    }));

                start = DateTime.Now;
                var data = await rawResult.Content.ReadAsStringAsync();
                elapsed = (DateTime.Now - start);

                return JsonConvert.DeserializeObject<TokenResponse>(data);
            }
        }
    }


    public class TokenResponse
    {
        [JsonProperty("access_token")]
        public string AccessToken { get; set; }
        [JsonProperty("refresh_token")]
        public string RefreshToken { get; set; }
    }
}
