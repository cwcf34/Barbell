using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using BBAPI.Helpers;
using System.Security.Claims;

namespace BBAPI.Controllers
{
    public class TestController : ApiController
    {
        /// <summary>
        /// This function is just to test the API's ability to validate a token
        /// </summary>
        /// <returns>S</returns>
        [HttpGet]
        [Authorize]
        public IHttpActionResult GetTest()
        {
            return Ok("Success");
        }
    }
}